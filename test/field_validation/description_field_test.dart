import 'package:flutter_test/flutter_test.dart';
import 'package:resus_test/AppStation/Protect/DescriptionFieldValidator.dart';


void main(){
  group("Test Description field", () {
    test('validate description null check', () {
      final fieldValidator = DescriptionFieldValidator();
      var result = fieldValidator.validateDescriptionNullCheck('');
      expect(result, 'Enter Description');
    });

    test('validate description format check', () {
      final fieldValidator = DescriptionFieldValidator();
      var result = fieldValidator.validateDescriptionFormat('example2@gmail.com');
      expect(result, '');
    });

  });
}