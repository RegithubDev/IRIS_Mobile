import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:resus_test/AppStation/Protect/api_call/incidentHistoryApiCall.dart';
import 'package:resus_test/Utility/MyHttpOverrides.dart';


void main() {
  HttpOverrides.global = MyHttpOverrides();

  group('For testing incident history list API', () {

    test('returns login response string when http response is successful',
            () async {

          // Mock the API call to return a json response with http status 200 Ok
          final mockHTTPClient = MockClient((request) async {

            final response = {

              "status": "In Progress",
              "created_by": "22011225",
              "approver_type": "IRL1",
              "approver_code": "22011568",
              "assigned_on": "27-Feb-23  09:35",
              "user_name": "Rontala Anil Kumar",

            };

            return Response(jsonEncode(response), 200, headers: {
              HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
            });
          });


          IncidentHistoryApiCall ih= IncidentHistoryApiCall("IRM_2302_508");


          expect(await ih.unitTestCallIncidentHistoryAPi(), "200");
        });

  });
}