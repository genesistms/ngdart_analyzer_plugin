import 'name.dart';
import 'selector.dart';

/// The [Selector] that matches elements that have an attribute with any name,
/// and with contents that match the given regex.
class AttributeStartsWithSelector implements Selector {
  final SelectorName nameElement;

  final String value;

  AttributeStartsWithSelector(this.nameElement, this.value);

  @override
  String toString() => '[$nameElement^=$value]';
}
