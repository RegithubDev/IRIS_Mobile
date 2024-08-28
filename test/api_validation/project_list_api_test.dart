import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:resus_test/Screens/profile/update_profile.dart';


void main() {

  group('getProjectListAPICall', () {

    test('returns Project List response string when http response is successful',
            () async {

          // Mock the API call to return a json response with http status 200 Ok
          final mockHTTPClient = MockClient((request) async {

            final response = {
              "id": "22",
              "company_code": "ReSL",
              "company_name": "Re Sustainability Ltd",
              "sbu_code": "IWM",
              "sbu_name": "Industrial Waste Management",
              "project_code": "BIWM",
              "project_name": "Arha Industrial Waste Management",
              "status": "Active",
              "created_date": "26-Dec-22",
              "created_by": "Rakesh Reddy Ravula",
              "modified_date": "26-Dec-22",
              "modified_by": "Rakesh Reddy Ravula",
              "all_projects": "62",
              "active_projects": "58",
              "inActive_projects": "4"
            };
            return Response(jsonEncode(response), 200, headers: {
              HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
            });
          });
          // Check whether getNumberTrivia function returns
          // number trivia which will be a String
          expect(await getProjectListAPICall(mockHTTPClient), isA<String>());
        });

    test('return error message when http response is unsuccessful', () async {

      // Mock the API call to return an
      // empty json response with http status 404
      final mockHTTPClient = MockClient((request) async {
        final response = {};
        return Response(jsonEncode(response), 404);
      });
      expect(await getProjectListAPICall(mockHTTPClient),
          'Failed to fetch Project list response');
    });
  });
}