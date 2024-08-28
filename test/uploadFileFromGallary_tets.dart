 import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resus_test/AppStation/Protect/Incident_report/uploadFileFromGallary.dart';

Future<void> main() async {

  test('For testing invalid file or not', () async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    uploadFile gh =uploadFile(result!);
    String value=await gh.unitTestFileFormat();

    expect( value,"application/pdf");
  });
}