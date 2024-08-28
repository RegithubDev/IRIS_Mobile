import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:resus_test/AppStation/Iris/model/iwm/post_disposal_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Utility/api_Url.dart';

class PostDisposalAPIService {
  Future<String> postDisposalApiCall(PostDisposalRequestModel postDisposalRequestModel, String siteID) async {
    final prefs = await SharedPreferences.getInstance();String  sites = prefs.getString('IRIS_SITE_ID').toString();
    String sessionId = prefs.getString('session_id') ?? '2020-05-26 10:00:00';
    postDisposalRequestModel.siteId= sites.contains(",") ? siteID :prefs.getString('IRIS_SITE_ID') ?? '';
    postDisposalRequestModel.createdBy=prefs.getString('IRIS_USER_ID') ?? '';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      HttpHeaders.cookieHeader: sessionId,
    };
    final response = await http.post(Uri.parse(POST_DISPOSAL_DATA),
        body: jsonEncode(postDisposalRequestModel),
        headers: headers,
        encoding: Encoding.getByName("utf-8"));
    if (response.statusCode == 200 || response.statusCode == 400) {
      return response.body;
    } else {
      return response.body;
    }
  }
}