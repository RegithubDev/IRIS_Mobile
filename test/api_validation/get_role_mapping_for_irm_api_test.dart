import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:resus_test/AppStation/Protect/api_call/roleMappingtApiCall.dart';
import 'package:resus_test/Utility/MyHttpOverrides.dart';



void main() {
  HttpOverrides.global = MyHttpOverrides();

  group('getRoleMappingForIrmAPICall', () {

    test('returns Role Mapping response string when http response is successful',
            () async {

          // Mock the API call to return a json response with http status 200 Ok
          final mockHTTPClient = MockClient((request) async {

            final response = {

              "employee_code": "22011586",
              "email_id": "saidileep.p@resustainability.com",
              "role_code": "IRL1",
              "user_id": "22011586",
              "user_name": "Patoju Giri Venkata Naga Sai Dileep"

            };
            return Response(jsonEncode(response), 200, headers: {
              HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
            });
          });
          RoleMappingApi sng= RoleMappingApi("JSESSIONID=80019B916CFB2688E39718D4F45B8EDE", "DE","RE");

          expect(await sng.unitTestRoleMappingAPi(), isA<String>());
        });

   /* test('return error message when http response is unsuccessful', () async {

      // Mock the API call to return an
      // empty json response with http status 404
      final mockHTTPClient = MockClient((request) async {
        final response = {};
        return Response(jsonEncode(response), 404);
      });
      expect(await getRoleMappingForIrmAPICall(mockHTTPClient),
          'Failed to fetch Role Mapping response');
    });*/
  });
}