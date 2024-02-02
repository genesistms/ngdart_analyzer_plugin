import 'package:analyzer/dart/ast/ast.dart' as ast;
import 'package:analyzer/src/dart/ast/utilities.dart' as ast;
import 'package:analyzer/src/generated/source.dart';
import 'package:collection/collection.dart';
import 'package:ngdart_analyzer_plugin/src/errors.dart';
import 'package:ngdart_analyzer_plugin/src/syntactic/component.dart' as syntactic;

import 'offsetting_constant_evaluator.dart';
import 'selector/error.dart';
import 'selector/parser.dart' as selector;
import 'selector/selector.dart';

Iterable<(syntactic.Component, List<AngularWarning>?)> findComponents(ast.CompilationUnit unit) sync* {
  final components = unit.declarations.whereType<ast.ClassDeclaration>().map(findComponent);
  for (final (component, errors) in components) {
    if (component == null) {
      continue;
    }

    yield (component, errors);
  }
}

(syntactic.Component?, List<AngularWarning>?) findComponent(ast.ClassDeclaration declaration) {
  final annotation = declaration.metadata.firstWhereOrNull((m) => m.name.name == 'Component');
  if (annotation == null) {
    return (null, null);
  }

  final errors = <AngularWarning>[];

  final (selector, selectorErrors) = findSelector(annotation);
  if (selectorErrors != null) {
    errors.addAll(selectorErrors);
  }

  final (template, templateErrors) = findTemplate(annotation);
  if (templateErrors != null) {
    errors.addAll(templateErrors);
  }

  final (templateUrl, templateUrlErrors) = findTemplateUrl(annotation);
  if (templateUrlErrors != null) {
    errors.addAll(templateUrlErrors);
  }

  if (template != null && templateUrl != null) {
    errors.addAll([
      AngularWarning(
        code: AngularWarningCode.templateUrlAndTemplateDefined,
        range: template.range,
      ),
      AngularWarning(
        code: AngularWarningCode.templateUrlAndTemplateDefined,
        range: templateUrl.range,
      ),
    ]);
  }

  if (template == null && templateUrl == null) {
    errors.add(
      AngularWarning(
        code: AngularWarningCode.noTemplateUrlOrTemplateDefined,
        range: SourceRange(annotation.offset, annotation.length),
      ),
    );
  }

  return (
    syntactic.Component(
      selector: selector,
      template: template,
      templateUrl: templateUrl,
    ),
    errors
  );
}

(Selector?, List<AngularWarning>?) findSelector(ast.Annotation annotation) {
  final expression = findNamedArgument(annotation, 'selector');
  if (expression == null) {
    return (null, null);
  }

  final evaluator = OffsettingConstantEvaluator();
  evaluator.value = expression.accept(evaluator);
  if (!evaluator.offsetsAreValid || evaluator.value is! String) {
    return (null, null);
  }

  try {
    final s = selector.Parser(
      original: evaluator.value as String,
      fileOffset: expression.offset,
      source: NonExistingSource.unknown,
    ).parse();
    return (s, null);
  } on SelectorParseError catch (e) {
    return (
      null,
      [
        AngularWarning(
          code: AngularWarningCode.cannotParseSelector,
          range: SourceRange(e.offset, e.length),
          arguments: [e.message],
        )
      ],
    );
  } on FormatException catch (_) {
    return (
      null,
      [
        AngularWarning(
          code: AngularWarningCode.cannotParseSelector,
          range: SourceRange(expression.offset, expression.length),
          arguments: [evaluator.value as String],
        )
      ],
    );
  }
}

(syntactic.Template?, List<AngularWarning>?) findTemplate(ast.Annotation annotation) {
  final expression = findNamedArgument(annotation, 'template');
  if (expression == null) {
    return (null, null);
  }

  final evaluator = OffsettingConstantEvaluator();
  evaluator.value = expression.accept(evaluator);
  if (!evaluator.offsetsAreValid || evaluator.value is! String) {
    return (null, null);
  }

  return (
    syntactic.Template(
      evaluator.value as String,
      SourceRange(expression.offset, expression.length),
    ),
    null
  );
}

(syntactic.TemplateUrl?, List<AngularWarning>?) findTemplateUrl(ast.Annotation annotation) {
  final expression = findNamedArgument(annotation, 'templateUrl');
  if (expression == null) {
    return (null, null);
  }

  final evaluator = ast.ConstantEvaluator();
  final text = expression.accept(evaluator);
  if (text is! String) {
    return (null, null);
  }

  return (
    syntactic.TemplateUrl(
      text,
      SourceRange(expression.offset, expression.length),
    ),
    null,
  );
}

ast.Expression? findNamedArgument(ast.Annotation node, String name) {
  if (node.arguments == null) {
    return null;
  }

  final arguments = node.arguments?.arguments;
  if (arguments == null) {
    return null;
  }

  for (final argument in arguments) {
    if (argument is ast.NamedExpression && argument.name.label.name == name) {
      return argument.expression;
    }
  }

  return null;
}
