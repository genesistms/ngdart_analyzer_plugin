import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer_plugin/channel/channel.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';

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
  Future<void> analyzeFile({required AnalysisContext analysisContext, required String path}) async {}
}
