import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'package:recase/recase.dart';
import 'package:resus_test/Screens/drawer/help_centre.dart';
import 'package:resus_test/Screens/drawer/privacy_policy.dart';
import 'package:resus_test/Screens/drawer/terms_and_conditions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../Utility/MySharedPreferences.dart';
import '../../Utility/api_Url.dart';
import '../../Utility/logout_loader.dart';
import '../../Utility/shared_preferences_string.dart';
import '../../Utility/utils/constants.dart';
import '../../custom_sharedPreference.dart';
import '../components/round_icon_button.dart';
import '../login/login_page.dart';
import '../profile/profile_dashboard.dart';
import 'download_centre.dart';
import 'package:flutter/cupertino.dart';

class DrawerPage extends StatefulWidget {
  final void Function() onTap;

  const DrawerPage({Key? key, required this.onTap}) : super(key: key);

  @override
  State<DrawerPage> createState() => _DrawerPageState(onTap);
}

class _DrawerPageState extends State<DrawerPage> {
  void Function() m_onTap;

  _DrawerPageState(this.m_onTap);

  bool isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: GestureDetector(
        onTap: m_onTap,
        child: Scaffold(
          backgroundColor: kReSustainabilityRed,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 35,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 4.h,
                              backgroundColor: Colors.white,
                              child: FutureBuilder(
                                  future: getStringValue('user_name'),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<String> snapshot) {
                                    if (snapshot.hasData) {
                                      return Text(
                                        '${snapshot.data.toString()[0]}'
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: kReSustainabilityRed,
                                          fontSize: 20.sp,
                                          fontFamily: 'ARIAL',
                                          fontWeight: FontWeight.bold, // italic
                                        ),
                                      );
                                      // your widget
                                    } else {
                                      return const CircularProgressIndicator();
                                    }
                                  }),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            RoundIconButton(
                              onPressed: () async {
                                // ignore: use_build_context_synchronously
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return const ProfileDashboard();
                                    },
                                  ),
                                );
                              },
                              icon: Icons.edit,
                              size: 40,
                              color: kReSustainabilityRed,
                              iconColor: Colors.white,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: 240,
                          child: FutureBuilder(
                              future: getStringValue('user_name'),
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> snapshot) {
                                if (snapshot.hasData) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          snapshot.data.toString().titleCase,
                                          textAlign: TextAlign.left,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: "ARIAL",
                                            color: Colors.white,
                                            fontSize: 13.sp,
                                            fontWeight:
                                                FontWeight.bold, // italic
                                          ),
                                        ),
                                      ),
                                    ],
                                  ); // your widget
                                } else {
                                  return const CircularProgressIndicator();
                                }
                              }),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          width: 240,
                          child: FutureBuilder(
                              future: getStringValue('base_role'),
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> snapshot) {
                                if (snapshot.hasData) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          snapshot.data.toString().titleCase,
                                          textAlign: TextAlign.left,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: "ARIAL",
                                            color: Colors.white,
                                            fontSize: 10.sp,
                                            fontWeight:
                                                FontWeight.bold, // italic
                                          ),
                                        ),
                                      ),
                                    ],
                                  ); // your widget
                                } else {
                                  return const CircularProgressIndicator();
                                }
                              }),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  _drawerItem(
                      icon: Icons.help_center_outlined,
                      text: 'Help Centre',
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const HelpCentre();
                            },
                          ),
                        );
                      }),
                  _drawerItem(
                      icon: Icons.library_books,
                      text: 'Terms and Conditions',
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const TermsAndConditions();
                            },
                          ),
                        );
                      }),
                  _drawerItem(
                    icon: Icons.privacy_tip_outlined,
                    text: 'Privacy Policy',
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const PrivacyPolicy();
                          },
                        ),
                      );
                    },
                  ),
                  _drawerItem(
                      icon: Icons.download,
                      text: 'Download Center',
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const DownloadCentre();
                            },
                          ),
                        );
                      }),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 25),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(32.w, 4.h),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      onPressed: () {
                        showLogoutAlertDialog(context);
                      },
                      child: Text(
                        "Logout",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kReSustainabilityRed,
                            fontFamily: "ARIAL",
                            fontSize: 9.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<String> getStringValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.getString(key) ?? "";
  }

  logoutAPICall(String sessionId) async {
    var headers = {'Content-Type': 'application/json', 'Cookie': sessionId};
    var request = http.Request('GET', Uri.parse(LOGOUT));
    request.body = json.encode({});
    request.headers.addAll(headers);
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      CustomSharedPref.setPref<bool>(SharedPreferencesString.isLoggedIn, false);
      CustomSharedPref.setPref<String>(SharedPreferencesString.userId, "");
      CustomSharedPref.setPref<String>(SharedPreferencesString.emailId, "");
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) => const LoginPage(),
        ),
        (Route route) => false,
      );
    } else {
      if (kDebugMode) {
        print(response.reasonPhrase);
      }
    }
  }

  googleLogout() async {
    GoogleSignIn _googleSignIn = GoogleSignIn();
    try {
      CustomSharedPref.setPref<bool>(SharedPreferencesString.isLoggedIn, false);
      CustomSharedPref.setPref<String>(SharedPreferencesString.userId, "");
      CustomSharedPref.setPref<String>(SharedPreferencesString.emailId, "");
      _googleSignIn.disconnect();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) => const LoginPage(),
        ),
        (Route route) => false,
      );
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  showLogoutAlertDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      style: TextButton.styleFrom(
        foregroundColor: kReSustainabilityRed,
      ),
      child: const Text("No"),
      onPressed: () {
        Navigator.of(context).pop('dialog');
      },
    );
    Widget continueButton = TextButton(
      style: TextButton.styleFrom(
        foregroundColor: kReSustainabilityRed,
      ),
      child: const Text("Yes"),
      onPressed: () {
        Navigator.of(context).pop();
        showDialog(
            useRootNavigator: false,
            barrierDismissible: false,
            context: context,
            builder: (_) => LogOutLoader());
        MySharedPreferences.instance
            .getCityStringValue('JSESSIONID')
            .then((session) async {
          MySharedPreferences.instance
              .getCityStringValue('GOOGLE_TOKEN')
              .then((google_token) async {
            if (google_token != "") {
              googleLogout();
            } else {
              logoutAPICall(session);
            }
          });
        });
      },
    );
    AlertDialog alert = AlertDialog(
      title: const Text("Logout"),
      content: const Text("Are you sure you want to logout?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      useRootNavigator: false,
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  InkWell _drawerItem({
    // required String image,
    required String text,
    required Function onTap,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        key: const ValueKey('drawerContainerKey'),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        height: 4.5.h,
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              color: Colors.white,
              size: 2.h,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              text,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'ARIAL'),
            )
          ],
        ),
      ),
    );
  }
}