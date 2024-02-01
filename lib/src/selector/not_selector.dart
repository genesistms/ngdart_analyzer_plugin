import 'selector.dart';

/// The [Selector] that confirms the inner [Selector] condition does NOT match.
class NotSelector extends Selector {
  final Selector condition;

  NotSelector(this.condition);

  @override
  String toString() => ":not($condition)";
}
