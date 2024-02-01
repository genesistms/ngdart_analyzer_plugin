import 'name.dart';
import 'selector.dart';

/// The [Selector] that matches elements that have an attribute with the
/// given name, and (optionally) with the given value;
class AttributeSelector implements Selector {
  final SelectorName nameElement;
  final String? value;

  AttributeSelector(this.nameElement, this.value);

  @override
  String toString() {
    final name = nameElement.string;
    if (value != null) {
      return '[$name=$value]';
    }
    return '[$name]';
  }
}
