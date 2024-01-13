import 'dart:isolate';

import 'package:ngdart_analyzer_plugin/starter.dart' as plugin;

void main(List<String> args, SendPort sendPort) {
  plugin.start(args, sendPort);
}
