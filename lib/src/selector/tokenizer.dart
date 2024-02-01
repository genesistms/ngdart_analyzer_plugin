import 'error.dart';
import 'regex.dart' as regex;

class Token {
  final TokenType type;
  final String lexeme;
  final int offset;
  final int endOffset;
  Token(
    this.type, {
    required this.lexeme,
    required this.offset,
    required this.endOffset,
  });
}

class Tokenizer {
  final int fileOffset;
  final String original;
  Tokenizer({
    required this.original,
    required this.fileOffset,
  }) : _matches = regex.tokenizer.allMatches(original).iterator;

  final Iterator<Match> _matches;
  Match? _currentMatch;

  Token? current;
  int lastOffset = 0;

  /// Get "foo" in ":contains(foo)" as a token when [current] is a [Contains].
  ///
  /// This token is special and does not get offset info.
  Token? get currentContainsString {
    assert(current?.type == TokenType.Contains);
    final lexeme = _currentMatch?[regex.subTokenContainsStr];
    if (lexeme == null) {
      return null;
    }
    return Token(TokenType.ContainsString, lexeme: lexeme, offset: -1, endOffset: -1);
  }

  /// Get "x" in "a=x" as a token when [current] is an [Attribute].
  ///
  /// This token is special and does not get offset info.
  Token? get currentValue {
    assert(current?.type == TokenType.Attribute);
    final lexeme = _currentMatch?[regex.subTokenUnquotedValue] ??
        _currentMatch?[regex.subTokenDoubleQuotedValue] ??
        _currentMatch?[regex.subTokenSingleQuotedValue];
    if (lexeme == null) {
      return null;
    }
    return Token(TokenType.Value, lexeme: lexeme, offset: -1, endOffset: -1);
  }

  /// Get "=" in "a=x" as a token when [current] is an [Attribute].
  ///
  /// This token is special and does not get offset info.
  Token? get currentOperator {
    assert(current?.type == TokenType.Attribute);
    final lexeme = _currentMatch?[regex.subTokenOperator];
    if (lexeme == null) {
      return null;
    }
    return Token(TokenType.Operator, lexeme: lexeme, offset: -1, endOffset: -1);
  }

  FormatException? advance() {
    if (!_matches.moveNext()) {
      _currentMatch = null;
      current = null;
      return null;
    }

    _currentMatch = _matches.current;

    final currentMatch = _currentMatch;
    if (currentMatch == null) {
      return null;
    }

    // no content should be skipped
    final skipStr = original.substring(lastOffset, currentMatch.start);
    if (!_isBlank(skipStr)) {
      return SelectorParseError('Unexpected $skipStr', original, lastOffset + fileOffset, skipStr.length);
    }
    lastOffset = currentMatch.end;

    for (final index in regex.matchIndexToToken.keys) {
      final currentGroup = currentMatch.group(index);
      final matchIndexToken = regex.matchIndexToToken[index];
      if (currentGroup != null && matchIndexToken != null) {
        current = Token(
          matchIndexToken,
          lexeme: currentGroup,
          offset: fileOffset + currentMatch.start,
          endOffset: fileOffset + currentMatch.end,
        );
        return null;
      }
    }

    current = null;
    return null;
  }

  /// Checks if [str] is `null`, empty or is whitespace.
  bool _isBlank(String? str) => (str ?? '').trim().isEmpty;
}

/// Various types of tokens that may be tokenized.
enum TokenType {
  NotStart, // :not(
  NotEnd, // )
  Attribute, // x=y
  Tag, // tag-name
  Comma, // ,
  Class, // .class
  Contains, // :contains(...)
  ContainsString, // :contains(string)
  Value, // x=value
  Operator, // =, ^=, etc.
}
