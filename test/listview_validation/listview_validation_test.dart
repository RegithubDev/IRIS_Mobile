import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';




void main() {

  group('Dropdown Field Testing', () {

    testWidgets('List View Test', (WidgetTester tester) async {
      tester.widgetList(find.byKey(const Key('MyIrListViewKey')));
      await tester.pump();
    });

    testWidgets('List View Test', (WidgetTester tester) async {
      tester.widgetList(find.byKey(const Key('PendinActionListViewKey')));
      await tester.pump();
    });

    testWidgets('List View Test', (WidgetTester tester) async {
      tester.widgetList(find.byKey(const Key('ActionTakenListViewKey')));
      await tester.pump();
    });

    testWidgets('List View Test', (WidgetTester tester) async {
      tester.widgetList(find.byKey(const Key('IncidentHistoryListViewKey')));
      await tester.pump();
    });


  });
}

