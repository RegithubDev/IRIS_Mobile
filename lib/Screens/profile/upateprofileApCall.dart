import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../Utility/api_Url.dart';
import '../../Utility/MySharedPreferences.dart';

class UpdateProfileApi {
  String m_sessionId;
  String m_requestBody;

  UpdateProfileApi(this.m_sessionId, this.m_requestBody);

  Future<Response?> calUpdateProfileAPi() async {
    var dio = Dio();
    try {
      var response = await dio.post(UPDATE_PROFILE,
          data: m_requestBody,
          options: Options(
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json',
              'Cookie': m_sessionId
            },
          ));
      return response;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

  saveDataToSharedPreference(Response? response) {
    if (response.toString() == "Updating User is failed. Try again.") {
      return;
    }
    if (response!.data["Project"] == null) {
      response!.data["Project"] = '';
    }
    if (response!.data["DEPARTMENT_NAME"] == null) {
      response!.data["DEPARTMENT_NAME"] = '';
    }
    if (response!.data["SBU_NAME"] == null) {
      response!.data["SBU_NAME"] = '';
    }
    if (response!.data["REPORTING_TO_NAME"] == null) {
      response!.data["REPORTING_TO_NAME"] = '';
    }
    if (response!.data["SBU"] == null) {
      response!.data["SBU"] = '';
    }
    if (response!.data["PROJECT_CODE"] == null) {
      response!.data["PROJECT_CODE"] = '';
    }
    if (response!.data["DEPARTMENT"] == null) {
      response!.data["DEPARTMENT"] = '';
    }
    if (response!.data["REPORTING_TO"] == null) {
      response!.data["REPORTING_TO"] = '';
    }
    MySharedPreferences.instance
        .setStringValue("SBU_NAME", response!.data["SBU_NAME"]);
    MySharedPreferences.instance
        .setStringValue("Project", response!.data["Project"]);
    MySharedPreferences.instance
        .setStringValue("DEPARTMENT_NAME", response!.data["DEPARTMENT_NAME"]);
    MySharedPreferences.instance.setStringValue(
        "REPORTING_TO_NAME", response!.data["REPORTING_TO_NAME"]);
    MySharedPreferences.instance.setStringValue("SBU", response!.data["SBU"]);
    MySharedPreferences.instance
        .setStringValue("PROJECT_CODE", response!.data["PROJECT_CODE"]);
    MySharedPreferences.instance
        .setStringValue("DEPARTMENT", response!.data["DEPARTMENT"]);
    MySharedPreferences.instance
        .setStringValue("REPORTING_TO", response!.data["REPORTING_TO"]);
  }
}
