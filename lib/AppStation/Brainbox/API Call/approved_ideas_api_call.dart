import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../Utility/api_Url.dart';
import '../Models/CBrainBox.dart';

class ApprovedIdeasApiCall {
  String m_sessionId;
  late List<CBrainBox> listIdeas = [];
  List<CBrainBox> itemsIdeas = [];

  ApprovedIdeasApiCall(this.m_sessionId);

  Future<http.Response> callApprovedIdeasAPi(int startIndex,String user,String role) async {
    var headers = {'Content-Type': 'application/json', "Cookie": m_sessionId};
    var request = http.Request('GET', Uri.parse(GET_ALL_IDEAS_LIST));
    request.body = json.encode(
        {
          // "admin_incidents": m_userId
          "i_completed": "Resolved",
          "startIndex": startIndex,
          "user": user,
          "role": role,
        });
    request.headers.addAll(headers);
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return response;
  }


}
