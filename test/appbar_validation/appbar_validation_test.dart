import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resus_test/AppStation/Protect/Incident_report/inbox.dart';
import 'package:resus_test/AppStation/Protect/Incident_report/incident_tabview_screen.dart';
import 'package:resus_test/AppStation/Protect/Incident_report/outbox.dart';
import 'package:resus_test/Screens/profile/profile_dashboard.dart';

void main() {

  group('Dropdown Field Testing', () {

    testWidgets(
      "App bar widget test",
          (widgetTester) async {
        await widgetTester.pumpWidget( MaterialApp(home:IncidentTabviewScreen(0)));
        expect(find.text('Incident Report'), findsOneWidget);
      },
    );

    testWidgets(
      "App bar widget test",
          (widgetTester) async {
        await widgetTester.pumpWidget(const MaterialApp(home:Inbox()));
        expect(find.text('Inbox'), findsOneWidget);
      },
    );

    testWidgets(
      "App bar widget test",
          (widgetTester) async {
        await widgetTester.pumpWidget(const MaterialApp(home:ProfileDashboard()));
        expect(find.text('Edit Profile'), findsOneWidget);
      },
    );

    testWidgets(
      "App bar widget test",
          (widgetTester) async {
        await widgetTester.pumpWidget(const MaterialApp(home:Outbox()));
        expect(find.text('Outbox'), findsOneWidget);
      },
    );

    /*testWidgets(
      "App bar widget test",
          (widgetTester) async {
        await widgetTester.pumpWidget(const MaterialApp(home:UpdateProfile(sbuDefaultValue: '', departmentDefaultValue: '', projectDefaultValue: '', reportingToDefaultValue: '',)));
        expect(find.text('Edit Profile'), findsOneWidget);
      },
    );*/

  });
}