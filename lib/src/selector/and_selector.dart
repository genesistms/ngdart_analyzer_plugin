import 'selector.dart';

/// The [Selector] that matches all of the given [selectors].
class AndSelector extends Selector {
  final List<Selector> selectors;

  AndSelector(this.selectors);

  @override
  String toString() => selectors.join(' && ');
}
