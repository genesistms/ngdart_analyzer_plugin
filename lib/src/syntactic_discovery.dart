import 'package:analyzer/dart/ast/ast.dart' as ast;
import 'package:analyzer/src/dart/ast/utilities.dart' as ast;
import 'package:analyzer/source/source_range.dart';
import 'package:collection/collection.dart';
import 'package:ngdart_analyzer_plugin/src/syntactic/component.dart' as syntactic;

import 'offsetting_constant_evaluator.dart';

List<syntactic.Component> findComponents(ast.CompilationUnit unit) {
  return unit.declarations.whereType<ast.ClassDeclaration>().map(findComponent).whereNotNull().toList();
}

syntactic.Component? findComponent(ast.ClassDeclaration declaration) {
  final annotation = declaration.metadata.firstWhereOrNull((m) => m.name.name == 'Component');
  if (annotation == null) {
    return null;
  }

  final template = findTemplate(annotation);
  final (templateUrl, _) = findTemplateUrl(annotation);

  return syntactic.Component(
    template: template,
    templateUrl: templateUrl,
  );
}

syntactic.Template? findTemplate(ast.Annotation annotation) {
  final expression = findNamedArgument(annotation, 'template');
  if (expression == null) {
    return null;
  }

  final evaluator = OffsettingConstantEvaluator();
  evaluator.value = expression.accept(evaluator);
  if (!evaluator.offsetsAreValid || evaluator.value is! String) {
    return null;
  }

  return syntactic.Template(
    evaluator.value as String,
    SourceRange(expression.offset, expression.length),
  );
}

(syntactic.TemplateUrl?, String?) findTemplateUrl(ast.Annotation annotation) {
  final expression = findNamedArgument(annotation, 'templateUrl');
  if (expression == null) {
    return (null, null);
  }

  final evaluator = ast.ConstantEvaluator();
  final text = expression.accept(evaluator);
  if (text is! String) {
    return (null, 'string expected');
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
