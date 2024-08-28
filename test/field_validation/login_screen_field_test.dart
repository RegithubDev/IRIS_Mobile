import 'package:flutter_test/flutter_test.dart';
import 'package:resus_test/Screens/login/FieldValidator.dart';


void main(){
  test('validate email id', () {
    final fieldValidator = FieldValidator();
    var result = fieldValidator.validateEmail('');
    expect(result, 'Enter Email');
  });

}
