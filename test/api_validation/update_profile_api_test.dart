import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:resus_test/Screens/profile/upateprofileApCall.dart';
import 'package:resus_test/Utility/MyHttpOverrides.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();

  group('For testing update profile API', () {

    test('returns update profile response string when http response is successful',
            () async {

          // Mock the API call to return a json response with http status 200 Ok
          final mockHTTPClient = MockClient((request) async {

            final response = {
              {
                "Project": "DEMO",
                "DEPARTMENT_NAME": "DEMO Department",
                "SBU_NAME": "DEMO",
                "REPORTING_TO_NAME": "A Amarnadha reddy",
                "SBU": "DE",
                "PROJECT_CODE": "DE",
                "DEPARTMENT": "RE",
                "REPORTING_TO": "22007871"
              }
            };

            return Response(jsonEncode(response), 200, headers: {
              HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
            });
          });
          final request_body = {
            {
              "base_sbu": "DE",
              "base_project": "DE",
              "base_department":"RE",
              "reporting_to": "22007871",
              "email_id" : "pcabhijith2@gmail.com",
              "contact_number": ""
            }
          };

          UpdateProfileApi up= UpdateProfileApi("JSESSIONID=80019B916CFB2688E39718D4F45B8EDE", json.encode({
            "base_sbu": "DE",
            "base_project": "DE",
            "base_department":"RE",
            "reporting_to": "22007871",
            "email_id" : "pcabhijith2@gmail.com",
            "contact_number": ""}));


          expect(await up.calUpdateProfileAPi(), isA<String>());
        });



  });
}