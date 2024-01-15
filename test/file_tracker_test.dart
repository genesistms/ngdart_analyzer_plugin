import 'package:ngdart_analyzer_plugin/src/file_tracker.dart';
import 'package:test/test.dart';

void main() {
  late FileTracker fileTracker;

  setUp(() {
    fileTracker = FileTracker();
  });

  test('dartHasTemplate', () {
    fileTracker.setDartHtmlTemplates("foo.dart", ["foo.html"]);
    expect(fileTracker.getHtmlPathsReferencedByDart("foo.dart"), equals(["foo.html"]));
  });

  test('dartHasTemplates', () {
    fileTracker.setDartHtmlTemplates("foo.dart", ["foo.html", "foo_bar.html"]);
    expect(fileTracker.getHtmlPathsReferencedByDart("foo.dart"), equals(["foo.html", "foo_bar.html"]));
  });

  test('htmlAffectingDart', () {
    fileTracker
      ..setDartHasTemplate("foo.dart", true)
      ..setDartImports("foo.dart", ["bar.dart"])
      ..setDartHtmlTemplates("bar.dart", ["bar.html"]);
    expect(fileTracker.getHtmlPathsAffectingDart("foo.dart"), equals(["bar.html"]));
  });

  test('htmlAffectingDartEmpty', () {
    expect(fileTracker.getHtmlPathsAffectingDart("foo.dart"), equals([]));
  });

  test('htmlAffectingDartEmptyNoImportedDart', () {
    fileTracker.setDartHtmlTemplates("foo.dart", ["foo.html"]);
    expect(fileTracker.getHtmlPathsAffectingDart("foo.dart"), equals([]));
  });

  test('htmlAffectingDartEmptyNotDartTemplate', () {
    fileTracker
      ..setDartImports("foo.dart", ["bar.dart"])
      ..setDartHtmlTemplates("bar.dart", ["bar.html"]);
    expect(fileTracker.getHtmlPathsAffectingDart("foo.dart"), equals([]));
  });

  test('htmlHasDart', () {
    fileTracker
      ..setDartHasTemplate("foo.dart", true)
      ..setDartImports("foo.dart", ["bar.dart"])
      ..setDartHtmlTemplates("bar.dart", ["bar.html"]);
    expect(fileTracker.getDartPathsAffectedByHtml("bar.html"), equals(["foo.dart"]));
  });

  test('htmlHasDartEmpty', () {
    expect(fileTracker.getDartPathsAffectedByHtml("foo.html"), equals([]));
  });

  test('htmlHasDartEmptyNoImportedDart', () {
    fileTracker.setDartHtmlTemplates("foo.dart", ["foo.html"]);
    expect(fileTracker.getDartPathsAffectedByHtml("foo.html"), equals([]));
  });

  test('htmlHasDartEmptyNotDartTemplate', () {
    fileTracker
      ..setDartImports("foo.dart", ["bar.dart"])
      ..setDartHtmlTemplates("bar.dart", ["bar.html"]);
    expect(fileTracker.getDartPathsAffectedByHtml("bar.html"), equals([]));
  });

  test('htmlHasDartMultiple', () {
    fileTracker
      ..setDartHasTemplate("foo.dart", true)
      ..setDartImports("foo.dart", ["bar.dart", "baz.dart"])
      ..setDartHtmlTemplates("bar.dart", ["bar.html", "bar_b.html"])
      ..setDartHtmlTemplates("baz.dart", ["baz.html", "baz_b.html"]);
    expect(fileTracker.getDartPathsAffectedByHtml("bar.html"), equals(["foo.dart"]));
    expect(fileTracker.getDartPathsAffectedByHtml("bar_b.html"), equals(["foo.dart"]));
    expect(fileTracker.getDartPathsAffectedByHtml("baz.html"), equals(["foo.dart"]));
    expect(fileTracker.getDartPathsAffectedByHtml("baz_b.html"), equals(["foo.dart"]));
  });

  test('htmlHasDartNotGrandchildren', () {
    fileTracker
      ..setDartHasTemplate("foo.dart", true)
      ..setDartImports("foo.dart", ["child.dart"])
      ..setDartHtmlTemplates("child.dart", ["child.html"])
      ..setDartImports("child.dart", ["grandchild.dart"])
      ..setDartHtmlTemplates("grandchild.dart", ["grandchild.html"]);
    expect(fileTracker.getDartPathsAffectedByHtml("child.html"), equals(["foo.dart"]));
    expect(fileTracker.getDartPathsAffectedByHtml("grandchild.html"), equals([]));
  });

  test('htmlHasHtml', () {
    fileTracker
      ..setDartHtmlTemplates("foo.dart", ["foo.html"])
      ..setDartImports("foo.dart", ["bar.dart"])
      ..setDartHtmlTemplates("bar.dart", ["bar.html"]);
    expect(fileTracker.getHtmlPathsReferencingHtml("bar.html"), equals(["foo.html"]));
  });

  test('htmlHasHtmlButNotGrandchildren', () {
    fileTracker
      ..setDartHtmlTemplates("foo.dart", ["foo.html"])
      ..setDartImports("foo.dart", ["child.dart"])
      ..setDartHtmlTemplates("child.dart", ["child.html"])
      ..setDartImports("child.dart", ["grandchild.dart"])
      ..setDartHtmlTemplates("grandchild.dart", ["grandchild.html"]);
    expect(fileTracker.getHtmlPathsReferencingHtml("child.html"), equals(["foo.html"]));
    expect(fileTracker.getHtmlPathsReferencingHtml("grandchild.html"), equals(["child.html"]));
  });

  test('htmlHasHtmlEmpty', () {
    expect(fileTracker.getHtmlPathsReferencingHtml("foo.html"), equals([]));
  });

  test('htmlHasHtmlEmptyNoHtml', () {
    fileTracker
      ..setDartHtmlTemplates("foo.dart", [])
      ..setDartImports("foo.dart", ["bar.dart"])
      ..setDartHtmlTemplates("bar.dart", ["bar.html"]);
    expect(fileTracker.getHtmlPathsReferencingHtml("bar.html"), equals([]));
  });

  test('htmlHasHtmlEmptyNoImportedDart', () {
    fileTracker.setDartHtmlTemplates("foo.dart", ["foo.html"]);
    expect(fileTracker.getHtmlPathsReferencingHtml("foo.html"), equals([]));
  });

  test('htmlHasHtmlMultipleResults', () {
    fileTracker
      ..setDartHtmlTemplates("foo.dart", ["foo.html", "foo_b.html"])
      ..setDartImports("foo.dart", ["bar.dart", "baz.dart"])
      ..setDartHtmlTemplates("bar.dart", ["bar.html"])
      ..setDartHtmlTemplates("baz.dart", ["baz.html", "baz_b.html"]);
    expect(fileTracker.getHtmlPathsReferencingHtml("bar.html"), equals(["foo.html", "foo_b.html"]));
    expect(fileTracker.getHtmlPathsReferencingHtml("baz.html"), equals(["foo.html", "foo_b.html"]));
    expect(fileTracker.getHtmlPathsReferencingHtml("baz_b.html"), equals(["foo.html", "foo_b.html"]));
  });

  test('notReferencedDart', () {
    expect(fileTracker.getDartPathsReferencingHtml("foo.html"), equals([]));
  });

  test('notReferencedHtml', () {
    expect(fileTracker.getDartPathsReferencingHtml("foo.dart"), equals([]));
  });

  test('templateHasDart', () {
    fileTracker.setDartHtmlTemplates("foo.dart", ["foo.html"]);
    expect(fileTracker.getDartPathsReferencingHtml("foo.html"), equals(["foo.dart"]));
  });

  test('templatesHaveDart', () {
    fileTracker
      ..setDartHtmlTemplates("foo.dart", ["foo.html"])
      ..setDartHtmlTemplates("foo_test.dart", ["foo.html"]);
    expect(fileTracker.getDartPathsReferencingHtml("foo.html"), equals(["foo.dart", "foo_test.dart"]));
  });

  test('templatesHaveDartComplex', () {
    fileTracker
      ..setDartHtmlTemplates("foo.dart", ["foo.html", "foo_b.html"])
      ..setDartHtmlTemplates("foo_test.dart", ["foo.html", "foo_b.html"])
      ..setDartHtmlTemplates("unrelated.dart", ["unrelated.html"]);
    expect(fileTracker.getDartPathsReferencingHtml("foo.html"), equals(["foo.dart", "foo_test.dart"]));
    expect(fileTracker.getDartPathsReferencingHtml("foo_b.html"), equals(["foo.dart", "foo_test.dart"]));

    fileTracker.setDartHtmlTemplates("foo_test.dart", ["foo_b.html"]);
    expect(fileTracker.getDartPathsReferencingHtml("foo.html"), equals(["foo.dart"]));
    expect(fileTracker.getDartPathsReferencingHtml("foo_b.html"), equals(["foo.dart", "foo_test.dart"]));

    fileTracker.setDartHtmlTemplates("foo_test.dart", ["foo.html"]);
    expect(fileTracker.getDartPathsReferencingHtml("foo.html"), equals(["foo.dart", "foo_test.dart"]));
    expect(fileTracker.getDartPathsReferencingHtml("foo_b.html"), equals(["foo.dart"]));

    fileTracker.setDartHtmlTemplates("foo_test.dart", ["foo.html", "foo_test.html"]);
    expect(fileTracker.getDartPathsReferencingHtml("foo.html"), equals(["foo.dart", "foo_test.dart"]));
    expect(fileTracker.getDartPathsReferencingHtml("foo_b.html"), equals(["foo.dart"]));
    expect(fileTracker.getDartPathsReferencingHtml("foo_test.html"), equals(["foo_test.dart"]));

    fileTracker
      ..setDartHtmlTemplates("foo.dart", ["foo.html"])
      ..setDartHtmlTemplates("foo_b.dart", ["foo_b.html"]);
    expect(fileTracker.getDartPathsReferencingHtml("foo.html"), equals(["foo.dart", "foo_test.dart"]));
    expect(fileTracker.getDartPathsReferencingHtml("foo_b.html"), equals(["foo_b.dart"]));
    expect(fileTracker.getDartPathsReferencingHtml("foo_test.html"), equals(["foo_test.dart"]));
  });

  test('templatesHaveDartRemove', () {
    fileTracker
      ..setDartHtmlTemplates("foo_test.dart", ["foo.html"])
      ..setDartHtmlTemplates("foo.dart", ["foo.html"])
      ..setDartHtmlTemplates("foo_test.dart", []);
    expect(fileTracker.getDartPathsReferencingHtml("foo.html"), equals(["foo.dart"]));
  });

  test('templatesHaveDartRepeated', () {
    fileTracker
      ..setDartHtmlTemplates("foo.dart", ["foo.html"])
      ..setDartHtmlTemplates("foo_test.dart", ["foo.html"])
      ..setDartHtmlTemplates("foo.dart", ["foo.html"]);
    expect(fileTracker.getDartPathsReferencingHtml("foo.html"), equals(["foo.dart", "foo_test.dart"]));
  });
}
