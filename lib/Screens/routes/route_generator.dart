import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:resus_test/AppStation/Iris/Department_Screen.dart';
import 'package:resus_test/AppStation/Protect/ProtectOnboardScreen.dart';
import '../../AppStation/Brainbox/brainbox_onboard_screen.dart';
import '../../AppStation/NewAppStation.dart';
import '../../AppStation/Protect/Incident_report/incident_tabview_screen.dart';
import '../SplashScreen.dart';
import '../home/home.dart';
import '../login/login_page.dart';
import '../notification/notification.dart';
import '../profile/profile_dashboard.dart';
import 'routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    //final args = settings.arguments;

    switch (settings.name) {
      case Routes.splash:
        return CupertinoPageRoute(builder: (_) => const SplashScreen());

      case Routes.login:
        return CupertinoPageRoute(builder: (_) => const LoginPage());

      case Routes.home:
        return CupertinoPageRoute(
            builder: (_) => Home(
                googleSignInAccount: null,
                userId: '',
                emailId: '',
                initialSelectedIndex: 0));

      case Routes.newAppStation:
        return CupertinoPageRoute(builder: (_) => const NewAppStation());

      case Routes.protectOnboard:
        return CupertinoPageRoute(builder: (_) => const ProtectOnboard());

      case Routes.notifications:
        return CupertinoPageRoute(builder: (_) => const Notifications());

      case Routes.profile:
        return CupertinoPageRoute(builder: (_) => const ProfileDashboard());

      case Routes.incidenttabview:
        return CupertinoPageRoute(builder: (_) => IncidentTabviewScreen(0));

      case Routes.brainboxOnboardScreen:
        return CupertinoPageRoute(builder: (_) => BrainboxOnboardScreen(googleSignInAccount: null, userId: "", emailId: "", initialSelectedIndex: 4));

      case Routes.irisHomeScreen:
        return CupertinoPageRoute(builder: (_) => DepartmentScreen());


      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return CupertinoPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Error'),
        ),
      );
    });
  }
}
