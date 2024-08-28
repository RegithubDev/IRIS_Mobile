import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:resus_test/AppStation/Protect/api_call/submitIncidentApiCall.dart';
import 'package:resus_test/Utility/MyHttpOverrides.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();

  group('For testing submit incident API', () {
    test('returns login response string when http response is successful',
        () async {
      final mockHTTPClient = MockClient((request) async {
        final response = {"Incident Submitted Succesfully."};

        return Response(jsonEncode(response), 200, headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
        });
      });
      SubmitIncidentApi sng = SubmitIncidentApi(
          "JSESSIONID=80019B916CFB2688E39718D4F45B8EDE",
          json.encode({
            "project_code": "BWMP",
            "department_code": "Bio",
            "incident_type": "NM",
            "incident_category": "Animal Attack",
            "description": "xhf",
            "approver_code": "",
            "email_id": "pcabhijith2@gmail.com",
            "approver_type": "",
            "image_list": [],
            "filenameAndExtList": [],
            "person_location": "12.9259979,77.5732783"
          }));
      expect(await sng.callSubmitIncidentAPi(), isA<String>());
    });
  });
}
