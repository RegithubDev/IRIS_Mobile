import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../Utility/api_Url.dart';

class RoleMappingBrainBoxApi {
  String m_sessionId;
  String m_role_code;

  RoleMappingBrainBoxApi(this.m_sessionId, this.m_role_code);

  Future<http.Response> callRoleMappingBrainBoxAPi() async {
    var headers = {'Content-Type': 'application/json', 'Cookie': m_sessionId};
    var request = http.Request('GET', Uri.parse(GET_ROLE_MAPPING_FOR_BRAIN_BOX));
    request.body = json.encode(
        {"role_code": m_role_code});
    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return response;
    }
    return response;
  }


}
