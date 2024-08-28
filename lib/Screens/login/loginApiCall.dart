import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:resus_test/Utility/shared_preferences_string.dart';

import '../../../Utility/api_Url.dart';
import '../../Utility/MySharedPreferences.dart';
import '../../custom_sharedPreference.dart';

class LoginApiCall {
  final String _userAgent = '<unknown>';
  String mEmailId;
  String mdeviceType;
  String mdeviceTypeNo;
  String mversionNo;

  LoginApiCall(
      this.mEmailId, this.mdeviceType, this.mdeviceTypeNo, this.mversionNo);

  Future<Response?> callLoginAPi() async {
    var dio = Dio();
    try {
      var response = await dio.post(LOGIN,
          data: {
            "email_id": mEmailId,
            "device_type": mdeviceType,
            "device_type_no": "1",
            "version_number": mversionNo,
          },
          options: Options(
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json',
              HttpHeaders.userAgentHeader: _userAgent
            },
          ));
      return response;
    } catch (e) {
      if (kDebugMode) {}
    }
    return null;
  }

  Future<String> userLogin(String emailId, String deviceType,
      String deviceTypeNo, String versionNo) async {
    LoginApiCall loginApiCall =
        LoginApiCall(emailId, deviceType, deviceTypeNo, versionNo);
    var response = await loginApiCall.callLoginAPi();
    debugPrint("response: $response");
    if (response?.statusCode == 200) {
      try {
        if (response!.data["contact_number"] == null) {
          response.data["contact_number"] = "";
        }
        if (response.data["user_id"] == null) {
          response.data["user_id"] = "";
        }
        if (response.data["email_id"] == null) {
          response.data["email_id"] = "";
        }
        if (response.data["project_name"] == null) {
          response.data["project_name"] = "";
        }
        if (response.data["module_type"] == null) {
          response.data["module_type"] = "";
        }
        if (response.data["base_sbu"] == null) {
          response.data["base_sbu"] = "";
        }
        if (response.data["base_project"] == null) {
          response.data["base_project"] = "";
        }
        if (response.data["base_role"] == null) {
          response.data["base_role"] = "";
        }
        if (response.data["message"] == null) {
          response.data["message"] = "";
        }
        if (response.data["sbu_name"] == null) {
          response.data["sbu_name"] = "";
        }
        if (response.data["reward_points"] == null) {
          response.data["reward_points"] = "";
        }
        if (response.data["base_department"] == null) {
          response.data["base_department"] = "";
        }
        if (response.data["reporting_to"] == null) {
          response.data["reporting_to"] = "";
        }
        if (response.data["reporting_user_name"] == null) {
          response.data["reporting_user_name"] = "";
        }
        if (response.data["department_name"] == null) {
          response.data["department_name"] = "";
        }

        String? session = response.headers['set-cookie']
            .toString()
            .split(";")[0]
            .replaceAll('[', '');
        MySharedPreferences.instance.setStringValue("JSESSIONID", session);

        CustomSharedPref.setPref<String>(
            SharedPreferencesString.sessionId, session);
        MySharedPreferences.instance
            .setStringValue("IRIS_CREATED_BY", response.data["id"]);
        MySharedPreferences.instance
            .setStringValue("user_id", response.data["user_id"]);
        MySharedPreferences.instance
            .setStringValue("user_name", response.data["user_name"]);
        MySharedPreferences.instance
            .setStringValue("email_id", response.data["email_id"]);
        MySharedPreferences.instance
            .setStringValue("Project", response.data["project_name"]);
        MySharedPreferences.instance
            .setStringValue("module_type", response.data["module_type"]);
        MySharedPreferences.instance
            .setStringValue("SBU", response.data["base_sbu"]);
        MySharedPreferences.instance
            .setStringValue("PROJECT_CODE", response.data["base_project"]);
        MySharedPreferences.instance
            .setStringValue("base_role", response.data["base_role"]);
        MySharedPreferences.instance
            .setStringValue("message", response.data["message"]);
        MySharedPreferences.instance
            .setStringValue("SBU_NAME", response.data["sbu_name"]);
        MySharedPreferences.instance
            .setStringValue("reward_points", response.data["reward_points"]);
        MySharedPreferences.instance
            .setStringValue("DEPARTMENT", response.data["base_department"]);
        MySharedPreferences.instance
            .setStringValue("contact_number", response.data["contact_number"]);
        MySharedPreferences.instance
            .setStringValue("REPORTING_TO", response.data["reporting_to"]);
        MySharedPreferences.instance.setStringValue(
            "REPORTING_TO_NAME", response.data["reporting_user_name"]);
        MySharedPreferences.instance.setStringValue(
            "DEPARTMENT_NAME", response.data["department_name"]);

        return response.data["user_id"];
      } catch (e) {
        return "";
      }
    } else {
      return "";
    }
  }
}
