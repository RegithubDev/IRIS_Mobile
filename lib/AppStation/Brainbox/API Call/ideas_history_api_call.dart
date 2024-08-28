import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../Utility/api_Url.dart';

class IdeasHistoryApiCall {
  String m_ideaNO;

  IdeasHistoryApiCall(
      this.m_ideaNO,
      );

  Future<http.Response> callIdeasHistoryAPi() async {
    var headers = {
      'Content-Type': 'application/json',
    };
    var request = http.Request('GET', Uri.parse(GET_IDEAS_HISTORY));
    request.body = json.encode({
      "idea_no": m_ideaNO,
    });
    request.headers.addAll(headers);
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return response;
  }

}
