import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:resus_test/Utility/shared_preferences_string.dart';

import '../Utility/utils/constants.dart';
import '../custom_sharedPreference.dart';
import '../data/pref_manager.dart';
import 'CarouselScreen.dart';
import 'home/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigatetohome();
  }

  _navigatetohome() async {
    await Prefs.load();
    await Future.delayed(const Duration(seconds: 3), () {});
    // ignore: use_build_context_synchronously
    bool isLoggedIn = await CustomSharedPref.getPref<bool>(
            SharedPreferencesString.isLoggedIn) ??
        false;
    if (kDebugMode) {
      print(isLoggedIn);
    }
    if (isLoggedIn) {
      ///if user already logged in
      String userId = await CustomSharedPref.getPref<String>(
              SharedPreferencesString.userId) ??
          '';
      String emailId = await CustomSharedPref.getPref<String>(
              SharedPreferencesString.emailId) ??
          '';

      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Home(
                  googleSignInAccount: null,
                  userId: userId,
                  emailId: emailId,
                  initialSelectedIndex: 0)));
    } else {
      CustomSharedPref.setPref<String>(SharedPreferencesString.userId, "");
      CustomSharedPref.setPref<String>(SharedPreferencesString.emailId, "");
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const CarouselScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        key: const ValueKey('splashscreenContainer'),
        backgroundColor: kReSustainabilityRed,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 195.0),
              child: Center(
                child: Image.asset(
                  'assets/images/reone_logo_updated.png',
                  height: 200,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(
              height: 200,
            ),
            const SizedBox(
              key: ValueKey('splashcontainer1'),
              width: 150,
              height: 2,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(kReSustainabilityRed),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
