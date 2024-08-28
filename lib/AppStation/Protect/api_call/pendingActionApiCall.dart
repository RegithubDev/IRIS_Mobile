import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../Utility/api_Url.dart';
import '../models/CProtect.dart';

class PendingActionApiCall {
  String m_sessionId;

  late List<CProtect> listProtect = [];
  List<CProtect> itemsProtect = [];

  PendingActionApiCall(
    this.m_sessionId
  );

  Future<http.Response> callPendingActionAPi(int startIndex,int pageIndex) async {
    var headers = {'Content-Type': 'application/json', "Cookie": m_sessionId};
    var request = http.Request('GET', Uri.parse(GET_IRM_LIST));
    request.body = json.encode({
      "i_pending": "In Progress",
      "startIndex": startIndex,
      "pageIndex": pageIndex
    });
    request.headers.addAll(headers);
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return response;
  }

  Future<String> unitTestCallPendingActionAPi() async {
    var headers = {'Content-Type': 'application/json', "Cookie": m_sessionId};
    var request = http.Request('GET', Uri.parse(GET_IRM_LIST));
    request.body = json.encode({ "i_pending": "In Progress"});
    request.headers.addAll(headers);
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return response.statusCode.toString();
  }
}
