import 'name.dart';
import 'selector.dart';

/// The element name based selector.
class ElementNameSelector extends Selector {
  final SelectorName nameElement;

  ElementNameSelector(this.nameElement);

  @override
  String toString() => nameElement.string;
}
