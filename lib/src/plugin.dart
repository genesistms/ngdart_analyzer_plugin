import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart' as ast;
import 'package:analyzer_plugin/channel/channel.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:collection/collection.dart';
import 'package:ngast/ngast.dart' as ngast;
import 'package:ngdart_analyzer_plugin/src/offsetting_constant_evaluator.dart';

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

    for (final declaration in result.unit.declarations) {
      if (declaration is! ast.ClassDeclaration) {
        continue;
      }

      final annotationNode = declaration.metadata.firstWhereOrNull((m) => m.name.name == 'Component');
      if (annotationNode == null) {
        continue;
      }

      final expression = getNamedArgument(annotationNode, 'template');
      if (expression == null) {
        continue;
      }

      final evaluator = OffsettingConstantEvaluator();
      evaluator.value = expression.accept(evaluator);
      if (!evaluator.offsetsAreValid || evaluator.value is! String) {
        continue;
      }

      final templateOffset = expression.offset;
      final templateText = evaluator.value as String;
      final recoveringExceptionHandler = ngast.RecoveringExceptionHandler();
      ngast.parse(
        templateText,
        sourceUrl: path,
        desugar: false,
        exceptionHandler: recoveringExceptionHandler,
      );

      if (recoveringExceptionHandler.exceptions.isNotEmpty) {
        for (final exception in recoveringExceptionHandler.exceptions) {
          channel.sendNotification(
            AnalysisErrorsParams(path, [
              AnalysisError(
                AnalysisErrorSeverity.ERROR,
                AnalysisErrorType.SYNTACTIC_ERROR,
                Location(path, templateOffset + (exception.offset ?? 0), exception.length ?? 0, 0, 0),
                exception.errorCode.message,
                exception.errorCode.name,
              ),
            ]).toNotification(),
          );
        }
      } else {
        channel.sendNotification(Notification('analysis.errors', {'file': path, 'errors': []}));
      }
    }
  }
}

ast.Expression? getNamedArgument(ast.Annotation node, String name) {
  if (node.arguments == null) {
    return null;
  }

  final arguments = node.arguments?.arguments;
  if (arguments == null) {
    return null;
  }

  for (final argument in arguments) {
    if (argument is ast.NamedExpression && argument.name.label.name == name) {
      return argument.expression;
    }
  }

  return null;
}
