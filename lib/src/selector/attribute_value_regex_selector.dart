import 'name.dart';
import 'selector.dart';

/// The [Selector] that matches any attributes contents against the given regex.
class AttributeValueRegexSelector extends Selector {
  final SelectorName regexpElement;
  final RegExp regexp;

  AttributeValueRegexSelector(this.regexpElement) : regexp = RegExp(regexpElement.string);

  @override
  String toString() => '[*=${regexpElement.string}]';
}
