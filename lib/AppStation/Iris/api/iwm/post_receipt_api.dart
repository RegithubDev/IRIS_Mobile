import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Utility/api_Url.dart';
import '../../model/iwm/post_receipt_model.dart';

class PostReceiptAPIService {
  Future<String> postReceiptApiCall(PostReceiptRequestModel postReceiptRequestModel, String siteID) async {
    final prefs = await SharedPreferences.getInstance();
    String  sites = prefs.getString('IRIS_SITE_ID').toString();
    String sessionId = prefs.getString('session_id') ?? '2020-05-26 10:00:00';
    postReceiptRequestModel.siteId= sites.contains(",") ? siteID :prefs.getString('IRIS_SITE_ID') ?? '';
    postReceiptRequestModel.createdBy=prefs.getString('IRIS_USER_ID') ?? '';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      HttpHeaders.cookieHeader: sessionId,
    };
    final response = await http.post(Uri.parse(POST_RECEIPT_DATA),
        body: jsonEncode(postReceiptRequestModel),
        headers: headers,
        encoding: Encoding.getByName("utf-8"));
    if (response.statusCode == 200 || response.statusCode == 400) {
      return response.body;
    } else {
      return response.body;
    }
  }
}