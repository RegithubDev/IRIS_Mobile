import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resus_test/AppStation/Protect/Incident_report/action_taken.dart';
import 'package:resus_test/AppStation/Protect/Incident_report/inbox.dart';
import 'package:resus_test/AppStation/Protect/Incident_report/incident_form_view.dart';
import 'package:resus_test/AppStation/Protect/Incident_report/incident_history.dart';
import 'package:resus_test/AppStation/Protect/Incident_report/my_ir.dart';
import 'package:resus_test/AppStation/Protect/Incident_report/pending_actions.dart';
import 'package:resus_test/AppStation/Protect/models/CProtect.dart';
import 'package:resus_test/Screens/SplashScreen.dart';
import 'package:resus_test/Screens/components/custom_circular_indicator.dart';
import 'package:resus_test/Screens/components/custom_icons.dart';
import 'package:resus_test/Screens/components/labeled_text_form_field.dart';
import 'package:resus_test/Screens/components/round_icon_button.dart';
import 'package:resus_test/Screens/components/social_icon.dart';
import 'package:resus_test/Screens/components/text_form_field.dart';
import 'package:resus_test/Screens/drawer/drawer.dart';
import 'package:resus_test/Screens/home/widgets/app_bar_title_widget.dart';
import 'package:resus_test/Screens/home/widgets/reward_count_widget.dart';
import 'package:resus_test/Screens/home/widgets/section_header_widget.dart';
import 'package:resus_test/Screens/login/widgets/input_widget.dart';
import 'package:resus_test/Screens/login/widgets/social_login_widget.dart';
import 'package:resus_test/Screens/notification/notification.dart';
import 'package:resus_test/Utility/dialog_rounded_button.dart';
import 'package:resus_test/Utility/showDialogBox.dart';
import 'package:resus_test/Utility/showLoader.dart';

void main() {

  Widget makeTestableWidget({required Widget child}) {
    return MaterialApp(
      home: child,
    );
  }
  group('Container Field Testing', () {

/*
    testWidgets("Login Screen Widget Test", (WidgetTester tester) async {
      LoginPage loginPage=const LoginPage();
      await tester.pumpWidget(makeTestableWidget(child: loginPage));
      await tester.tap(find.byKey(const Key('login_btn')));
    });
*/

/*
    testWidgets("OTP Screen Widget Test", (WidgetTester tester) async {
      LoginWithOtpScreen loginWithOtpScreen=const LoginWithOtpScreen(emailId: 'pcabhijith2@gmail.com',);
      await tester.pumpWidget(makeTestableWidget(child: loginWithOtpScreen));

      await tester.tap(find.byKey(const Key('otp_login_btn')));
    });
*/

   /* testWidgets('Submit Incident Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(const MaterialApp(home:SubmitIncident()));
      final container = find.byKey(const ValueKey('c1'));
      await tester.tap(container);
      await tester.pump();
    });
    testWidgets('Submit Incident Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(const MaterialApp(home:SubmitIncident()));
      final container = find.byKey(const ValueKey('c2'));
      await tester.tap(container);
      await tester.pump();
    });*/

    /*testWidgets('Submit Incident Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(const MaterialApp(home:SubmitIncident()));
      final container = find.byKey(const ValueKey('c3'));
      await tester.tap(container);
      await tester.pump();
    });*/

    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(const MaterialApp(home:MyIR()));
      final container = find.byKey(const ValueKey('myIrContainer'));
      await tester.tap(container);
      await tester.pump();
    });


    /*testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget( MaterialApp(home:CarouselScreen()));
      final container = find.byKey(const ValueKey('carouselcontainer1'));
      await tester.tap(container);
      await tester.pump();
    });

    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget( MaterialApp(home:CarouselScreen()));
      final container = find.byKey(const ValueKey('carouselcontainer2'));
      await tester.tap(container);
      await tester.pump();
    });

    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget( MaterialApp(home:CarouselScreen()));
      final container = find.byKey(const ValueKey('carouselcontainer3'));
      await tester.pump();
    });

    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget( MaterialApp(home:CarouselScreen()));
      final container = find.byKey(const ValueKey('carouselcontainer4'));
      await tester.pump();
    });

    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget( MaterialApp(home:CarouselScreen()));
      final container = find.byKey(const ValueKey('carouselcontainer5'));
      await tester.pump();
    });

    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget( MaterialApp(home:CarouselScreen()));
      final container = find.byKey(const ValueKey('carouselcontainer6'));
      await tester.pump();
    });*/

    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget( MaterialApp(home:DrawerPage(onTap: () {  },)));
      final container = find.byKey(const ValueKey('drawerContainerKey'));
      await tester.pump();
    });

    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget( const MaterialApp(home:Notifications()));
      final container = find.byKey(const ValueKey('notificationcontainer1'));
      await tester.pump();
    });

    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget( const MaterialApp(home:Notifications()));
      final container = find.byKey(const ValueKey('notificationcontainer2'));
      await tester.pump();
    });

    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(const MaterialApp(home:PendingActions()));
      final container = find.byKey(const ValueKey('pendingActionContainer1'));
      await tester.pump();
    });

    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget( const MaterialApp(home:AppBarTitleWidget()));
      final container = find.byKey(const ValueKey('homeAppbar'));
      await tester.pump();
    });

    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget( const MaterialApp(home:SectionHeaderWidget(title: '',)));
      final container = find.byKey(const ValueKey('sectionheaderContainer1'));
      await tester.pump();
    });

    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget( const MaterialApp(home:InputWidget()));
      final container = find.byKey(const ValueKey('inputWidgetContainer1'));
      await tester.pump();
    });

    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget( const MaterialApp(home:SocialLoginWidget()));
      final container = find.byKey(const ValueKey('socialLoginContainer1'));
      await tester.pump();
    });

    /*testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget( const MaterialApp(home:AppStation()));
      final container = find.byKey(const ValueKey('appStationContainer'));
      await tester.pump();
    });

    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget( const MaterialApp(home:ProtectOnboard()));
      final container = find.byKey(const ValueKey('protectContainer'));
      await tester.pump();
    });*/

    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget( MaterialApp(home:DialogRoundedButton(text: '', press: () {  }, color: Colors.white )));
      final container = find.byKey(const ValueKey('roundedButton'));
      await tester.pump();
    });

    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget( const MaterialApp(home:SplashScreen(  )));
      final container = find.byKey(const ValueKey('splashscreenContainer'));
      await tester.pumpAndSettle(const Duration(seconds:3));
    });

