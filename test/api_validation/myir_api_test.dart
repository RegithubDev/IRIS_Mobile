import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:resus_test/AppStation/Protect/api_call/myIrApiCall.dart';
import 'package:resus_test/Utility/MyHttpOverrides.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();

  group('For testing my IR list API', () {
    test('returns login response string when http response is successful',
        () async {
      final mockHTTPClient = MockClient((request) async {
        final response = {
          "id": "237",
          "document_code": "IRM_2302_237",
          "incident_type": "Accident",
          "email_id": "syedshoiab.hadi@resustainability.com",
          "all_irm": "263",
          "active_irm": "63",
          "inActive_irm": "179",
          "project_name": "Hyderabad MSW Energy Solutions Private Limited",
          "department_name": "Mechanical",
          "description":
              "On dated 28.01.2023 Time: 08.30 AM As a routine activity on daily basis, worker had visited the slagger area for checking slagger’s hydraulic cylinder base bolts and while checking the base bolts worker has slipped and stepped inside slagger hot water and right leg got burn injuries.\r\nDuring maintenance / inspection LOTO for slagger’s hydraulic cylinder and planks to reach the hydraulic system is mandatory as per regular procedure. However as it’s a routine work, worker ignored and tried to approach inaccessible area without planks for checking of Slagger hydraulic cylinder base bolts and unfortunately slipped and stepped inside slagger due to adequate safety shoes burns are not too intense and resulted superficial burns on right leg.\r\nFirst aid provided and shifted to hospital and doctors confirmed as superficial burns on right leg and discharged after treatment.",
          "department_code": "Mechanical",
          "project_code": "HMESPL",
          "risk_type": "Medium",
          "status": "Resolved",
          "created_date": "01-Feb-23  04:19",
          "created_by": "22010752",
          "approver_type": "IRL3",
          "approver_code": "22008799",
          "action_taken": "10-Feb-23  11:51",
          "incident_code": "AC",
          "user_name": "Syed Shoiab Hadi",
          "approver_name": "Appi Reddy Kommareddy",
          "not_assigned": "21",
          "sbu_code": "WTE",
          "sbu_name": "Waste to Energy",
          "noCounts": "21",
          "counts": "179",
          "incident_category": "Injury",
        };

        return Response(jsonEncode(response), 200, headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
        });
      });

      MyIRApiCall sng =
          MyIRApiCall("JSESSIONID=80019B916CFB2688E39718D4F45B8EDE", "54321");

      expect(await sng.unitTestCallMyIrAPi(), "200");
    });
  });
}
