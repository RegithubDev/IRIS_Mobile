import 'dart:async';
import 'dart:convert';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
import 'ideas_inbox.dart';
import 'ideas_outbox.dart';
import 'ideas_tabview_screen.dart';

class BrainboxOnboardScreen extends StatefulWidget {
  final GoogleSignInAccount? googleSignInAccount;
  final String userId;
  final String emailId;
  int? initialSelectedIndex = 0;
  BrainboxOnboardScreen(
      {Key? key,
      required this.googleSignInAccount,
      required this.userId,
      required this.emailId,
      required this.initialSelectedIndex})
      : super(key: key);

  @override
  State<BrainboxOnboardScreen> createState() => _BrainboxOnboardScreenState();
}

class _BrainboxOnboardScreenState extends State<BrainboxOnboardScreen> {
  GoogleSignInAccount? m_googleSignInAccount;
  String m_user_id = "";
  String m_emailId = "";

  double allIdeas = 0.0;
  double activeIdeas = 0.0;
  double inActiveIdeas = 0.0;
  double notAssignedIdeas = 0.0;

  bool isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void initState() {
    getConnectivity();
    super.initState();
  }

  getInit() {
    MySharedPreferences.instance
        .getCityStringValue('JSESSIONID')
        .then((session) async {
      MySharedPreferences.instance
          .getCityStringValue('user_id')
          .then((userid) async {
        MySharedPreferences.instance
            .getCityStringValue('base_role')
            .then((role) async {
          getDashboardCount(session, role, userid);
        });
      });
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

  getConnectivity() async {
    isDeviceConnected =
        await Future.value(InternetCheck().checkInternetConnection())
            .timeout(const Duration(seconds: 2));
    if (!isDeviceConnected && isAlertSet == false) {
      showDialogBox();
      setState(() => isAlertSet = true);
    } else {
      getInit();
    }
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
          "Brain Box",
          style: TextStyle(
              fontFamily: "ARIAL",
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        leading: InkWell(
            onTap: () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Home(
                          googleSignInAccount: m_googleSignInAccount,
                          userId: m_user_id,
                          emailId: m_emailId,
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
                          "Total Ideas",
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
                                        IdeasTabviewScreen(0)))
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
                                    allIdeas.toString().split('.')[0],
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
                          "Ideas Implementation",
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
                          count: activeIdeas / allIdeas * 100,
                        ),
                        RawMaterialButton(
                          key: const Key("btn_tab_view"),
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) =>
                                        IdeasTabviewScreen(2)))
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
                                    activeIdeas.toString().split('.')[0],
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
                          "Ideas Evaluation",
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
                          count: notAssignedIdeas / allIdeas * 100,
                        ),
                        RawMaterialButton(
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) =>
                                        IdeasTabviewScreen(1)))
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
                                    notAssignedIdeas.toString().split('.')[0],
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
                          "Ideas Rejected",
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
                          count: inActiveIdeas / allIdeas * 100,
                        ),
                        RawMaterialButton(
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) =>
                                        IdeasTabviewScreen(0)))
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
                                    inActiveIdeas.toString().split('.')[0],
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
                      height: 37.h,
                      width: 100.w,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: <Widget>[
                          Container(
                            height: 12.h,
                            width: 300.0,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Image.asset(
                              'assets/images/brain_box_banner.jpg',
                              scale: 0.09.h,
                              fit: BoxFit.fill,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Container(
                            height: 40.0,
                            width: 300.0,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Image.asset(
                              'assets/images/brain_box_banner.jpg',
                              scale: 0.09.h,
                              fit: BoxFit.fill,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Container(
                            height: 40.0,
                            width: 300.0,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Image.asset(
                              'assets/images/brain_box_banner.jpg',
                              scale: 0.09.h,
                              fit: BoxFit.fill,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Container(
                            height: 40.0,
                            width: 300.0,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Image.asset(
                              'assets/images/brain_box_banner.jpg',
                              scale: 0.09.h,
                              fit: BoxFit.fill,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Container(
                            height: 40.0,
                            width: 320.0,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Image.asset(
                              'assets/images/brain_box_banner.jpg',
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
                    activeIdeas.toString().split('.')[0],
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                child: RoundIconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const IdeasInbox()));
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
                    notAssignedIdeas.toString().split('.')[0],
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                child: RoundIconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const IdeasOutbox()));
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
                              builder: (context) => IdeasTabviewScreen(0)),
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
                        'View ' + '/ ' + 'create Idea'.titleCase,
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

  getDashboardCount(String sessionId, String role, String userId) async {
    var headers = {'Content-Type': 'application/json', "Cookie": sessionId};
    var request = http.Request('GET', Uri.parse(GET_ALL_IDEAS_LIST));
    request.body =
        json.encode({"startIndex": "0", "role": role, "user": userId});
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
      if (jsonDecode(response.body).isEmpty) {
        return;
      }
      if (mounted == true) {
        setState(() {
          allIdeas = double.parse(jsonDecode(response.body)[0]["all_themes"]);
          activeIdeas =
              double.parse(jsonDecode(response.body)[0]["active_themes"]);
          inActiveIdeas =
              double.parse(jsonDecode(response.body)[0]["inActive_themes"]);
          notAssignedIdeas =
              double.parse(jsonDecode(response.body)[0]["counts"]);
        });
      }
    } else {
      if (kDebugMode) {
        print(response.reasonPhrase);
      }
    }
  }

  Future<String> getStringValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.getString(key) ?? "";
  }
}
