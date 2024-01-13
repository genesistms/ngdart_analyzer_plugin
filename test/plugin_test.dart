import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/file_system/overlay_file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/channel/channel.dart';
import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:ngdart_analyzer_plugin/src/plugin.dart';
import 'package:test/test.dart';

void main() {
  test('Initial notifications after new context', () async {
    final resourceProvider = OverlayResourceProvider(PhysicalResourceProvider.INSTANCE);
    final channel = SpyCommunicationChanngel();
    final plugin = AngularPlugin(resourceProvider: resourceProvider)..start(channel);

    final collection = AnalysisContextCollection(
      includedPaths: [],
      resourceProvider: resourceProvider,
    );
    await plugin.afterNewContextCollection(contextCollection: collection);
    expect(channel.notifications.length, 0);
  });

  test('Should report template errors as diagnostics', () async {
    final resourceProvider = OverlayResourceProvider(PhysicalResourceProvider.INSTANCE);
    final componentCode = '''
      @Component(
        template: '<div</div>',
      )
      class Example {}
      ''';
    final componentPath = resourceProvider.pathContext.absolute('component.dart');
    resourceProvider.setOverlay(componentPath, content: componentCode, modificationStamp: 0);

    final plugin = AngularPlugin(resourceProvider: resourceProvider);
    final channel = SpyCommunicationChanngel();
    plugin.start(channel);

    await plugin.afterNewContextCollection(
      contextCollection: AnalysisContextCollection(
        includedPaths: [componentPath],
        resourceProvider: resourceProvider,
      ),
    );

    expect(channel.notifications.length, greaterThan(0));
    expect(channel.notifications[0].event, 'analysis.errors');
  });
}

class SpyCommunicationChanngel implements PluginCommunicationChannel {
  final notifications = <Notification>[];
  final responses = <Response>[];

  @override
  void close() {}

  @override
  void listen(void Function(Request request) onRequest, {Function? onError, void Function()? onDone}) {}

  @override
  void sendNotification(Notification notification) {
    notifications.add(notification);
  }

  @override
  void sendResponse(Response response) {
    responses.add(response);
  }
}
