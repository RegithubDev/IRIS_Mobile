import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:resus_test/AppStation/Protect/api_call/actionTakenApiCall.dart';
import 'package:resus_test/Utility/MyHttpOverrides.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();

  group('For testing action taken list API', () {

    test('returns login response string when http response is successful',
            () async {

          // Mock the API call to return a json response with http status 200 Ok
          final mockHTTPClient = MockClient((request) async {

            final response = {
              "id": "728",
              "document_code": "IRM_2303_728",
              "maxRole2": "IRL1",
              "incident_type": "Unsafe Act",
              "email_id": "pcabhijith2@gmail.com",
              "all_irm": "3",
              "active_irm": "0",
              "inActive_irm": "3",
              "project_name": "DEMO",
              "department_name": "Contracts and Claims",
              "description": "fhf",
              "department_code": "C&C",
              "project_code": "DE",
              "risk_type": "Medium",
              "status": "In Progress",
              "created_date": "17-Mar-23  06:33",
              "created_by": "54321",
              "approver_type": "IRL1",
              "approver_code": "22011284",
              "incident_code": "UA",
              "user_name": "abhijith pc",
              "approver_name": "Shyama Sundar MN",
              "not_assigned": "0",
              "sbu_code": "DE",
              "sbu_name": "DEMO",
              "noCounts": "82",
              "counts": "239",
              "incident_category": "Falling Object",

            };

            return Response(jsonEncode(response), 200, headers: {
              HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
            });
          });


          ActionTakenApiCall Act= ActionTakenApiCall("JSESSIONID=80019B916CFB2688E39718D4F45B8EDE", );


          expect(await Act.unitTestCallActionTakenAPi(), "200");
        });

  });
}