/*
    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget( MaterialApp(home:ConfirmationDialogBox(title: 'Incident Submitted Succesfully',
        press: () {  }, color: Colors.white, text: 'Done',)));
      final container = find.byKey(const ValueKey('confirmationDialog'));
    });
*/

    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget( MaterialApp(home:ShowLoader()));
      final container = find.byKey(const ValueKey('showLoader'));
    });

    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget( const MaterialApp(home:ShowDialogBox(title: '',)));
      final container = find.byKey(const ValueKey('showDialog'));
    });

    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget( const MaterialApp(home:ActionTaken()));
      final container = find.byKey(const ValueKey('actionTaken'));
    });

    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget( const MaterialApp(home:Inbox()));
      final container = find.byKey(const ValueKey('inbox'));
    });

    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget( const MaterialApp(home:CustomCircularIndicator(radius: 70, percent: 1.0, count: null,)));
      final container = find.byKey(const ValueKey('customCircularIndicator'));
    });

    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget( const MaterialApp(home:LabeledTextFormField(title: '',)));
      final container = find.byKey(const ValueKey('labeledTextFormField'));
    });

    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(  MaterialApp(home:SocialIcon(colors: const [], iconData: CustomIcons.googlePlus, onPressed: () {  },)));
      final container = find.byKey(const ValueKey('socialLogin'));
    });

    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(  MaterialApp(home:RoundIconButton(icon: Icons.live_help_outlined, onPressed: () {  },)));
      final container = find.byKey(const ValueKey('roundIconButton'));
    });

    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(  const MaterialApp(home:CustomTextFormField(hintText: '',)));
      final container = find.byKey(const ValueKey('customTextFormField'));
    });

    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(const MaterialApp(home:RewardCountWidget()));
      final container = find.byKey(const ValueKey('rewardCountContainer'));
    });

/*
    testWidgets('Select Container item test', (WidgetTester tester) async {
      FlutterError.onError = ignoreOverflowErrors;
      await tester.pumpWidget(   MaterialApp(home:VisitedDoctorListItem()));
      final container = find.byKey(const ValueKey('visitedContainer'));
    });
*/


    testWidgets('Select Container item test', (WidgetTester tester) async {
      final FlutterExceptionHandler? originalOnError = FlutterError.onError;
      IncidentHistory(cProtect: CProtect(document_code: "", status: "",
          incident_type: "", project_name: "", department_name: "",
          approver_type: "", approver_name: "", user_name: "",
          created_date: "", email_id: "", risk_type: "",
          incident_category: "", description: "", action_taken: ""),);
      await tester.pumpAndSettle();
      // reset onError after calling pumpAndSettle()
      FlutterError.onError = originalOnError;
    });

    testWidgets('Select Container item test', (WidgetTester tester) async {
      final FlutterExceptionHandler? originalOnError = FlutterError.onError;
      IncidentFormView(cProtect: CProtect(document_code: "", status: "",
          incident_type: "", project_name: "", department_name: "",
          approver_type: "", approver_name: "", user_name: "",
          created_date: "", email_id: "", risk_type: "",
          incident_category: "", description: "", action_taken: ""),);
      await tester.pumpAndSettle();
      // reset onError after calling pumpAndSettle()
      FlutterError.onError = originalOnError;
    });

  });
}



void ignoreOverflowErrors(
    FlutterErrorDetails details, {
      bool forceReport = false,
    }) {
  bool ifIsOverflowError = false;
  bool isUnableToLoadAsset = false;

  // Detect overflow error.
  var exception = details.exception;
  if (exception is FlutterError) {
    ifIsOverflowError = !exception.diagnostics.any(
          (e) => e.value.toString().startsWith("A RenderFlex overflowed by"),
    );
    isUnableToLoadAsset = !exception.diagnostics.any(
          (e) => e.value.toString().startsWith("Unable to load asset"),
    );
  }

  // Ignore if is overflow error.
  if (ifIsOverflowError || isUnableToLoadAsset) {
    debugPrint('Ignored Error');
  } else {
    FlutterError.dumpErrorToConsole(details, forceReport: forceReport);
  }
}