import 'package:analyzer/src/generated/source.dart';

import 'and_selector.dart';
import 'attribute_contains_selector.dart';
import 'attribute_selector.dart';
import 'attribute_starts_with_selector.dart';
import 'attribute_value_regex_selector.dart';
import 'class_selector.dart';
import 'contains_selector.dart';
import 'element_name_selector.dart';
import 'error.dart';
import 'name.dart';
import 'not_selector.dart';
import 'or_selector.dart';
import 'selector.dart';
import 'tokenizer.dart';

class Parser {
  final Tokenizer tokenizer;
  final int fileOffset;
  final String original;
  final Source source;
  Parser({
    required this.original,
    required this.source,
    this.fileOffset = 0,
  }) : tokenizer = Tokenizer(
          original: original,
          fileOffset: fileOffset,
        );

  int lastOffset = 0;

  Selector parse() {
    final err = tokenizer.advance();
    if (err != null) {
      throw err;
    }

    final selector = _parseNested();

    final current = tokenizer.current;
    if (current != null) {
      throw SelectorParseError('Unexpected ${current.lexeme}', original, current.offset, current.lexeme.length);
    }

    return selector;
  }

  Selector _parseNested() {
    final selectors = <Selector>[];
    var current = tokenizer.current;
    while (current != null) {
      if (current.type == TokenType.NotEnd) {
        // don't advance, just know we're at the end of this.
        break;
      }

      if (current.type == TokenType.Comma) {
        // [selectors] is the lhs of the OR. [_parseOrSelector] will parse the
        // rhs, so return its result without continuing the loop.
        return _parseOrSelector(selectors);
      } else if (current.type == TokenType.NotStart) {
        selectors.add(_parseNotSelector());
      } else if (current.type == TokenType.Tag) {
        selectors.add(_parseElementNameSelector());
      } else if (current.type == TokenType.Class) {
        selectors.add(_parseClassSelector());
      } else if (current.type == TokenType.Attribute) {
        selectors.add(_parseAttributeSelector());
      } else if (current.type == TokenType.Contains) {
        selectors.add(_parseContainsSelector());
      } else {
        break;
      }

      current = tokenizer.current;
    }

    // final result
    return _andSelectors(selectors);
  }

  Selector _andSelectors(List<Selector> selectors) {
    if (selectors.length == 1) {
      return selectors.single;
    }
    return AndSelector(selectors);
  }

  Selector _parseAttributeSelector() {
    final current = tokenizer.current;
    if (current == null) {
      throw SelectorParseError('Unexpected end', original, lastOffset, 0);
    }

    final nameOffset = current.offset + '['.length;

    final operator = tokenizer.currentOperator;
    final value = tokenizer.currentValue;
    if (operator != null && value != null && value.lexeme.isEmpty) {
      throw SelectorParseError(
          'Expected a value after ${operator.lexeme}, got ]', original, current.endOffset - 1, ']'.length);
    }

    final name = current.lexeme;
    tokenizer.advance();

    return _tryParseAttributeValueRegexSelector(name, nameOffset, operator?.lexeme, value) ??
        _tryParseAttributeContainsSelector(name, nameOffset, operator?.lexeme, value) ??
        _tryParseAttributeStartsWithSelector(name, nameOffset, operator?.lexeme, value) ??
        AttributeSelector(
          SelectorName(name, navigationRange: SourceRange(nameOffset, name.length), source: source),
          value?.lexeme,
        );
  }

  AttributeValueRegexSelector? _tryParseAttributeValueRegexSelector(
    String name,
    int nameOffset,
    String? operator,
    Token? value,
  ) {
    if (operator == null ||
        name != '*' ||
        value == null ||
        !value.lexeme.startsWith('/') ||
        !value.lexeme.endsWith('/')) {
      return null;
    }

    if (operator != '=') {
      throw SelectorParseError(
        'Unexpected $operator',
        operator,
        nameOffset + name.length,
        operator.length,
      );
    }

    final valueOffset = nameOffset + name.length + '='.length;
    final regex = value.lexeme.substring(1, value.lexeme.length - 1);
    return AttributeValueRegexSelector(
      SelectorName(regex, navigationRange: SourceRange(valueOffset, regex.length), source: source),
    );
  }

  AttributeContainsSelector? _tryParseAttributeContainsSelector(
    String originalName,
    int nameOffset,
    String? operator,
    Token? value,
  ) {
    if (value == null) {
      return null;
    }

    if (operator == '*=') {
      final name = originalName.replaceAll('*', '');
      return AttributeContainsSelector(
        SelectorName(name, navigationRange: SourceRange(nameOffset, name.length), source: source),
        value.lexeme,
      );
    }

    return null;
  }

  AttributeStartsWithSelector? _tryParseAttributeStartsWithSelector(
    String name,
    int nameOffset,
    String? operator,
    Token? value,
  ) {
    if (value == null) {
      return null;
    }

    if (operator == '^=') {
      return AttributeStartsWithSelector(
        SelectorName(name, navigationRange: SourceRange(nameOffset, name.length), source: source),
        value.lexeme,
      );
    }

    return null;
  }

  ContainsSelector _parseContainsSelector() {
    final containsString = tokenizer.currentContainsString?.lexeme;
    if (containsString == null) {
      throw SelectorParseError('Unexpected end', original, lastOffset, 0);
    }

    tokenizer.advance();
    return ContainsSelector(containsString);
  }

  ClassSelector _parseClassSelector() {
    final current = tokenizer.current;
    if (current == null) {
      throw SelectorParseError('Unexpected end', original, lastOffset, 0);
    }

    final nameOffset = current.offset + 1;
    final name = current.lexeme;
    tokenizer.advance();
    return ClassSelector(
      SelectorName(
        name,
        navigationRange: SourceRange(nameOffset, name.length),
        source: source,
      ),
    );
  }

  ElementNameSelector _parseElementNameSelector() {
    final current = tokenizer.current;
    if (current == null) {
      throw SelectorParseError('Unexpected end', original, lastOffset, 0);
    }

    final nameOffset = current.offset;
    final name = current.lexeme;
    tokenizer.advance();
    return ElementNameSelector(
      SelectorName(
        name,
        navigationRange: SourceRange(nameOffset, name.length),
        source: source,
      ),
    );
  }

  NotSelector _parseNotSelector() {
    tokenizer.advance();
    final condition = _parseNested();

    final current = tokenizer.current;
    if (current == null) {
      throw SelectorParseError('Unexpected end', original, lastOffset, 0);
    }

    if (current.type != TokenType.NotEnd) {
      throw SelectorParseError(
        'Unexpected ${current.lexeme}',
        original,
        current.offset,
        current.lexeme.length,
      );
    }

    tokenizer.advance();
    return NotSelector(condition);
  }

  OrSelector _parseOrSelector(List<Selector> selectors) {
    tokenizer.advance();
    final rhs = _parseNested();
    if (rhs is OrSelector) {
      // flatten "a, b, c, d" from (a, (b, (c, d))) into (a, b, c, d)
      return OrSelector(<Selector>[_andSelectors(selectors)]..addAll(rhs.selectors));
    }

    return OrSelector(<Selector>[_andSelectors(selectors), rhs]);
  }
}
