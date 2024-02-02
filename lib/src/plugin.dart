import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/channel/channel.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:ngast/ngast.dart' as ngast;
import 'package:ngdart_analyzer_plugin/src/errors.dart';
import 'package:ngdart_analyzer_plugin/src/file_tracker.dart';
import 'package:ngdart_analyzer_plugin/src/syntactic_discovery.dart' as syntactic;

void debug(PluginCommunicationChannel channel, String message, [String code = 'DEBUG']) {
  channel.sendNotification(PluginErrorParams(false, message, code).toNotification());
}

class AngularPlugin extends ServerPlugin {
  AngularPlugin({required super.resourceProvider});

  @override
  final fileGlobsToAnalyze = ['**/*.dart', '**/*.html'];

  @override
  final name = 'Angular plugin';

  @override
  final version = '1.0.0';

  final fileTracker = FileTracker();
  final _waitingHtmlFiles = <String>{};

  @override
  Future<void> analyzeFile({required AnalysisContext analysisContext, required String path}) async {
    if (path.endsWith('.dart')) {
      _analyzeDart(analysisContext: analysisContext, path: path);
    } else if (path.endsWith('.html')) {
      _analyzeHtml(analysisContext: analysisContext, path: path);
    }
  }

  void _analyzeDart({required AnalysisContext analysisContext, required String path}) {
    final result = analysisContext.currentSession.getParsedUnit(path);
    if (result is! ParsedUnitResult) {
      return;
    }

    final analysisErrors = <String, List<AnalysisError>>{};
    analysisErrors[path] = [];

    var hasTemplate = false;
    final templateUrlPaths = <String>{};
    for (final (component, errors) in syntactic.findComponents(result.unit)) {
      if (errors != null) {
        analysisErrors[path]?.addAll(
          errors.map(
            (error) => AnalysisError(
              AnalysisErrorSeverity.WARNING,
              AnalysisErrorType.STATIC_WARNING,
              Location(path, error.range.offset, error.range.length, 0, 0),
              error.message(),
              error.code.name,
            ),
          ),
        );
      }

      final template = component.template;
      if (template != null) {
        hasTemplate = true;
        final templateErrors = _validateHtml(path, template.value, offset: template.range.offset);
        analysisErrors[path]?.addAll(templateErrors);
      }

      // clear analysis for templates that may not be linked anymore
      //
      // in cases where user removed `templateUrl` from annotation
      for (final tp in fileTracker.getHtmlPathsReferencedByDart(path)) {
        analysisErrors[tp] = [];
      }

      final templateUrl = component.templateUrl;
      if (templateUrl != null) {
        final templatePath = Uri.file(path).resolve(templateUrl.value).toFilePath();
        templateUrlPaths.add(templatePath);
        if (!resourceProvider.getFile(templatePath).exists) {
          analysisErrors[path]?.add(
            AnalysisError(
              AnalysisErrorSeverity.WARNING,
              AnalysisErrorType.STATIC_WARNING,
              Location(path, templateUrl.range.offset, templateUrl.range.length, 0, 0),
              AngularWarningCode.referencedHtmlFileDoesntExist.message,
              AngularWarningCode.referencedHtmlFileDoesntExist.name,
            ),
          );
        }
      }
    }

    fileTracker.setDartHasTemplate(path, hasTemplate);
    fileTracker.setDartHtmlTemplates(path, templateUrlPaths.toList());

    // check if template file is waiting for its component pair
    //
    // we need to analyze it here because when analyzer sent us this file we
    // didn't have its component pair
    for (final templatePath in templateUrlPaths.where(_waitingHtmlFiles.contains)) {
      _analyzeHtml(analysisContext: analysisContext, path: templatePath);
    }

    analysisErrors.forEach((path, errors) {
      if (errors.isEmpty) {
        channel.sendNotification(Notification('analysis.errors', {'file': path, 'errors': []}));
        return;
      }

      channel.sendNotification(AnalysisErrorsParams(path, errors).toNotification());
    });
  }

  void _analyzeHtml({required AnalysisContext analysisContext, required String path}) {
    final analysisErrors = <String, List<AnalysisError>>{};
    analysisErrors[path] = [];

    try {
      final file = resourceProvider.getFile(path);
      final isReferenced = fileTracker.getDartPathsReferencingHtml(path).isNotEmpty;
      if (!isReferenced) {
        _waitingHtmlFiles.add(path);
        return;
      }

      analysisErrors[path] = _validateHtml(path, file.readAsStringSync());
    } catch (_) {
      // ignore
    }

    analysisErrors.forEach((path, errors) {
      if (errors.isEmpty) {
        channel.sendNotification(Notification('analysis.errors', {'file': path, 'errors': []}));
        return;
      }

      channel.sendNotification(AnalysisErrorsParams(path, errors).toNotification());
    });
  }
}

List<AnalysisError> _validateHtml(String path, String content, {int offset = 0}) {
  final recoveringExceptionHandler = ngast.RecoveringExceptionHandler();
  ngast.parse(
    content,
    sourceUrl: path,
    desugar: false,
    exceptionHandler: recoveringExceptionHandler,
  );

  return recoveringExceptionHandler.exceptions
      .map(
        (exception) => AnalysisError(
          AnalysisErrorSeverity.ERROR,
          AnalysisErrorType.SYNTACTIC_ERROR,
          Location(path, offset + (exception.offset ?? 0), exception.length ?? 0, 0, 0),
          exception.errorCode.message,
          exception.errorCode.name,
        ),
      )
      .toList(growable: false);
}
