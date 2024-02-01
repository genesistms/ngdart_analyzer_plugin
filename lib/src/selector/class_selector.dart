import 'name.dart';
import 'selector.dart';

/// The [Selector] that matches elements with the given (static) classes.
class ClassSelector extends Selector {
  final SelectorName nameElement;

  ClassSelector(this.nameElement);

  @override
  String toString() => '.${nameElement.string}';
}
