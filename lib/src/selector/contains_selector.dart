import 'selector.dart';

/// The [Selector] that checks a TextNode for contents by a regex.
class ContainsSelector extends Selector {
  final String regex;

  ContainsSelector(this.regex);

  @override
  String toString() => ":contains($regex)";
}
