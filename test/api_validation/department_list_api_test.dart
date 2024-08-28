import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:resus_test/Screens/profile/update_profile.dart';


void main() {

  group('getDepartmentListAPICall', () {

    test('returns Department list response string when http response is successful',
            () async {

          // Mock the API call to return a json response with http status 200 Ok
          final mockHTTPClient = MockClient((request) async {

            final response = {
              "id": "26",
              "department_code": "Admin",
              "department_name": "Admin",
              "assigned_to_sbu_multiple": "BMW,IWM,MSW,Recycling,CO",
              "status": "Active",
              "user_name": "Ramesh Reddy G",
              "created_date": "19-Dec-22  08:34",
              "created_by": "22010973",
              "modified_by": "Amarnath Reddy Kakumanu",
              "modified_date": "16-Jan-23  06:47",
              "all_department": "42",
              "active_department": "40",
              "inActive_department": "2"
            };
            return Response(jsonEncode(response), 200, headers: {
              HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
            });
          });
          // Check whether getNumberTrivia function returns
          // number trivia which will be a String
          expect(await getDepartmentListAPICall(mockHTTPClient), isA<String>());
        });

    test('return error message when http response is unsuccessful', () async {

      // Mock the API call to return an
      // empty json response with http status 404
      final mockHTTPClient = MockClient((request) async {
        final response = {};
        return Response(jsonEncode(response), 404);
      });
      expect(await getDepartmentListAPICall(mockHTTPClient),
          'Failed to fetch Department list response');
    });
  });
}