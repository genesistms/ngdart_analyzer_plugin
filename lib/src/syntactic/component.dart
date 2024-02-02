import 'package:analyzer/source/source_range.dart';
import 'package:ngdart_analyzer_plugin/src/selector/selector.dart';

/// Syntactic model of an Angular component.
///
/// A component is a directive with a template, which also has additional
/// information used to render and interact with that template.
///
/// ```dart
/// @Component(
///   selector: 'my-selector', // required
///   exportAs: 'foo', // optional
///   directives: [SubDirectiveA, SubDirectiveB], // optional
///   pipes: [PipeA, PipeB], // optional
///   exports: [foo, bar], // optional
///
///   // Template required. May be an inline body or a URL
///   template: '...', // or
///   templateUrl: '...',
/// )
/// class MyComponent { // must be a class
///   @Input() input; // may have inputs
///   @Output() output; // may have outputs
///
///   // may have content child(ren).
///   @ContentChild(...) child;
///   @ContentChildren(...) children;
///
///   MyComponent(
///     @Attribute() String attr, // may have attributes
///   );
/// }
/// ```
///
/// Note that the syntactic model of a component only includes its inline
/// [NgContent]s. See [ngContent]/README.md for more information.
class Component {
  final Selector? selector;
  final Template? template;
  final TemplateUrl? templateUrl;
  Component({
    this.selector,
    this.template,
    this.templateUrl,
  });
}

class Template {
  final String value;
  final SourceRange range;
  Template(this.value, this.range);
}

class TemplateUrl {
  final String value;
  final SourceRange range;
  TemplateUrl(this.value, this.range);
}
