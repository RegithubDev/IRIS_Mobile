import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Utility/api_Url.dart';
import '../model/iris_profile_model.dart';


class IrisUpdateProfileAPIService {
  Future<String> updateProfileApiCall(IRISProfileRequestModel irisProfileRequestModel) async {
    final prefs = await SharedPreferences.getInstance();
    String sessionId = prefs.getString('session_id') ?? '2020-05-26 10:00:00';
    irisProfileRequestModel.userId=prefs.getInt('IRIS_USER_ID') ?? 0;

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      HttpHeaders.cookieHeader: sessionId,
    };
    final response = await http.post(Uri.parse(IRIS_UPDATE_PROFILE),
        body: jsonEncode(irisProfileRequestModel),
        headers: headers,
        encoding: Encoding.getByName("utf-8"));
    if (response.statusCode == 200 || response.statusCode == 400) {
      return response.body;
    } else {
      return response.body;
    }
  }
}
