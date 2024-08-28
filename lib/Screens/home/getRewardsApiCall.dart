import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../Utility/api_Url.dart';
import 'CRewards.dart';

class RewardsApiCall {
  String m_sessionId;
  String m_userId;
  late List<CRewards> listRewards = [];
  List<CRewards> itemsRewards = [];

  RewardsApiCall(this.m_sessionId, this.m_userId);

  Future<http.Response> callRewardsAPi() async {
    var headers = {'Content-Type': 'application/json', "Cookie": m_sessionId};
    var request = http.Request('GET', Uri.parse(GET_REWARDS_LIST));
    request.body = json.encode({"user": m_userId});
    request.headers.addAll(headers);
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return response;
  }
}
