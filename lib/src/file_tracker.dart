/// Compute relationships between dart & html contents.
///
/// We also want to be able to discover the relationships between
/// Dart and HTML files so that when an HTML file is updated, we can efficiently
/// reanalyze only the dart files that are affected.
class FileTracker {
  final _dartToDart = _RelationshipTracker();
  final _dartToHtml = _RelationshipTracker();
  final _dartFilesWithDartTemplates = <String>{};

  /// Find Dart sources affected by an HTML change that need reanalysis.
  ///
  /// This is used to reanalyze the correct Dart files when HTML files are
  /// updated.
  List<String> getDartPathsAffectedByHtml(String htmlPath) => _dartToHtml
      .getFilesReferencingFile(htmlPath)
      .map(_dartToDart.getFilesReferencingFile)
      .fold<List<String>>(<String>[], (list, acc) => list..addAll(acc))
      .where(_dartFilesWithDartTemplates.contains)
      .toList();

  /// Find Dart sources that refer directly to [htmlPath].
  ///
  /// This is used to be able to analyze [htmlPath], where we need to know which
  /// components reference that [htmlPath].
  List<String> getDartPathsReferencingHtml(String htmlPath) => _dartToHtml.getFilesReferencingFile(htmlPath);

  /// Get the HTML files that affect a Dart file at [dartPath].
  ///
  /// This occurs when, for instance, a main component with an inline template
  /// imports a secondary component with a templateUrl. That main component's
  /// template string must be analyzed against the latest version of the
  /// secondary HTML, which may define `<ng-content>`s that affect the result.
  ///
  /// This is used to know when Dart files have to be reanalyzed when an HTML
  /// file is updated.
  List<String> getHtmlPathsAffectingDart(String dartPath) {
    if (_dartFilesWithDartTemplates.contains(dartPath)) {
      return getHtmlPathsAffectingDartContext(dartPath);
    }

    return [];
  }

  /// Get the HTML files that affect APIs of components defined in [dartPath].
  ///
  /// This is used to by [getDartSignature] and [getHtmlSignature] to ensure
  /// that Dart result signatures include the signatures of all HTML files that
  /// affected that result.
  List<String> getHtmlPathsAffectingDartContext(String dartPath) => _dartToDart
      .getFilesReferencedBy(dartPath)
      .map(_dartToHtml.getFilesReferencedBy)
      .fold<List<String>>(<String>[], (list, acc) => list..addAll(acc)).toList();

  /// Get the HTML files that are directly referenced by Dart file [dartPath].
  List<String> getHtmlPathsReferencedByDart(String dartPath) => _dartToHtml.getFilesReferencedBy(dartPath);

  /// Get the HTML files that depend on the state of [htmlPath].
  ///
  /// This occurs when, for instance, a main component with a templateUrl
  /// imports a secondary component with a templateUrl. That main component's
  /// template HTML file must be analyzed against the latest version of the
  /// secondary HTML, which may define `<ng-content>`s that affect the result.
  ///
  /// This is used to efficiently reanalyze the HTML files that need to be
  /// reanalyzed when other HTML files are updated.
  List<String> getHtmlPathsReferencingHtml(String htmlPath) => _dartToHtml
      .getFilesReferencingFile(htmlPath)
      .map(_dartToDart.getFilesReferencingFile)
      .fold<List<String>>(<String>[], (list, acc) => list..addAll(acc))
      .map(_dartToHtml.getFilesReferencedBy)
      .fold<List<String>>(<String>[], (list, acc) => list..addAll(acc))
      .toList();

  /// Note that the latset version of [dartPath] has an inline template or not.
  void setDartHasTemplate(String dartPath, bool hasTemplate) {
    if (hasTemplate) {
      _dartFilesWithDartTemplates.add(dartPath);
    } else {
      _dartFilesWithDartTemplates.remove(dartPath);
    }
  }

  /// Note that the latest version of [dartPath] refers to [htmlPaths].
  void setDartHtmlTemplates(String dartPath, List<String> htmlPaths) =>
      _dartToHtml.setFileReferencesFiles(dartPath, htmlPaths);

  /// Note that the latest version of [dartPath] refers to [imports].
  void setDartImports(String dartPath, List<String> imports) {
    _dartToDart.setFileReferencesFiles(dartPath, imports);
  }
}

class _RelationshipTracker {
  final _filesReferencedByFile = <String, List<String>>{};
  final _filesReferencingFile = <String, List<String>>{};

  List<String> getFilesReferencedBy(String filePath) => _filesReferencedByFile[filePath] ?? [];

  List<String> getFilesReferencingFile(String usesPath) => _filesReferencingFile[usesPath] ?? [];

  void setFileReferencesFiles(String filePath, List<String> referencesPaths) {
    final priorRelationships = <String>{};
    if (_filesReferencedByFile.containsKey(filePath)) {
      for (final referencesPath in _filesReferencedByFile[filePath]!) {
        if (!referencesPaths.contains(referencesPath)) {
          _filesReferencingFile[referencesPath]!.remove(filePath);
        } else {
          priorRelationships.add(referencesPath);
        }
      }
    }

    _filesReferencedByFile[filePath] = referencesPaths;

    for (final referencesPath in referencesPaths) {
      if (priorRelationships.contains(referencesPath)) {
        continue;
      }

      if (!_filesReferencingFile.containsKey(referencesPath)) {
        _filesReferencingFile[referencesPath] = [filePath];
      } else {
        _filesReferencingFile[referencesPath]!.add(filePath);
      }
    }
  }
}
