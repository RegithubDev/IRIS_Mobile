import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resus_test/AppStation/Protect/Incident_report/action_taken.dart';
import 'package:resus_test/AppStation/Protect/Incident_report/my_ir.dart';
import 'package:resus_test/AppStation/Protect/Incident_report/pending_actions.dart';

void main() {

  group('Dropdown Field Testing', () {

    testWidgets(
      "Floating Action Button is displayed",
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home:MyIR()));
        expect(find.widgetWithIcon(FloatingActionButton, Icons.add), findsOneWidget);
      },
    );

    testWidgets(
      "Floating Action Button is displayed",
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home:PendingActions()));
        expect(find.widgetWithIcon(FloatingActionButton, Icons.add), findsOneWidget);
      },
    );

    testWidgets(
      "Floating Action Button is displayed",
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home:ActionTaken()));
        expect(find.widgetWithIcon(FloatingActionButton, Icons.add), findsOneWidget);
      },
    );
  });
}