import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:resus_test/Screens/profile/update_profile.dart';


void main() {

  group('getSbuListAPICall', () {

    test('returns SBU List response string when http response is successful',
            () async {

          // Mock the API call to return a json response with http status 200 Ok
          final mockHTTPClient = MockClient((request) async {

            final response = {
              "id": "8",
              "company_code": "ReSL",
              "company_name": "Re Sustainability Ltd",
              "sbu_code": "BMW",
              "sbu_name": "Bio Medical Waste Management",
              "status": "Active",
              "all_sbu": "9",
              "active_sbu": "9",
              "inActive_sbu": "0"
            };
            return Response(jsonEncode(response), 200, headers: {
              HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
            });
          });
          // Check whether getNumberTrivia function returns
          // number trivia which will be a String
          expect(await getSbuListAPICall(mockHTTPClient), isA<String>());
        });

    test('return error message when http response is unsuccessful', () async {

      // Mock the API call to return an
      // empty json response with http status 404
      final mockHTTPClient = MockClient((request) async {
        final response = {};
        return Response(jsonEncode(response), 404);
      });
      expect(await getSbuListAPICall(mockHTTPClient),
          'Failed to fetch SBU list response');
    });
  });
}