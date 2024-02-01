import 'name.dart';
import 'selector.dart';

/// The [AttributeContainsSelector] that matches elements that have attributes
/// with the given name, and that attribute contains the value of the selector.
class AttributeContainsSelector implements Selector {
  final SelectorName nameElement;
  final String value;

  AttributeContainsSelector(this.nameElement, this.value);

  @override
  String toString() {
    final name = nameElement.string;
    return '[$name*=$value]';
  }
}
