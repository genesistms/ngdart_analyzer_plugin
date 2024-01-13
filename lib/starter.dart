import 'dart:isolate';

import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/starter.dart';
import 'package:ngdart_analyzer_plugin/src/plugin.dart';

void start(List<String> args, SendPort sendPort) {
  ServerPluginStarter(
    AngularPlugin(resourceProvider: PhysicalResourceProvider.INSTANCE),
  ).start(sendPort);
}
