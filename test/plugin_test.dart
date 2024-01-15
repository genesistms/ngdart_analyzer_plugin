import 'package:analyzer/file_system/overlay_file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/channel/channel.dart';
import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:ngdart_analyzer_plugin/src/plugin.dart';
import 'package:test/test.dart';

const _testDir = '_test_lib';

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
    final path = plugin.resourceProvider.pathContext.absolute(_testDir, relativePath);
    plugin.resourceProvider.setOverlay(path, content: content, modificationStamp: 0);
    return path;
  }

  Future<Map<String, String>> initContext([Map<String, String> files = const {}]) async {
    final result = <String, String>{};
    files.forEach((key, value) {
      result[key] = newFile(relativePath: key, value);
    });

    await plugin.handleAnalysisSetContextRoots(
      AnalysisSetContextRootsParams(
        [ContextRoot(plugin.resourceProvider.pathContext.absolute(_testDir), [])],
      ),
    );

    return result;
  }

  test('Should send no notifications without analyzing', () async {
    await initContext();
    expect(channel.notifications.length, 0);
  });

  test('Should report inline template errors as diagnostics', () async {
    await initContext({
      'component.dart': '''
      @Component(
        template: '<div</div>',
      )
      class Example {}
      ''',
    });
    expect(channel.notifications.length, 1);
    expect(channel.notifications[0].event, 'analysis.errors');
  });

  test('Should report external template errors as diagnostics', () async {
    final paths = await initContext({
      'component.dart': '''
      @Component(
        templateUrl: 'component.html',
      )
      class Example {}
      ''',
      'component.html': '<div</div>',
    });

    expect(channel.notifications.length, 2);

    final componentNotification = channel.notifications.firstWhere((n) => n.params?['file'] == paths['component.dart']);
    expect(componentNotification.event, 'analysis.errors');
    expect(componentNotification.params?['errors'], isEmpty);

    final templateNotification = channel.notifications.firstWhere((n) => n.params?['file'] == paths['component.html']);
    expect(templateNotification.event, 'analysis.errors');
    expect(templateNotification.params?['errors'], isNotEmpty);
  });

  test('Should report after update content', () async {
    final paths = await initContext({
      'component.dart': '''
      @Component(
        templateUrl: 'component.html',
      )
      class Example {}
      ''',
      'component.html': '<div></div>',
    });
    final templatePath = paths['component.html']!;

    expect(channel.notifications.length, 2);
    expect(channel.notifications[0].event, 'analysis.errors');
    expect(channel.notifications[0].params?['errors'], isEmpty);
    expect(channel.notifications[1].event, 'analysis.errors');
    expect(channel.notifications[1].params?['errors'], isEmpty);
    channel.spyReset();

    await plugin.handleAnalysisSetPriorityFiles(AnalysisSetPriorityFilesParams([templatePath]));
    await plugin.handleAnalysisUpdateContent(
      AnalysisUpdateContentParams(
        {templatePath: AddContentOverlay('<div</div>')},
      ),
    );

    expect(channel.notifications.length, 1);
    expect(channel.notifications.first.params?['errors'], isNotEmpty);
  });

  test('Should report external template errors as diagnostics for each component', () async {
    await initContext({
      'component.dart': '''
      @Component(
        template: '<div</div>',
      )
      class ExampleA {}

      @Component(
        template: '<p</p>',
      )
      class ExampleB {}
      '''
    });

    expect(channel.notifications.length, 1);
    expect(channel.notifications[0].event, 'analysis.errors');
    expect((channel.notifications[0].params?['errors'] as List).length, 2);
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

  void spyReset() {
    notifications.clear();
    responses.clear();
  }
}
