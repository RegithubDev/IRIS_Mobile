import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../Utility/api_Url.dart';
import 'CNotification.dart';

class NotificationApiCall {
  String m_sessionId;
  String m_userId;
  late List<CNotification> listNotification = [];
  List<CNotification> itemsNotification = [];

  NotificationApiCall(this.m_sessionId, this.m_userId);

  Future<http.Response> callNotificationAPi() async {
    var headers = {'Content-Type': 'application/json', "Cookie": m_sessionId};
    var request = http.Request('GET', Uri.parse(GET_NOTIFICATION_LIST));
    request.body =
        json.encode({"user": m_userId, "last_sync_time": "2023-07-04"});
    request.headers.addAll(headers);
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return response;
  }
}
