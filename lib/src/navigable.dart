import 'package:analyzer/src/generated/source.dart';

abstract class Navigable {
  SourceRange get navigationRange;
  Source get source;
}

class NavigableString implements Navigable {
  final String string;

  @override
  final SourceRange navigationRange;

  @override
  final Source source;

  NavigableString(
    this.string, {
    required this.navigationRange,
    required this.source,
  });

  @override
  int get hashCode => Object.hash(string, navigationRange.hashCode, source.hashCode);

  @override
  bool operator ==(Object other) =>
      other is NavigableString &&
      other.string == string &&
      other.navigationRange == navigationRange &&
      other.source == source;
}
