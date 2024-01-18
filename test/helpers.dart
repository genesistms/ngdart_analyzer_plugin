import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/overlay_file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:ngdart_analyzer_plugin/src/errors.dart';
import 'package:ngdart_analyzer_plugin/src/syntactic/component.dart' as syntactic;
import 'package:ngdart_analyzer_plugin/src/syntactic_discovery.dart' as syntactic;
import 'package:test/test.dart';

(syntactic.Component, List<AngularWarning>?) singleComponentParse(String componentCode) {
  final resourceProvider = OverlayResourceProvider(PhysicalResourceProvider.INSTANCE);
  final path = resourceProvider.pathContext.absolute('file.dart');
  resourceProvider.setOverlay(path, content: componentCode, modificationStamp: 0);

  final collection = AnalysisContextCollection(
    includedPaths: [path],
    resourceProvider: resourceProvider,
  );

  final result = collection.contextFor(path).currentSession.getParsedUnit(path);
  if (result is! ParsedUnitResult) {
    fail('Expected ParsedUnitResult but got ${result.runtimeType}');
  }

  final components = syntactic.findComponents(result.unit);
  if (components.isEmpty) {
    fail('Expected at least one component');
  }

  return components.first;
}
