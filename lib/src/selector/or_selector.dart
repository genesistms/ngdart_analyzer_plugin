import 'selector.dart';

/// The [Selector] that matches one of the given [selectors].
class OrSelector extends Selector {
  final List<Selector> selectors;

  OrSelector(this.selectors);

  @override
  String toString() => selectors.join(' || ');
}
