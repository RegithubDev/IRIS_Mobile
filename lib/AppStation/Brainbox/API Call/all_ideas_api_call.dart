import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../Utility/api_Url.dart';
import '../Models/CBrainBox.dart';

class AllIdeasApiCall {
  String mSessionId;

  late List<CBrainBox> listIdeas = [];
  List<CBrainBox> itemsIdeas = [];

  AllIdeasApiCall(this.mSessionId);

  Future<http.Response> callAllIdeasAPi(int startIndex,String user,String role) async {
    var headers = {'Content-Type': 'application/json', "Cookie": mSessionId};
    var request = http.Request('GET', Uri.parse(GET_ALL_IDEAS_LIST));
    request.body = json.encode(
        {
          // "admin_incidents": userId,
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
