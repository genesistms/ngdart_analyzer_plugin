import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer_plugin/channel/channel.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:ngast/ngast.dart' as ngast;

import 'syntactic_discovery.dart' as syntactic;

void debug(PluginCommunicationChannel channel, String message, [String code = 'DEBUG']) {
  channel.sendNotification(PluginErrorParams(false, message, code).toNotification());
}

class AngularPlugin extends ServerPlugin {
  AngularPlugin({required super.resourceProvider});

  @override
  final fileGlobsToAnalyze = ['**/*.dart'];

  @override
  final name = 'Angular plugin';

  @override
  final version = '1.0.0';

  @override
  Future<void> analyzeFile({required AnalysisContext analysisContext, required String path}) async {
    if (!path.endsWith('.dart')) {
      return;
    }

    final result = analysisContext.currentSession.getParsedUnit(path);
    if (result is! ParsedUnitResult) {
      return;
    }

    final analysisErrors = <String, List<AnalysisError>>{};
    for (final component in syntactic.findComponents(result.unit)) {
      final template = component.template;
      if (template != null) {
        final recoveringExceptionHandler = ngast.RecoveringExceptionHandler();
        ngast.parse(
          template.value,
          sourceUrl: path,
          desugar: false,
          exceptionHandler: recoveringExceptionHandler,
        );

        analysisErrors[path] = recoveringExceptionHandler.exceptions.map((exception) {
          return AnalysisError(
            AnalysisErrorSeverity.ERROR,
            AnalysisErrorType.SYNTACTIC_ERROR,
            Location(path, template.range.offset + (exception.offset ?? 0), exception.length ?? 0, 0, 0),
            exception.errorCode.message,
            exception.errorCode.name,
          );
        }).toList(growable: false);
      }

      final templateUrl = component.templateUrl;
      if (templateUrl != null) {
        try {
          final templatePath = Uri.file(path).resolve(templateUrl.value).toFilePath();
          final templateFile = resourceProvider.getFile(templatePath);

          final recoveringExceptionHandler = ngast.RecoveringExceptionHandler();
          ngast.parse(
            templateFile.readAsStringSync(),
            sourceUrl: templatePath,
            desugar: false,
            exceptionHandler: recoveringExceptionHandler,
          );

          analysisErrors[templatePath] = recoveringExceptionHandler.exceptions.map((exception) {
            return AnalysisError(
              AnalysisErrorSeverity.ERROR,
              AnalysisErrorType.SYNTACTIC_ERROR,
              Location(templatePath, exception.offset ?? 0, exception.length ?? 0, 0, 0),
              exception.errorCode.message,
              exception.errorCode.name,
            );
          }).toList(growable: false);
        } on PathNotFoundException catch (_) {
          // TODO(tms): report file does not exists
        }
      }
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
