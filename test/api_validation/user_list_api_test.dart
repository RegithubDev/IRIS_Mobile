import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:resus_test/Screens/profile/update_profile.dart';


void main() {

  group('getUserListAPICall', () {

    test('returns User List response string when http response is successful',
            () async {

          // Mock the API call to return a json response with http status 200 Ok
          final mockHTTPClient = MockClient((request) async {

            final response = {
              "user_id": "22007871",
              "user_name": "A Amarnadha reddy",
              "user_role": "User",
              "reporting_to": "P Subba rao",
              "reporting_to_id": "22000341",
              "id": "89",
              "email_id": "amarnadhareddy.a@resustainability.com",
              "contact_number": "7568146633",
              "project_code": "HWMP",
              "department_code": "Ops",
              "status": "Active",
              "created_date": "19-Dec-22",
              "created_by": "Ramesh Reddy G",
              "active_users": "546",
              "inActive_users": "14",
              "base_sbu": "IWM",
              "base_project": "Hyderabad Waste Management Project",
              "base_role": "User",
              "sbu_name": "Industrial Waste Management",
              "days": "134",
              "hours": "57",
              "base_department": "Operations",
            };
            return Response(jsonEncode(response), 200, headers: {
              HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
            });
          });
          // Check whether getNumberTrivia function returns
          // number trivia which will be a String
          expect(await getUserListAPICall(mockHTTPClient), isA<String>());
        });

    test('return error message when http response is unsuccessful', () async {

      // Mock the API call to return an
      // empty json response with http status 404
      final mockHTTPClient = MockClient((request) async {
        final response = {};
        return Response(jsonEncode(response), 404);
      });
      expect(await getUserListAPICall(mockHTTPClient),
          'Failed to fetch User list response');
    });
  });
}