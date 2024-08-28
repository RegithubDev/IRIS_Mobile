import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../Utility/api_Url.dart';

class IncidentHistoryApiCall {
  String m_documentCode;

  IncidentHistoryApiCall(
    this.m_documentCode,
  );

  Future<http.Response> callIncidentHistoryAPi() async {
    var headers = {
      'Content-Type': 'application/json',
    };
    var request = http.Request('GET', Uri.parse(GET_IRM_HISTORY_LIST));
    request.body = json.encode({
      "document_code": m_documentCode,
    });
    request.headers.addAll(headers);
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return response;
  }

  Future<String> unitTestCallIncidentHistoryAPi() async {
    var headers = {
      'Content-Type': 'application/json',
    };
    var request = http.Request('GET', Uri.parse(GET_IRM_HISTORY_LIST));
    request.body = json.encode({
      "document_code": m_documentCode,
    });
    request.headers.addAll(headers);
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return response.statusCode.toString();
  }
}
