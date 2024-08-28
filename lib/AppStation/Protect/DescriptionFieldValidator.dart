class DescriptionFieldValidator {
  String validateDescriptionNullCheck(String value) {
    if (value.isEmpty) {
      return 'Enter Description';
    }

    bool descriptionValid = RegExp(r"^[a-zA-Z0-9_ ]+").hasMatch(value);
    if (!descriptionValid) {
      return 'Enter Valid Email';
    }
    return '';
  }

  String validateDescriptionFormat(String value) {
    bool isFormat = RegExp(r"^[a-zA-Z0-9_ ]+").hasMatch(value);
    if (!isFormat) {
      return 'Email format Wrong';
    }
    return '';
  }
}
