import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../Utility/api_Url.dart';
import '../models/CProtect.dart';

class ActionTakenApiCall {
  String m_sessionId;


  // List<CProtect> m_actionList;
  late List<CProtect> listProtect = [];
  List<CProtect> itemsProtect = [];

  ActionTakenApiCall(this.m_sessionId);


  Future<http.Response> callActionTakenAPi(int startIndex,int pageIndex) async {
    var headers = {'Content-Type': 'application/json', "Cookie": m_sessionId};
    var request = http.Request('GET', Uri.parse(GET_IRM_LIST));
    request.body = json.encode(
        {
          "i_completed": "Resolved",
          "startIndex": startIndex,
          "pageIndex": pageIndex
        });
    request.headers.addAll(headers);
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return response;
  }


  Future<String> unitTestCallActionTakenAPi() async {
    var headers = {'Content-Type': 'application/json', "Cookie": m_sessionId};
    var request = http.Request('GET', Uri.parse(GET_IRM_LIST));
    request.body = json.encode({ "i_completed": "Resolved"});
    request.headers.addAll(headers);
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return response.statusCode.toString();
  }
}
