import 'package:intl/intl.dart';

String getTime(String? inputString) {
  if (inputString == null || inputString.isEmpty) {
    return '';
  } else {
    var inputFormat = DateFormat('dd-MMM-yy  hh:mm');
    var date1 = inputFormat.parse(inputString);

    var outputFormat = DateFormat('dd-MM-yyyy');
    return outputFormat.format(date1);
  }
}
