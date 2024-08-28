import 'dart:math' as math;
import 'package:flutter/services.dart';  // Use the correct import for TextInputFormatter
import 'package:flutter/material.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({required this.decimalRange})
      : assert(decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    if (decimalRange != null) {
      String value = newValue.text;

      // Prevent multiple dots
      if (value.contains('.') && value.indexOf('.') != value.lastIndexOf('.')) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      }
      // Prevent more decimal places than allowed
      else if (value.contains(".") &&
          value.substring(value.indexOf(".") + 1).length > decimalRange) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      }
      // Add leading zero to a lone dot
      else if (value == ".") {
        truncated = "0.";
        newSelection = newValue.selection.copyWith(
          baseOffset: math.min(truncated.length, truncated.length + 1),
          extentOffset: math.min(truncated.length, truncated.length + 1),
        );
      }
      // Prevent negative values and commas
      else if (value.contains("-") || value.contains(",")) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      }
      // Ensure value does not exceed 9999
      else if (double.tryParse(value) != null && double.parse(value) >= 10000) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      }

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}
