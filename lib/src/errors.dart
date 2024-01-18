import 'package:analyzer/source/source_range.dart';

enum AngularWarningCode {
  /// An error for when the provided selector cannot be parsed.
  cannotParseSelector('Cannot parse the given selector ({0})'),

  /// An error for when a template points to a missing html file.
  referencedHtmlFileDoesntExist('The referenced HTML file doesn\'t exist'),

  /// An error for when a @Component has both a template and a templateUrl
  /// defined at once.
  templateUrlAndTemplateDefined('Cannot define both template and templateUrl. Remove one'),

  /// An error for when a @Component does not have a template or a templateUrl.
  noTemplateUrlOrTemplateDefined('Either a template or templateUrl is required'),
  ;

  final String message;

  const AngularWarningCode(this.message);
}

class AngularWarning {
  final AngularWarningCode code;
  final SourceRange range;
  AngularWarning({
    required this.code,
    required this.range,
  });
}
