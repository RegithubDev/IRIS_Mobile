import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:resus_test/AppStation/Iris/model/msw_wte_collect_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Utility/api_Url.dart';

class MswWteAPIService {
  Future<String> mswWteDataApiCall(MswWteCollectRequestModel requestModelCopy, String siteID) async {
    final prefs = await SharedPreferences.getInstance();
    String sites = prefs.getString("IRIS_SITE_ID").toString();
    String sessionId = prefs.getString('session_id') ?? '2020-05-26 10:00:00';
    requestModelCopy.siteId=sites.contains(",") ? siteID : prefs.getString('IRIS_SITE_ID') ?? '';
    requestModelCopy.createdBy=prefs.getString('IRIS_USER_ID') ?? '';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      HttpHeaders.cookieHeader: sessionId,
    };
    final response = await http.post(Uri.parse(IRIS_MSW_WTE),
        body: jsonEncode(requestModelCopy),
        headers: headers,
        encoding: Encoding.getByName("utf-8"));
    if (response.statusCode == 200 || response.statusCode == 400) {
      return response.body;
    } else {
      return response.body;
    }
  }
}
