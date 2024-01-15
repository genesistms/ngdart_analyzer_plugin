import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/file_system/overlay_file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/channel/channel.dart';
import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:ngdart_analyzer_plugin/src/plugin.dart';
import 'package:test/test.dart';

void main() {
  late SpyCommunicationChanngel channel;
  late AngularPlugin plugin;

  setUp(() {
    plugin = AngularPlugin(
      resourceProvider: OverlayResourceProvider(PhysicalResourceProvider.INSTANCE),
    );
    channel = SpyCommunicationChanngel();
    plugin.start(channel);
  });

  String newFile(String content, {required String relativePath}) {
    final path = plugin.resourceProvider.pathContext.absolute(relativePath);
    plugin.resourceProvider.setOverlay(path, content: content, modificationStamp: 0);
    return path;
  }

  test('Should send no notifications without analyzing', () async {
    await plugin.afterNewContextCollection(
      contextCollection: AnalysisContextCollection(
        includedPaths: [],
        resourceProvider: plugin.resourceProvider,
      ),
    );
    expect(channel.notifications.length, 0);
  });

  test('Should report inline template errors as diagnostics', () async {
    String componentPath = newFile(
      relativePath: 'component.dart',
      '''
      @Component(
        template: '<div</div>',
      )
      class Example {}
      ''',
    );

    await plugin.afterNewContextCollection(
      contextCollection: AnalysisContextCollection(
        includedPaths: [componentPath],
        resourceProvider: plugin.resourceProvider,
      ),
    );

    expect(channel.notifications.length, 1);
    expect(channel.notifications[0].event, 'analysis.errors');
  });

  test('Should report external template errors as diagnostics', () async {
    final componentPath = newFile(
      relativePath: 'component.dart',
      '''
      @Component(
        templateUrl: 'component.html',
      )
      class Example {}
      ''',
    );

    newFile(
      relativePath: 'component.html',
      '''
      <div</div>
    ''',
    );

    await plugin.afterNewContextCollection(
      contextCollection: AnalysisContextCollection(
        includedPaths: [componentPath],
        resourceProvider: plugin.resourceProvider,
      ),
    );

    expect(channel.notifications.length, 1);
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
