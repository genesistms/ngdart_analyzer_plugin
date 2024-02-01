/// A type of [FormatException] specific to errors parsing [Selector]s.
class SelectorParseError extends FormatException {
  int length;
  SelectorParseError(String message, String source, int offset, this.length) : super(message, source, offset);
}
