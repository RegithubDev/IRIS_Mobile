import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Utility/MySharedPreferences.dart';
import '../../../Utility/api_Url.dart';
import '../model/iris_home_model.dart';

ValueNotifier<String> userRoleValueNotifier = ValueNotifier<String>('');

class GetIRISHomeAPIService extends ChangeNotifier{
  Future<void> getIrisHomeApiCall(
      IRISHomeRequestModel irisHomeRequestModel) async {
    final prefs = await SharedPreferences.getInstance();
    String emailId = prefs.getString('email_id') ?? '';
    irisHomeRequestModel.emailId = emailId;
    Map<String, String> headers = {
      'Content-Type': 'application/json'
    };
    final response = await http.post(Uri.parse(GET_IRIS_HOME),
        body: jsonEncode(irisHomeRequestModel),
        headers: headers,
        encoding: Encoding.getByName("utf-8"));
    if (response.statusCode == 200 || response.statusCode == 400) {
      if(response.body.isNotEmpty) {
        MySharedPreferences.instance.setStringValue("IRIS_MOBILE_NO",
            json.decode(response.body)[0]["mobile_number"] ?? "");
        MySharedPreferences.instance.setStringValue(
            "IRIS_SBU_CODE", json.decode(response.body)[0]["sbu"] ?? "");
        MySharedPreferences.instance.setStringValue(
            "IRIS_SITE_ID", json.decode(response.body)[0]["site_id"] ?? "");
        MySharedPreferences.instance.setStringValue(
            "IRIS_SITE_NAME", json.decode(response.body)[0]["site_name"] ?? "");
        MySharedPreferences.instance.setStringValue("IRIS_LOCATION_NAME",
            json.decode(response.body)[0]["location_name"] ?? "");
        MySharedPreferences.instance.setStringValue(
            "IRIS_USER_ID", json.decode(response.body)[0]["id"] ?? "");
        MySharedPreferences.instance.setStringValue(
            "IRIS_ROLE_NAME", json.decode(response.body)[0]["role_name"] ?? "");
        userRoleValueNotifier.value =
            json.decode(response.body)[0]["roles"] ?? "";
        MySharedPreferences.instance.setStringValue(
            "IRIS_USER_NAME", json.decode(response.body)[0]["user_name"] ?? "");
        MySharedPreferences.instance.setStringValue(
            "IRIS_USER_ROLE", json.decode(response.body)[0]["roles"] ?? "");
        userRoleValueNotifier.notifyListeners();
      }else{
        userRoleValueNotifier.value = "";
      }
    }
  }
}
