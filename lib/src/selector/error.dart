/// A type of [FormatException] specific to errors parsing [Selector]s.
class SelectorParseError extends FormatException {
  int length;
  int offset;
  SelectorParseError(String message, String source, this.offset, this.length) : super(message, source, offset);
}
