import 'dart:async';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:resus_test/AppStation/Iris/Department_Screen.dart';
import 'package:resus_test/AppStation/widgets/complyone.dart';
import 'package:resus_test/AppStation/widgets/new_app_station_widget.dart';
import 'package:resus_test/AppStation/widgets/re_learning.dart';
import 'package:resus_test/Utility/internetCheck.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../Utility/utils/constants.dart';
import 'Brainbox/brainbox_onboard_screen.dart';
import 'Iris/model/iris_home_model.dart';
import 'Protect/ProtectOnboardScreen.dart';

class NewAppStation extends StatefulWidget {
  const NewAppStation({Key? key}) : super(key: key);

  @override
  State<NewAppStation> createState() => _NewAppStationState();
}

class _NewAppStationState extends State<NewAppStation> {
  TextEditingController searchController = TextEditingController();

  bool isDeviceConnected = false;
  bool isAlertSet = false;

  GoogleSignInAccount? m_googleSignInAccount;
  String m_user_id = "";
  String m_emailId = "";

  late List<NewAppStationItemWidget> listAppStation = [];
  List<NewAppStationItemWidget> itemsAppStation = [];
  late IRISHomeRequestModel irisHomeRequestModel;

  @override
  void initState() {
    getConnectivity();
    super.initState();
    irisHomeRequestModel = IRISHomeRequestModel();
  }

  showDialogBox() => showCupertinoDialog<String>(
        barrierDismissible: false,
        context: context,
        useRootNavigator: false,
        builder: (BuildContext context) => PopScope(
          canPop: false,
          child: CupertinoAlertDialog(
            title: const Text('No Connection'),
            content: const Text('Please check your internet connectivity'),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  Navigator.pop(context, 'Cancel');
                  if (mounted == true) {
                    setState(() => isAlertSet = false);
                  }
                  isDeviceConnected = await Future.value(
                          InternetCheck().checkInternetConnection())
                      .timeout(const Duration(seconds: 2));
                  if (!isDeviceConnected && isAlertSet == false) {
                    showDialogBox();
                    if (mounted == true) {
                      setState(() => isAlertSet = true);
                    }
                  }
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      );

  getConnectivity() async {
    isDeviceConnected =
        await Future.value(InternetCheck().checkInternetConnection())
            .timeout(const Duration(seconds: 2));
    if (!isDeviceConnected && isAlertSet == false) {
      showDialogBox();
      setState(() => isAlertSet = true);
    }
  }

  @override
  void dispose() {
    // subscriptionAppStation.pause();
    super.dispose();
  }

  Future<bool?> _showBackDialog() {
    return showDialog<bool>(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text("Confirm Exit",
                style: TextStyle(
                  fontFamily: 'ARIAL',
                )),
            content: const Text("Are you sure you want to exit?",
                style: TextStyle(
                  fontFamily: 'ARIAL',
                )),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  "YES",
                  style: TextStyle(
                    color: kReSustainabilityRed,
                    fontFamily: 'ARIAL',
                  ),
                ),
                onPressed: () {
                  SystemNavigator.pop();
                },
              ),
              TextButton(
                child: const Text("NO",
                    style: TextStyle(
                      color: kReSustainabilityRed,
                      fontFamily: 'ARIAL',
                    )),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        _showBackDialog().then((value) {
          if (value != null && value) {
            Navigator.of(context).pop();
          }
        });
      },
      child: Scaffold(
        key: const ValueKey('appStationContainer'),
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xfffafafa),
        body: Stack(
          key: const ValueKey('appStationContainer1'),
          children: [
            Stack(
              children: [
                Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(
                            top: 40.0, right: 20, left: 20),
                        child: TextField(
                          style: const TextStyle(color: kReSustainabilityRed),
                          cursorColor: kReSustainabilityRed,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: const BorderSide(
                                  color: kReSustainabilityRed, width: 0.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide(
                                  color: Colors.grey[400]!, width: 0.5),
                            ),
                            border: const UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: kReSustainabilityRed),
                            ),
                            hintText: 'Search..',
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: kReSustainabilityRed),
                            contentPadding: const EdgeInsets.fromLTRB(
                                20.0, 15.0, 20.0, 15.0),
                          ),
                          onChanged: (value) {
                            // filterSearchResults(value.toLowerCase());
                          },
                          controller: searchController,
                        )),
                    SizedBox(
                      height: 3.h,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: Center(
                          child: ListView(
                            children: <Widget>[
                              NewAppStationItemWidget(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ProtectOnboard(),
                                    ),
                                  );
                                },
                                image: 'new_protect',
                                // image: 'AAYUSH LOGO_02-01',
                                label: 'Aayush',
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              NewAppStationItemWidget(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BrainboxOnboardScreen(
                                                  googleSignInAccount:
                                                      m_googleSignInAccount,
                                                  userId: m_user_id,
                                                  emailId: m_emailId,
                                                  initialSelectedIndex: 4)));
                                },
                                image: 'new_brainbox',
                                label: 'Brain Box',
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              NewAppStationItemWidget(
                                onTap: () async {
                                  var openAppResult = await LaunchApp.openApp(
                                    androidPackageName:
                                        'com.darwinbox.darwinbox',
                                    appStoreLink:
                                        'https://play.google.com/store/apps/details?id=com.darwinbox.darwinbox',
                                    // openStore: false
                                  );
                                  if (kDebugMode) {
                                    print(
                                        'openAppResult => $openAppResult ${openAppResult.runtimeType}');
                                  }
                                },
                                image: 'new_darwinbox',
                                label: 'Darwinbox',
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              NewAppStationItemWidget(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ReLearning()));
                                },
                                image: 'new_relearning',
                                label: 'Relearning',
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              NewAppStationItemWidget(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Complyone()));
                                },
                                image: 'new_complyone',
                                label: 'Complyone',
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              NewAppStationItemWidget(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const DepartmentScreen()));
                                },
                                image: 'new_iris',
                                label: 'IRIS',
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<String> getStringValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.getString(key) ?? "";
  }
}
