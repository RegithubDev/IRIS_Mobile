import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resus_test/AppStation/Protect/sort/action_taken_sort_popup.dart';
import 'package:resus_test/AppStation/Protect/sort/incident_history_sort_popup.dart';
import 'package:resus_test/AppStation/Protect/sort/myir_sort_popup.dart';
import 'package:resus_test/AppStation/Protect/sort/pending_action_sort_popup.dart';
import 'package:resus_test/Screens/notification/notification_sort_popup.dart';
import 'package:resus_test/Utility/network_error_dialogbox.dart';
import 'package:resus_test/Utility/showDialogBox.dart';

void main() {

  group('Dialog Field Testing', () {

     testWidgets('Select Dialog item test', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home:NotificationSortPopup()));
      final container = find.byKey(const ValueKey('notificationDialog'));
      await tester.pump();
    });

    testWidgets('Select Dialog item test', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home:MyIrSortPopup()));
      final container = find.byKey(const ValueKey('myIrDialog'));
      await tester.pump();
    });

    testWidgets('Select Dialog item test', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home:PendingActionsSortPopup()));
      final container = find.byKey(const ValueKey('pendingActionDialog'));
      await tester.pump();
    });

    testWidgets('Select Dialog item test', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home:ActionTakenSortPopup()));
      final container = find.byKey(const ValueKey('actionTakenDialog'));
      await tester.pump();
    });


    testWidgets('Select Dialog item test', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home:IncidentHistorySortPopup()));
      final container = find.byKey(const ValueKey('incidentHistoryDialog'));
      await tester.pump();
    });

     testWidgets('Select Dialog item test', (WidgetTester tester) async {
       await tester.pumpWidget(const MaterialApp(home:ShowDialogBox(title: '',)));
       final container = find.byKey(const ValueKey('showDialog'));
       await tester.pump();
     });

     testWidgets('Select Dialog item test', (WidgetTester tester) async {
       await tester.pumpWidget(const MaterialApp(home:NetworkErrorDialog()));
       final container = find.byKey(const ValueKey('internetCheck'));
       await tester.pump();
     });





  });
}