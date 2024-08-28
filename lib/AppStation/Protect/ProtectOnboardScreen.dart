import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:recase/recase.dart';
import 'package:resus_test/Utility/internetCheck.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../Screens/components/custom_circular_indicator.dart';
import '../../Screens/components/round_icon_button.dart';
import '../../Screens/home/home.dart';
import '../../Utility/MySharedPreferences.dart';
import '../../Utility/api_Url.dart';
import '../../Utility/shared_preferences_string.dart';
import '../../Utility/showLoader.dart';
import '../../Utility/utils/constants.dart';
import '../../custom_sharedPreference.dart';
import 'Incident_report/inbox.dart';
import 'Incident_report/incident_tabview_screen.dart';
import 'Incident_report/outbox.dart';

class ProtectOnboard extends StatefulWidget {
  const ProtectOnboard({Key? key}) : super(key: key);

  @override
  State<ProtectOnboard> createState() => _ProtectOnboardState();
}

class _ProtectOnboardState extends State<ProtectOnboard> {
  int _all_irm = 0;
  int _active_irm = 0;
  int _inActive_irm = 0;
  int _not_assigned = 0;

  String userID = '';

  bool isDeviceConnected = false;
  bool isAlertSet = false;

  GoogleSignInAccount? m_googleSignInAccount;
  String m_user_id = "";
  String m_emailId = "";

  @override
  void initState() {
    getConnectivity();
    super.initState();
  }

