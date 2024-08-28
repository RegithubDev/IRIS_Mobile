import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resus_test/AppStation/Protect/Incident_report/action_taken.dart';
import 'package:resus_test/AppStation/Protect/Incident_report/my_ir.dart';
import 'package:resus_test/AppStation/Protect/Incident_report/pending_actions.dart';
import 'package:resus_test/Screens/notification/notification.dart';

void main() {

  group('Dropdown Field Testing', () {

    testWidgets(
      "Search button is displayed",
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home:MyIR()));
        expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      },
    );

    testWidgets(
      "Search button is displayed",
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home:PendingActions()));
        expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      },
    );

    testWidgets(
      "Search button is displayed",
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home:ActionTaken()));
        expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      },
    );

    testWidgets(
      "Search button is displayed",
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home:Notifications()));
        expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      },
    );

  });
}