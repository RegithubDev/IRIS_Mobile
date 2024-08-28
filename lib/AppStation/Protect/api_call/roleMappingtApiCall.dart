import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../Utility/api_Url.dart';

class RoleMappingApi {
  String m_sessionId;
  String m_project_code;
  String m_department_code;

  RoleMappingApi(this.m_sessionId, this.m_project_code, this.m_department_code);

  Future<http.Response> callRoleMappingAPi() async {
    var headers = {'Content-Type': 'application/json', 'Cookie': m_sessionId};
    var request = http.Request('GET', Uri.parse(GET_ROLE_MAPPING_FOR_IRM));
    request.body = json.encode(
        {"project_code": m_project_code, "department_code": m_department_code});
    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      // MySharedPreferences.instance.setStringValue(
      //     "employee_code",
      //     jsonDecode(response.body)["employee_code"]);
      // MySharedPreferences.instance.setStringValue(
      //     "email_id", jsonDecode(response.body)["email_id"]);
      // MySharedPreferences.instance.setStringValue(
      //     "role_code",
      //     jsonDecode(response.body)["role_code"]);
      return response;
    }
    return response;
  }

  Future<String> unitTestRoleMappingAPi() async {
    var headers = {'Content-Type': 'application/json',
      'Cookie': m_sessionId,
      HttpHeaders.acceptHeader:"*/*",
      HttpHeaders.acceptEncodingHeader:"gzip, deflate, br",
      HttpHeaders.connectionHeader:"keep-alive"
    };
    var request = http.Request('GET', Uri.parse(GET_ROLE_MAPPING_FOR_IRM));
    request.body = json.encode(
        {"project_code": m_project_code, "department_code": m_department_code});
    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return response.body;
    }
    return response.body;
  }
}
