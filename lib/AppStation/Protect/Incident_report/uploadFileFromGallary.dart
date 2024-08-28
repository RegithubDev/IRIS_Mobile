import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';

class uploadFile {
  FilePickerResult filePickerResult;

  uploadFile(this.filePickerResult);

  Future<String> fetchFile() async {
    if (filePickerResult == null) return "";
    if (lookupMimeType(filePickerResult.files.first.name.toString()) ==
            "image/jpeg" ||
        lookupMimeType(filePickerResult.files.first.name.toString()) ==
            "application/pdf" ||
        lookupMimeType(filePickerResult.files.first.name.toString()) ==
            "image/png") {
      File imgFile = File(filePickerResult.files.first.path.toString());
      return base64.encode(await imgFile.readAsBytes());
    } else {
      return "";
    }
  }

  Future<String> unitTestFileFormat() async {
    if (filePickerResult == null) return "";
    if (lookupMimeType(filePickerResult.files.first.name.toString()) ==
            "image/jpeg" ||
        lookupMimeType(filePickerResult.files.first.name.toString()) ==
            "application/pdf" ||
        lookupMimeType(filePickerResult.files.first.name.toString()) ==
            "image/png") {
      return (lookupMimeType(filePickerResult.files.first.name.toString()))
          .toString();
    } else {
      return "";
    }
  }
}
