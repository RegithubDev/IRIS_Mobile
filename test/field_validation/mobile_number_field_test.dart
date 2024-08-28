import 'package:flutter_test/flutter_test.dart';
import 'package:resus_test/Screens/profile/MobileNoFieldValidator.dart';


void main(){
  test('validate mobile number', () {
    final fieldValidator = MobileNoFieldValidator();
    var result = fieldValidator.validateMobileNo('');
    expect(result, 'Enter Mobile Number');
  });



}