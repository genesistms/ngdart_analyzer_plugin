import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  test('template:', () {
    final (component, errors) = singleComponentParse(
      '''
      @Component(
        template: '<div></div>',
      )
      class Component {}
      ''',
    );

    expect(errors, isEmpty);
    expect(component.templateUrl, isNull);
    expect(component.template, isNotNull);
    // spaces added because text is offsetted
    expect(component.template?.value, ' <div></div> ');
  });

  test('templateUrl:', () {
    final (component, errors) = singleComponentParse(
      '''
      @Component(
        templateUrl: 'component.html',
      )
      class Component {}
      ''',
    );

    expect(errors, isEmpty);
    expect(component.template, isNull);
    expect(component.templateUrl, isNotNull);
    expect(component.templateUrl?.value, 'component.html');
  });
}
