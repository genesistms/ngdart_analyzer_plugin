import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  test('template:', () {
    final component = singleComponentParse(
      '''
      @Component(
        template: '<div></div>',
      )
      class Component {}
      ''',
    );

    expect(component.templateUrl, isNull);
    expect(component.template, isNotNull);
    // spaces added because text is offsetted
    expect(component.template?.value, ' <div></div> ');
  });

  test('templateUrl:', () {
    final component = singleComponentParse(
      '''
      @Component(
        templateUrl: 'component.html',
      )
      class Component {}
      ''',
    );

    expect(component.template, isNull);
    expect(component.templateUrl, isNotNull);
    expect(component.templateUrl?.value, 'component.html');
  });
}
