import 'package:analyzer/file_system/overlay_file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/channel/channel.dart';
import 'package:analyzer_plugin/protocol/protocol.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:ngast/ngast.dart' as ngast;
import 'package:ngdart_analyzer_plugin/src/errors.dart';
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

  test('Should report no errors without any file', () async {
    await initContext();
    expect(channel.errors.length, 0);
  });

  test('Should report parser errors for inline template', () async {
    final paths = await initContext({
      'component.dart': '''
      @Component(
        template: '<div</div>',
      )
      class Example {}
      ''',
    });

    expect(channel.errors[paths['component.dart']]?.length, 1);
    expect(channel.errors[paths['component.dart']]?[0].code, ngast.ParserErrorCode.expectedAfterElementIdentifier.name);
  });

  test('Should report template errors for external file', () async {
    final paths = await initContext({
      'component.dart': '''
      @Component(
        templateUrl: 'component.html',
      )
      class Example {}
      ''',
      'component.html': '<div</div>',
    });
    final componentPath = paths['component.dart'];
    final templatePath = paths['component.html'];

    expect(channel.errors.keys, [templatePath]);
    expect(channel.errors[componentPath], null);
    expect(channel.errors[templatePath]?.length, 1);
    expect(channel.errors[templatePath]?[0].code, ngast.ParserErrorCode.expectedAfterElementIdentifier.name);
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

    expect(channel.errors[templatePath], null);

    // still we send empty errors to reset analysis on this file
    // maybe we should hold a map of files that were not analyzed yet
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

    expect(channel.errors[templatePath]?.length, 1);
    expect(channel.errors[templatePath]?[0].code, ngast.ParserErrorCode.expectedAfterElementIdentifier.name);
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

    final allErrors = channel.errors.values.expand((e) => e);
    expect(allErrors.length, 2);
    expect(allErrors.map((e) => e.code), [
      ngast.ParserErrorCode.expectedAfterElementIdentifier.name,
      ngast.ParserErrorCode.expectedAfterElementIdentifier.name,
    ]);
  });

  test('Should report referenced template does not exists', () async {
    final paths = await initContext({
      'component.dart': '''
      @Component(
        templateUrl: 'non-existent.html',
      )
      class ExampleA {}
      '''
    });
    final componentPath = paths['component.dart'];

    expect(channel.errors[componentPath]?.length, 1);
    expect(channel.errors[componentPath]?[0].code, AngularWarningCode.referencedHtmlFileDoesntExist.name);
  });
}

class SpyCommunicationChanngel implements PluginCommunicationChannel {
  final notifications = <Notification>[];
  final errors = <String, List<AnalysisError>>{};

  final responses = <Response>[];

  @override
  void close() {}

  @override
  void listen(void Function(Request request) onRequest, {Function? onError, void Function()? onDone}) {}

  @override
  void sendNotification(Notification notification) {
    notifications.add(notification);
    if (notification.event == 'analysis.errors') {
      final errorParams = AnalysisErrorsParams.fromNotification(notification);
      if (errorParams.errors.isEmpty) {
        return;
      }

      errors[errorParams.file] = errorParams.errors;
    }
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