  getInit() {
    userID = getUserID().toString();

    MySharedPreferences.instance
        .getCityStringValue('JSESSIONID')
        .then((session) async {
      getDashboardCount(session);
    });
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
                  } else {
                    getInit();
                  }
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      );

  Future<bool> checkInternetConnection() async {
    bool isConnected = true;
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isConnected = true;
      }
    } on SocketException catch (_) {
      isConnected = false;
    }
    return isConnected;
  }

  getConnectivity() async {
    isDeviceConnected =
        await Future.value(InternetCheck().checkInternetConnection())
            .timeout(const Duration(seconds: 2));
    if (!isDeviceConnected && isAlertSet == false) {
      showDialogBox();
      if (mounted == true) {
        setState(() => isAlertSet = true);
      }
    } else {
      getInit();
    }
  }

  @override
  void dispose() {
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: const Text('Please confirm',
                style: TextStyle(
                  color: kReSustainabilityRed,
                  fontFamily: "ARIAL",
                )),
            content: const Text('Do you want go back?!',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "ARIAL",
                )),
            actions: <Widget>[
              TextButton(
                child: const Text('No',
                    style: TextStyle(
                      color: kReSustainabilityRed,
                      fontFamily: "ARIAL",
                    )),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                onPressed: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Home(
                            googleSignInAccount: m_googleSignInAccount,
                            userId: m_user_id,
                            emailId: m_user_id,
                            initialSelectedIndex: 4)),
                  ),
                },
                child: const Text(
                  'Yes',
                  style: TextStyle(
                    color: kReSustainabilityRed,
                    fontFamily: "ARIAL",
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('protectContainer'),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Aayush",
          style: TextStyle(
              fontFamily: "ARIAL",
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        leading: InkWell(
            onTap: () async {
              String userId = await CustomSharedPref.getPref<String>(
                      SharedPreferencesString.userId) ??
                  '';
              String emailId = await CustomSharedPref.getPref<String>(
                      SharedPreferencesString.emailId) ??
                  '';

              // ignore: use_build_context_synchronously
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Home(
                          googleSignInAccount: null,
                          userId: userId,
                          emailId: emailId,
                          initialSelectedIndex: 4)));
            },
            child: const Icon(Icons.arrow_back_ios)),
        elevation: 0,
        backgroundColor: kReSustainabilityRed,
        actions: [
          InkWell(
            key: const Key("home_icon_btn"),
            child: const Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: Icon(Icons.home, color: Colors.white),
            ),
            onTap: () async {
              String userId = await CustomSharedPref.getPref<String>(
                      SharedPreferencesString.userId) ??
                  '';
              String emailId = await CustomSharedPref.getPref<String>(
                      SharedPreferencesString.emailId) ??
                  '';

              // ignore: use_build_context_synchronously
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Home(
                          googleSignInAccount: null,
                          userId: userId,
                          emailId: emailId,
                          initialSelectedIndex: 0)));
            },
          ),
        ],
      ),
      body: PopScope(
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          FutureBuilder(
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
                                            color: Colors.black,
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
                          FutureBuilder(
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
                                            color: Colors.grey,
                                            fontSize: 9.sp,
                                            fontFamily: 'ARIAL',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ); // your widget
                                } else {
                                  return const CircularProgressIndicator();
                                }
                              }),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      children: [
                        const Text(
                          "Total Incidents",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontFamily: 'ARIAL'),
                        ),
                        const SizedBox(height: 10),
                        RawMaterialButton(
                          key: const Key("btn_incident_screen"),
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) =>
                                        IncidentTabviewScreen(0)))
                                .then((value) => setState(() {}));
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          fillColor: kReSustainabilityRed,
                          child: SizedBox(
                            height: 4.h,
                            child: Center(
                              child: Row(
                                children: [
                                  Text(
                                    _all_irm.toString().split('.')[0],
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                    child: const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 16,
                                        color: Colors.white),
                                    onTap: () {},
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 2.h,
                ),
                Divider(
                  height: 1,
                  color: Colors.grey[350],
                ),
                SizedBox(
                  height: 2.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: [
                        const Text(
                          "Resolved",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontFamily: 'ARIAL'),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        CustomCircularIndicator(
                          radius: 65,
                          percent: 1.0,
                          lineWidth: 5,
                          line1Width: 2,
                          count: _active_irm / _all_irm * 100,
                        ),
                        RawMaterialButton(
                          key: const Key("btn_tab_view"),
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) =>
                                        IncidentTabviewScreen(2)))
                                .then((value) => setState(() {}));
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          fillColor: kReSustainabilityRed,
                          child: SizedBox(
                            height: 4.h,
                            child: Center(
                              child: Row(
                                children: [
                                  Text(
                                    _active_irm.toString().split('.')[0],
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                      child: const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      onTap: () {
                                        // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const IncidentTabview()));
                                      })
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          "In Progress",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontFamily: 'ARIAL'),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        CustomCircularIndicator(
                          radius: 65,
                          percent: 1.0,
                          lineWidth: 5,
                          line1Width: 2,
                          count: _inActive_irm / _all_irm * 100,
                        ),
                        RawMaterialButton(
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) =>
                                        IncidentTabviewScreen(1)))
                                .then((value) => setState(() {}));
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          fillColor: kReSustainabilityRed,
                          child: SizedBox(
                            height: 4.h,
                            child: Center(
                              child: Row(
                                children: [
                                  Text(
                                    _inActive_irm.toString().split('.')[0],
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                      child: const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      onTap: () {})
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          "No Reviewer",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontFamily: 'ARIAL'),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        CustomCircularIndicator(
                          radius: 65,
                          percent: 1.0,
                          lineWidth: 5,
                          line1Width: 2,
                          count: _not_assigned / _all_irm * 100,
                        ),
                        RawMaterialButton(
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) =>
                                        IncidentTabviewScreen(0)))
                                .then((value) => setState(() {}));
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          fillColor: kReSustainabilityRed,
                          child: SizedBox(
                            height: 4.h,
                            child: Center(
                              child: Row(
                                children: [
                                  Text(
                                    _not_assigned.toString().split('.')[0],
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                      child: const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 16,
                                          color: Colors.white),
                                      onTap: () {
                                        // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const IncidentTabview()));
                                      })
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 2.h,
                ),
                Divider(
                  height: 1,
                  color: Colors.grey[350],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 3.0.h),
                  child: SizedBox(
                      // color: Colors.grey.shade200,
                      height: 25.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: <Widget>[
                          Container(
                            height: 40.0,
                            width: 150.0,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Image.asset(
                              'assets/images/AYUSH_PPE.jpg',
                              scale: 0.09.h,
                              fit: BoxFit.fill,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Container(
                            height: 40.0,
                            width: 150.0,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Image.asset(
                              'assets/images/AUYUSH_ELECTRICAL-SAFETY.jpg',
                              scale: 0.09.h,
                              fit: BoxFit.fill,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Container(
                            height: 40.0,
                            width: 150.0,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Image.asset(
                              'assets/images/AYUSH_TRANSPORT-SAFETY.jpg',
                              scale: 0.09.h,
                              fit: BoxFit.fill,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Container(
                            height: 40.0,
                            width: 150.0,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Image.asset(
                              'assets/images/AYUSH_MACHINE-SAFETY.jpg',
                              scale: 0.09.h,
                              fit: BoxFit.fill,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Container(
                            height: 40.0,
                            width: 150.0,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Image.asset(
                              'assets/images/AUYUSH_LIFE-SAVING-RULES.jpg',
                              scale: 0.09.h,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.only(
              top: 10.0, left: 20, right: 20, bottom: 20.0),
          child: Row(
            children: <Widget>[
              badges.Badge(
                position: badges.BadgePosition.topEnd(top: -15, end: -15),
                badgeStyle: const badges.BadgeStyle(
                  badgeColor: Colors.green,
                ),
                badgeContent: Container(
                  width: 25,
                  height: 20,
                  alignment: Alignment.center,
                  child: Text(
                    _active_irm.toString().split('.')[0],
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                child: RoundIconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const Inbox()));
                  },
                  icon: Icons.move_to_inbox,
                  elevation: 1,
                  color: kReSustainabilityRed,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              badges.Badge(
                position: badges.BadgePosition.topEnd(top: -15, end: -15),
                badgeStyle: const badges.BadgeStyle(
                  badgeColor: Colors.green,
                ),
                badgeContent: Container(
                  width: 25,
                  height: 20,
                  alignment: Alignment.center,
                  child: Text(
                    _inActive_irm.toString().split('.')[0],
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                child: RoundIconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const Outbox()));
                  },
                  icon: Icons.outbox,
                  elevation: 1,
                  color: kReSustainabilityRed,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: RawMaterialButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                              builder: (context) => IncidentTabviewScreen(0)),
                        )
                        .then((value) => setState(() {}));
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  fillColor: kReSustainabilityRed,
                  child: SizedBox(
                    height: 48,
                    child: Center(
                      child: Text(
                        'View ' + '/ ' + 'create incident'.titleCase,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontFamily: 'ARIAL',
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  getDashboardCount(String sessionId) async {
    debugPrint(userID);
    var headers = {'Content-Type': 'application/json', "Cookie": sessionId};
    var request = http.Request('GET', Uri.parse(GET_IRM_LIST));
    request.body = json.encode({
      "user_id": userID,
    });
    request.headers.addAll(headers);
    showDialog(
        barrierDismissible: false,
        context: context,
        useRootNavigator: false,
        builder: (BuildContext context) {
          return ShowLoader();
        });
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      debugPrint(response.body);
      if (jsonDecode(response.body).isEmpty) {
        return;
      }
      if (mounted == true) {
        setState(() {
          _all_irm = int.parse(jsonDecode(response.body)[0]["all_irm"]);
          _active_irm = int.parse(jsonDecode(response.body)[0]["active_irm"]);
          _inActive_irm =
              int.parse(jsonDecode(response.body)[0]["inActive_irm"]);
          _not_assigned =
              int.parse(jsonDecode(response.body)[0]["not_assigned"]);
        });
        debugPrint("all_irm: $_all_irm");
        debugPrint("active_irm: $_active_irm");
        debugPrint("inActive_irm: $_inActive_irm");
        debugPrint("not_assigned: $_not_assigned");
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<String> getStringValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.getString(key) ?? "";
  }

  Future<String> getUserID() async {
    return MySharedPreferences.instance.getCityStringValue('user_id');
  }
}
