class MobileNoFieldValidator {
  String validateMobileNo(String value) {
    if (value.isEmpty) {
      return 'Enter Mobile Number';
    }

    bool mobileNoValid = RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)').hasMatch(value);
    if (!mobileNoValid) {
      return 'Enter Valid Mobile Number';
    }
    return '';
  }
}
