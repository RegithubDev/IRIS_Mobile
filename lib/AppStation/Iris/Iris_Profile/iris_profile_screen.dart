import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../../Screens/home/home.dart';
import '../../../Utility/MySharedPreferences.dart';
import '../../../Utility/confirmationDialogBox.dart';
import '../../../Utility/progressHUD.dart';
import '../../../Utility/shared_preferences_string.dart';
import '../../../Utility/utils/constants.dart';
import '../../../custom_sharedPreference.dart';
import '../api/iris_update_profile_api_service.dart';
import '../iris_home_screen.dart';
import '../model/iris_profile_model.dart';
import 'history_screen.dart';

class IrisProfileScreen extends StatefulWidget {
  const IrisProfileScreen({super.key});

  @override
  State<IrisProfileScreen> createState() => _IrisProfileScreenState();
}

class _IrisProfileScreenState extends State<IrisProfileScreen> {
  bool phoneReadOnly = true;
  bool isApiCallProcess = false;

  late SharedPreferences prefs;
  String sbuCode = "";

  late StreamSubscription subscriptionIrisProfile;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  bool isMswExpanded = false;
  bool collectedWaste = false;
  bool processedWaste = false;
  bool distributeWaste = false;

  bool isIwmExpanded = false;
  bool allIwm = false;
  bool openStock = false;
  bool receipt = false;
  bool disposal = false;
  bool closeStock = false;

  bool isSubmitVisible = false;
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  late IRISProfileRequestModel _irisProfileRequestModel;
  final TextEditingController _mobileNoController = TextEditingController();

  @override
  void initState() {
    isMswExpanded = false;
    collectedWaste = false;
    processedWaste = false;
    distributeWaste = false;
    getPrefs();
    super.initState();
    _irisProfileRequestModel = IRISProfileRequestModel();
  }

  getPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      sbuCode = prefs.getString("IRIS_SBU_CODE").toString();
    });
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
      child: ProgressHUD(
        inAsyncCall: isApiCallProcess,
        opacity: 0.3,
        child: _uiSetup(context),
      ),
    );
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
            content: const Text('Do you want go back to Iris Home Screen!',
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
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => IrisHomeScreen(
                              sbuCode: prefs.getString("selectSBU").toString(),
                              userRole: prefs.getString("roleName").toString(),
                              departmentName:
                                  prefs.getString("department").toString())))
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

  Widget _uiSetup(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Account Info",
          style: TextStyle(
              fontFamily: "ARIAL",
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        leading: InkWell(
            onTap: () async {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IrisHomeScreen(
                        sbuCode: prefs.getString("selectSBU").toString(),
                        userRole: prefs.getString("roleName").toString(),
                        departmentName:
                            prefs.getString("department").toString()),
                  ));
            },
            child: const Icon(Icons.arrow_back_ios)),
        elevation: 0,
        backgroundColor: kReSustainabilityRed,
        actions: [
          InkWell(
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Image.asset(
                "assets/icons/home.png",
                height: 25.0,
                width: 25.0,
              ),
            ),
            onTap: () async {
              String userId = await CustomSharedPref.getPref<String>(
                      SharedPreferencesString.userId) ??
                  '';
              String emailId = await CustomSharedPref.getPref<String>(
                      SharedPreferencesString.emailId) ??
                  '';

              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Home(
                          googleSignInAccount: null,
                          userId: userId,
                          emailId: emailId,
                          initialSelectedIndex: 0)));
            },
          )
        ],
      ),
      body: Stack(
        key: const ValueKey('appStationContainer1'),
        children: [
          Stack(
            children: [
              SingleChildScrollView(
                child: Form(
                  key: globalFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 20.0),
                                      child: CircleAvatar(
                                        radius: 6.h,
                                        backgroundColor:
                                            const Color(0xffD9D9D9),
                                        child: FutureBuilder(
                                            future: getStringValue('user_name'),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<String>
                                                    snapshot) {
                                              if (snapshot.hasData) {
                                                return Text(
                                                  snapshot.data
                                                      .toString()[0]
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 40.sp,
                                                    fontFamily: 'ARIAL',
                                                    fontWeight: FontWeight
                                                        .bold, // italic
                                                  ),
                                                );
                                                // your widget
                                              } else {
                                                return const CircularProgressIndicator();
                                              }
                                            }),
                                      ),
                                    ),
                                    const SizedBox(height: 5.0),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 20.0),
                                      child: FutureBuilder<String>(
                                          future: getUserName(),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<String> snapshot) {
                                            if (snapshot.hasData) {
                                              return Text(
                                                "${snapshot.data}",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13.sp,
                                                    fontFamily: 'ARIAL',
                                                    fontWeight: FontWeight
                                                        .normal, // italic
                                                    letterSpacing: 1.0),
                                                textAlign: TextAlign.center,
                                              );
                                            } else {
                                              return const Text("");
                                            }
                                          }),
                                    )
                                  ]),
                                ]),
                            const SizedBox(
                              width: 20,
                            ),
                            const SizedBox(
                              height: 20,
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Column(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 8.h,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10.0, bottom: 10.0),
                                    child: Container(
                                        height: 5.h,
                                        width: 0.4.h,
                                        decoration: BoxDecoration(
                                          color: kReSustainabilityRed,
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        )),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width - 45,
                                    height: 7.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          offset: const Offset(0,
                                              3), // Horizontal offset is 0, vertical offset is positive
                                        ),
                                      ],
                                    ),
                                    child: Row(children: [
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15.0),
                                          child: CircleAvatar(
                                              radius: 2.h,
                                              backgroundColor:
                                                  const Color(0xffD9D9D9),
                                              child: Image.asset(
                                                "assets/icons/phone-call_profile_icon.png",
                                                width: 20,
                                                height: 20,
                                              ))),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20.0),
                                        child: FutureBuilder<String>(
                                            future: getPhoneNumber(),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<String>
                                                    snapshot) {
                                              if (snapshot.hasData) {
                                                return Text(
                                                  snapshot.data.toString(),
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12.sp,
                                                      fontFamily: 'ARIAL',
                                                      fontWeight: FontWeight
                                                          .normal, // italic
                                                      letterSpacing: 1.0),
                                                  textAlign: TextAlign.center,
                                                );
                                              } else {
                                                return const Text(
                                                    "No Phone Found");
                                              }
                                            }),
                                      ),
                                    ]),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 2.h),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 8.h,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10.0, bottom: 10.0),
                                    child: Container(
                                        height: 5.h,
                                        width: 0.4.h,
                                        decoration: BoxDecoration(
                                          color: kReSustainabilityRed,
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        )),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width - 45,
                                    height: 7.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          offset: const Offset(0,
                                              3), // Horizontal offset is 0, vertical offset is positive
                                        ),
                                      ],
                                    ),
                                    child: Row(children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 15.0),
                                        child: CircleAvatar(
                                            radius: 2.h,
                                            backgroundColor:
                                                const Color(0xffD9D9D9),
                                            child: Image.asset(
                                              "assets/icons/mail_profile_icon.png",
                                              width: 20,
                                              height: 20,
                                            )),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20.0,
                                              top: 5.0,
                                              bottom: 5.0,
                                              right: 10.0),
                                          child: FutureBuilder<String>(
                                              future: getEmail(),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<String>
                                                      snapshot) {
                                                if (snapshot.hasData) {
                                                  final emailText =
                                                      snapshot.data.toString();
                                                  final checkLength =
                                                      emailText.length;
                                                  return TextFormField(
                                                    readOnly: true,
                                                    decoration: InputDecoration(
                                                      enabledBorder:
                                                          InputBorder.none,
                                                      border: InputBorder.none,
                                                      hintText: checkLength > 35
                                                          ? emailText.replaceAll(
                                                              '@resustainability.com',
                                                              '\n@resustainability.com')
                                                          : emailText,
                                                      hintMaxLines:
                                                          checkLength > 35
                                                              ? 2
                                                              : 1,
                                                      hintStyle: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 12.sp,
                                                          fontFamily: 'ARIAL',
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          letterSpacing: 0.5),
                                                    ),
                                                  );
                                                } else {
                                                  return const Text(
                                                      "No Email Found");
                                                }
                                              }),
                                        ),
                                      ),
                                    ]),
                                  ),
                                ],
                              ),
                            ),
                            sbuCode.contains("BMW")
                                ? SizedBox(height: 2.h)
                                : const SizedBox(),
                            sbuCode.contains("BMW")
                                ? SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 8.h,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10.0, bottom: 10.0),
                                          child: Container(
                                              height: 5.h,
                                              width: 0.4.h,
                                              decoration: BoxDecoration(
                                                color: kReSustainabilityRed,
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              )),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              isMswExpanded = false;
                                              isIwmExpanded = false;
                                            });
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const HistoryScreen(
                                                            sbuCode: "BMW")));
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                45,
                                            height: 7.h,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 1,
                                                  blurRadius: 3,
                                                  offset: const Offset(0,
                                                      3), // Horizontal offset is 0, vertical offset is positive
                                                ),
                                              ],
                                            ),
                                            child: Row(children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 15.0),
                                                child: CircleAvatar(
                                                  radius: 2.h,
                                                  backgroundColor:
                                                      const Color(0xffD9D9D9),
                                                  child: Image.asset(
                                                      "assets/icons/bmw.png",
                                                      width: 20,
                                                      height: 20),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 20.0),
                                                child: Text(
                                                  "BMW",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12.sp,
                                                      fontFamily: 'ARIAL',
                                                      fontWeight: FontWeight
                                                          .normal, // italic
                                                      letterSpacing: 0.5),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              const Spacer(),
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(right: 5.0),
                                                child: Icon(
                                                  size: 20.0,
                                                  Icons.arrow_forward_ios,
                                                  color: kColorBlack,
                                                ),
                                              ),
                                            ]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox(),
                            sbuCode.contains("MSW")
                                ? SizedBox(
                                    height: 2.h,
                                  )
                                : const SizedBox(),
                            sbuCode.contains("MSW")
                                ? SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 8.h,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10.0, bottom: 10.0),
                                          child: Container(
                                              height: 5.h,
                                              width: 0.4.h,
                                              decoration: BoxDecoration(
                                                color: kReSustainabilityRed,
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              )),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              isMswExpanded = false;
                                              isIwmExpanded = false;
                                            });
                                            // Navigator.push(
                                            //     context,
                                            //     MaterialPageRoute(
                                            //         builder: (context) =>
                                            //             WteHistory(sbuCode: prefs.get('selectSBU').toString())));
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                45,
                                            height: 7.h,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 1,
                                                  blurRadius: 3,
                                                  offset: const Offset(0,
                                                      3), // Horizontal offset is 0, vertical offset is positive
                                                ),
                                              ],
                                            ),
                                            child: Row(children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 15.0),
                                                child: CircleAvatar(
                                                    radius: 2.h,
                                                    backgroundColor:
                                                        const Color(0xffD9D9D9),
                                                    child: Image.asset(
                                                        "assets/icons/wte_profile_icon.png",
                                                        width: 26,
                                                        height: 26)),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 20.0),
                                                child: Text(
                                                  "WTE",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12.sp,
                                                      fontFamily: 'ARIAL',
                                                      fontWeight: FontWeight
                                                          .normal, // italic
                                                      letterSpacing: 0.5),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              const Spacer(),
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(right: 5.0),
                                                child: Icon(
                                                  size: 20.0,
                                                  Icons.arrow_forward_ios,
                                                  color: kColorBlack,
                                                ),
                                              ),
                                            ]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox(),
                            sbuCode.contains("MSW")
                                ? SizedBox(
                                    height: 2.h,
                                  )
                                : const SizedBox(),
                            sbuCode.contains("MSW")
                                ? SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: isMswExpanded == false ? 8.h : 30.h,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        isMswExpanded == false
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10.0, bottom: 10.0),
                                                child: Container(
                                                    height: 5.5.h,
                                                    width: 0.4.h,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          kReSustainabilityRed,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0),
                                                    )),
                                              )
                                            : const SizedBox(),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              45,
                                          height: isMswExpanded == false
                                              ? 8.h
                                              : 30.h,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 1,
                                                blurRadius: 3,
                                                offset: const Offset(0,
                                                    3), // Horizontal offset is 0, vertical offset is positive
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10.0),
                                            child: Column(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    if (isMswExpanded ==
                                                        false) {
                                                      setState(() {
                                                        isMswExpanded = true;
                                                        isIwmExpanded = false;
                                                        collectedWaste = false;
                                                        processedWaste = false;
                                                        distributeWaste = false;
                                                      });
                                                    } else {
                                                      setState(() {
                                                        isMswExpanded = false;
                                                        collectedWaste = false;
                                                        processedWaste = false;
                                                        distributeWaste = false;
                                                      });
                                                    }
                                                  },
                                                  child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 15.0,
                                                                  top: 3.0),
                                                          child: CircleAvatar(
                                                              radius: 2.h,
                                                              backgroundColor:
                                                                  const Color(
                                                                      0xffD9D9D9),
                                                              child:
                                                                  Image.asset(
                                                                "assets/icons/msw.png",
                                                                width: 22,
                                                                height: 22,
                                                              )),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 20.0,
                                                                  top: 10.0),
                                                          child: Text(
                                                            "MSW",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12.sp,
                                                                fontFamily:
                                                                    'ARIAL',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal, // italic
                                                                letterSpacing:
                                                                    0.5),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 5.0),
                                                            child:
                                                                isMswExpanded ==
                                                                        false
                                                                    ? const Icon(
                                                                        size:
                                                                            35.0,
                                                                        Icons
                                                                            .keyboard_arrow_down,
                                                                        color:
                                                                            kColorBlack,
                                                                      )
                                                                    : const Icon(
                                                                        size:
                                                                            35.0,
                                                                        Icons
                                                                            .keyboard_arrow_up,
                                                                        color:
                                                                            kColorBlack,
                                                                      )),
                                                      ]),
                                                ),
                                                SizedBox(
                                                  height: 1.h,
                                                ),
                                                isMswExpanded == true
                                                    ? Column(
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () async {
                                                              setState(() {
                                                                distributeWaste =
                                                                    false;
                                                                processedWaste =
                                                                    false;
                                                                collectedWaste =
                                                                    true;
                                                              });
                                                              // await Future.delayed(const Duration(milliseconds: 400)).then((value) {
                                                              //   return Navigator.push(
                                                              //     context,
                                                              //     MaterialPageRoute(
                                                              //       builder: (context) => MswCollectionHistoryScreen(sbuCode: prefs.get('selectSBU').toString()),
                                                              //     ),
                                                              //   );
                                                              // });
                                                            },
                                                            child: Row(
                                                              children: [
                                                                collectedWaste ==
                                                                        true
                                                                    ? Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                10.0,
                                                                            bottom:
                                                                                10.0),
                                                                        child: Container(
                                                                            height: 4.h,
                                                                            width: 0.4.h,
                                                                            decoration: BoxDecoration(
                                                                              color: kReSustainabilityRed,
                                                                              borderRadius: BorderRadius.circular(20.0),
                                                                            )),
                                                                      )
                                                                    : const SizedBox(),
                                                                Container(
                                                                  width: MediaQuery.sizeOf(
                                                                              context)
                                                                          .width -
                                                                      50,
                                                                  height: 6.h,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: collectedWaste ==
                                                                            true
                                                                        ? kSelectDropdown
                                                                        : Colors
                                                                            .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            65.0,
                                                                        top:
                                                                            0.0),
                                                                    child:
                                                                        Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
                                                                        "Collected Waste",
                                                                        style: TextStyle(
                                                                            color: Colors.black,
                                                                            fontSize: 12.sp,
                                                                            fontFamily: 'ARIAL',
                                                                            fontWeight: FontWeight.normal, // italic
                                                                            letterSpacing: 0.5),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () async {
                                                              setState(() {
                                                                distributeWaste =
                                                                    false;
                                                                processedWaste =
                                                                    true;
                                                                collectedWaste =
                                                                    false;
                                                              });
                                                              // await Future.delayed(const Duration(milliseconds: 400)).then((value) {
                                                              //   return Navigator.push(
                                                              //     context,
                                                              //     MaterialPageRoute(
                                                              //       builder: (context) => const MswProcessingHistoryScreen(),
                                                              //     ),
                                                              //   );
                                                              // });
                                                            },
                                                            child: Row(
                                                              children: [
                                                                processedWaste ==
                                                                        true
                                                                    ? Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                10.0,
                                                                            bottom:
                                                                                10.0),
                                                                        child: Container(
                                                                            height: 4.h,
                                                                            width: 0.4.h,
                                                                            decoration: BoxDecoration(
                                                                              color: kReSustainabilityRed,
                                                                              borderRadius: BorderRadius.circular(20.0),
                                                                            )),
                                                                      )
                                                                    : const SizedBox(),
                                                                Container(
                                                                  width: MediaQuery.sizeOf(
                                                                              context)
                                                                          .width -
                                                                      50,
                                                                  height: 6.h,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: processedWaste ==
                                                                            true
                                                                        ? kSelectDropdown
                                                                        : Colors
                                                                            .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            65.0,
                                                                        top:
                                                                            0.0),
                                                                    child:
                                                                        Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
                                                                        "Processed Waste",
                                                                        style: TextStyle(
                                                                            color: Colors.black,
                                                                            fontSize: 12.sp,
                                                                            fontFamily: 'ARIAL',
                                                                            fontWeight: FontWeight.normal, // italic
                                                                            letterSpacing: 0.5),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () async {
                                                              setState(() {
                                                                distributeWaste =
                                                                    true;
                                                                processedWaste =
                                                                    false;
                                                                collectedWaste =
                                                                    false;
                                                              });
                                                              // await Future.delayed(const Duration(milliseconds: 400)).then((value) {
                                                              //   return Navigator.push(
                                                              //     context,
                                                              //     MaterialPageRoute(
                                                              //       builder: (context) => const MswDistributeHistoryScreen(),
                                                              //     ),
                                                              //   );
                                                              // });
                                                            },
                                                            child: Row(
                                                              children: [
                                                                distributeWaste ==
                                                                        true
                                                                    ? Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                10.0,
                                                                            bottom:
                                                                                10.0),
                                                                        child: Container(
                                                                            height: 4.h,
                                                                            width: 0.4.h,
                                                                            decoration: BoxDecoration(
                                                                              color: kReSustainabilityRed,
                                                                              borderRadius: BorderRadius.circular(20.0),
                                                                            )),
                                                                      )
                                                                    : const SizedBox(),
                                                                Container(
                                                                  width: MediaQuery.sizeOf(
                                                                              context)
                                                                          .width -
                                                                      50,
                                                                  height: 6.h,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: distributeWaste ==
                                                                            true
                                                                        ? kSelectDropdown
                                                                        : Colors
                                                                            .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            65.0,
                                                                        top:
                                                                            0.0),
                                                                    child:
                                                                        Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
                                                                        "Distributed Waste",
                                                                        style: TextStyle(
                                                                            color: Colors.black,
                                                                            fontSize: 12.sp,
                                                                            fontFamily: 'ARIAL',
                                                                            fontWeight: FontWeight.normal, // italic
                                                                            letterSpacing: 0.5),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                    : const SizedBox(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox(),
                            sbuCode.contains("IWM")
                                ? SizedBox(
                                    height: 2.h,
                                  )
                                : const SizedBox(),
                            sbuCode.contains("IWM")
                                ? SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: isIwmExpanded == false ? 8.h : 42.h,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        isIwmExpanded == false
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10.0, bottom: 10.0),
                                                child: Container(
                                                    height: 5.5.h,
                                                    width: 0.4.h,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          kReSustainabilityRed,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0),
                                                    )),
                                              )
                                            : const SizedBox(),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              45,
                                          height: isIwmExpanded == false
                                              ? 8.h
                                              : 42.h,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 1,
                                                blurRadius: 3,
                                                offset: const Offset(0,
                                                    3), // Horizontal offset is 0, vertical offset is positive
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10.0),
                                            child: Column(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    if (isIwmExpanded ==
                                                        false) {
                                                      setState(() {
                                                        isIwmExpanded = true;
                                                        isMswExpanded = false;
                                                        openStock = false;
                                                        receipt = false;
                                                        disposal = false;
                                                        closeStock = false;
                                                        allIwm = false;
                                                      });
                                                    } else {
                                                      setState(() {
                                                        isIwmExpanded = false;
                                                        openStock = false;
                                                        receipt = false;
                                                        disposal = false;
                                                        closeStock = false;
                                                        allIwm = false;
                                                      });
                                                    }
                                                  },
                                                  child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 15.0,
                                                                  top: 3.0),
                                                          child: CircleAvatar(
                                                              radius: 2.h,
                                                              backgroundColor:
                                                                  const Color(
                                                                      0xffD9D9D9),
                                                              child: Image.asset(
                                                                  "assets/icons/iwm.png",
                                                                  width: 20,
                                                                  height: 20)),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 20.0,
                                                                  top: 10.0),
                                                          child: Text(
                                                            "IWM",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12.sp,
                                                                fontFamily:
                                                                    'ARIAL',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal, // italic
                                                                letterSpacing:
                                                                    0.5),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 5.0),
                                                            child:
                                                                isIwmExpanded ==
                                                                        false
                                                                    ? const Icon(
                                                                        size:
                                                                            35.0,
                                                                        Icons
                                                                            .keyboard_arrow_down,
                                                                        color:
                                                                            kColorBlack,
                                                                      )
                                                                    : const Icon(
                                                                        size:
                                                                            35.0,
                                                                        Icons
                                                                            .keyboard_arrow_up,
                                                                        color:
                                                                            kColorBlack,
                                                                      )),
                                                      ]),
                                                ),
                                                SizedBox(
                                                  height: 1.h,
                                                ),
                                                isIwmExpanded == true
                                                    ? Column(
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () async {
                                                              setState(() {
                                                                receipt = false;
                                                                disposal =
                                                                    false;
                                                                openStock =
                                                                    false;
                                                                closeStock =
                                                                    false;
                                                                allIwm = true;
                                                              });
                                                              // await Future.delayed(const Duration(milliseconds: 400)).then((value) {
                                                              //   return Navigator.push(
                                                              //     context,
                                                              //     MaterialPageRoute(
                                                              //       builder: (context) => const MswProcessingHistoryScreen(),
                                                              //     ),
                                                              //   );
                                                              // });
                                                            },
                                                            child: Row(
                                                              children: [
                                                                allIwm == true
                                                                    ? Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                10.0,
                                                                            bottom:
                                                                                10.0),
                                                                        child: Container(
                                                                            height: 4.h,
                                                                            width: 0.4.h,
                                                                            decoration: BoxDecoration(
                                                                              color: kReSustainabilityRed,
                                                                              borderRadius: BorderRadius.circular(20.0),
                                                                            )),
                                                                      )
                                                                    : const SizedBox(),
                                                                Container(
                                                                  width: MediaQuery.sizeOf(
                                                                              context)
                                                                          .width -
                                                                      50,
                                                                  height: 6.h,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: allIwm ==
                                                                            true
                                                                        ? kSelectDropdown
                                                                        : Colors
                                                                            .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            65.0,
                                                                        top:
                                                                            0.0),
                                                                    child:
                                                                        Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
                                                                        "IWM Overall Summary",
                                                                        style: TextStyle(
                                                                            color: Colors.black,
                                                                            fontSize: 12.sp,
                                                                            fontFamily: 'ARIAL',
                                                                            fontWeight: FontWeight.normal, // italic
                                                                            letterSpacing: 0.5),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () async {
                                                              setState(() {
                                                                closeStock =
                                                                    false;
                                                                receipt = false;
                                                                disposal =
                                                                    false;
                                                                openStock =
                                                                    true;
                                                                allIwm = false;
                                                              });
                                                              // await Future.delayed(Duration(milliseconds: 400)).then((value) {
                                                              //   return Navigator.push(
                                                              //     context,
                                                              //     MaterialPageRoute(
                                                              //       builder: (context) => MswCollectionHistoryScreen(sbuCode: prefs.get('selectSBU').toString()),
                                                              //     ),
                                                              //   );
                                                              // });
                                                            },
                                                            child: Row(
                                                              children: [
                                                                openStock ==
                                                                        true
                                                                    ? Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                10.0,
                                                                            bottom:
                                                                                10.0),
                                                                        child: Container(
                                                                            height: 4.h,
                                                                            width: 0.4.h,
                                                                            decoration: BoxDecoration(
                                                                              color: kReSustainabilityRed,
                                                                              borderRadius: BorderRadius.circular(20.0),
                                                                            )),
                                                                      )
                                                                    : const SizedBox(),
                                                                Container(
                                                                  width: MediaQuery.sizeOf(
                                                                              context)
                                                                          .width -
                                                                      50,
                                                                  height: 6.h,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: openStock ==
                                                                            true
                                                                        ? kSelectDropdown
                                                                        : Colors
                                                                            .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            65.0,
                                                                        top:
                                                                            0.0),
                                                                    child:
                                                                        Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
                                                                        "Opening Stock",
                                                                        style: TextStyle(
                                                                            color: Colors.black,
                                                                            fontSize: 12.sp,
                                                                            fontFamily: 'ARIAL',
                                                                            fontWeight: FontWeight.normal, // italic
                                                                            letterSpacing: 0.5),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () async {
                                                              setState(() {
                                                                receipt = true;
                                                                disposal =
                                                                    false;
                                                                openStock =
                                                                    false;
                                                                closeStock =
                                                                    false;
                                                                allIwm = false;
                                                              });
                                                              // await Future.delayed(const Duration(milliseconds: 400)).then((value) {
                                                              //   return Navigator.push(
                                                              //     context,
                                                              //     MaterialPageRoute(
                                                              //       builder: (context) => const MswDistributeHistoryScreen(),
                                                              //     ),
                                                              //   );
                                                              // });
                                                            },
                                                            child: Row(
                                                              children: [
                                                                receipt == true
                                                                    ? Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                10.0,
                                                                            bottom:
                                                                                10.0),
                                                                        child: Container(
                                                                            height: 4.h,
                                                                            width: 0.4.h,
                                                                            decoration: BoxDecoration(
                                                                              color: kReSustainabilityRed,
                                                                              borderRadius: BorderRadius.circular(20.0),
                                                                            )),
                                                                      )
                                                                    : const SizedBox(),
                                                                Container(
                                                                  width: MediaQuery.sizeOf(
                                                                              context)
                                                                          .width -
                                                                      50,
                                                                  height: 6.h,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: receipt ==
                                                                            true
                                                                        ? kSelectDropdown
                                                                        : Colors
                                                                            .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            65.0,
                                                                        top:
                                                                            0.0),
                                                                    child:
                                                                        Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
                                                                        "Receipt",
                                                                        style: TextStyle(
                                                                            color: Colors.black,
                                                                            fontSize: 12.sp,
                                                                            fontFamily: 'ARIAL',
                                                                            fontWeight: FontWeight.normal, // italic
                                                                            letterSpacing: 0.5),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () async {
                                                              setState(() {
                                                                receipt = false;
                                                                disposal = true;
                                                                openStock =
                                                                    false;
                                                                closeStock =
                                                                    false;
                                                                allIwm = false;
                                                              });
                                                              // await Future.delayed(const Duration(milliseconds: 400)).then((value) {
                                                              //   return Navigator.push(
                                                              //     context,
                                                              //     MaterialPageRoute(
                                                              //       builder: (context) => const MswProcessingHistoryScreen(),
                                                              //     ),
                                                              //   );
                                                              // });
                                                            },
                                                            child: Row(
                                                              children: [
                                                                disposal == true
                                                                    ? Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                10.0,
                                                                            bottom:
                                                                                10.0),
                                                                        child: Container(
                                                                            height: 4.h,
                                                                            width: 0.4.h,
                                                                            decoration: BoxDecoration(
                                                                              color: kReSustainabilityRed,
                                                                              borderRadius: BorderRadius.circular(20.0),
                                                                            )),
                                                                      )
                                                                    : const SizedBox(),
                                                                Container(
                                                                  width: MediaQuery.sizeOf(
                                                                              context)
                                                                          .width -
                                                                      50,
                                                                  height: 6.h,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: disposal ==
                                                                            true
                                                                        ? kSelectDropdown
                                                                        : Colors
                                                                            .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            65.0,
                                                                        top:
                                                                            0.0),
                                                                    child:
                                                                        Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
                                                                        "Disposal",
                                                                        style: TextStyle(
                                                                            color: Colors.black,
                                                                            fontSize: 12.sp,
                                                                            fontFamily: 'ARIAL',
                                                                            fontWeight: FontWeight.normal, // italic
                                                                            letterSpacing: 0.5),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () async {
                                                              setState(() {
                                                                receipt = false;
                                                                disposal =
                                                                    false;
                                                                openStock =
                                                                    false;
                                                                closeStock =
                                                                    true;
                                                                allIwm = false;
                                                              });
                                                              // await Future.delayed(const Duration(milliseconds: 400)).then((value) {
                                                              //   return Navigator.push(
                                                              //     context,
                                                              //     MaterialPageRoute(
                                                              //       builder: (context) => const MswDistributeHistoryScreen(),
                                                              //     ),
                                                              //   );
                                                              // });
                                                            },
                                                            child: Row(
                                                              children: [
                                                                closeStock ==
                                                                        true
                                                                    ? Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                10.0,
                                                                            bottom:
                                                                                10.0),
                                                                        child: Container(
                                                                            height: 4.h,
                                                                            width: 0.4.h,
                                                                            decoration: BoxDecoration(
                                                                              color: kReSustainabilityRed,
                                                                              borderRadius: BorderRadius.circular(20.0),
                                                                            )),
                                                                      )
                                                                    : const SizedBox(),
                                                                Container(
                                                                  width: MediaQuery.sizeOf(
                                                                              context)
                                                                          .width -
                                                                      50,
                                                                  height: 6.h,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: closeStock ==
                                                                            true
                                                                        ? kSelectDropdown
                                                                        : Colors
                                                                            .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            65.0,
                                                                        top:
                                                                            0.0),
                                                                    child:
                                                                        Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
                                                                        "Closing Stock",
                                                                        style: TextStyle(
                                                                            color: Colors.black,
                                                                            fontSize: 12.sp,
                                                                            fontFamily: 'ARIAL',
                                                                            fontWeight: FontWeight.normal, // italic
                                                                            letterSpacing: 0.5),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                    : const SizedBox(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Visibility(
                        visible: isSubmitVisible,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0, right: 20),
                          child: GestureDetector(
                            child: Container(
                              decoration: ShapeDecoration(
                                  color: kReSustainabilityRed,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  shadows: [
                                    BoxShadow(
                                        spreadRadius: 1,
                                        blurRadius: 2,
                                        offset: const Offset(0, 2),
                                        color: Colors.grey.shade400)
                                  ]),
                              height: 6.h,
                              width: 40.w,
                              child: Center(
                                child: Text(
                                  "Submit",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                phoneReadOnly = true;
                                isSubmitVisible = false;
                              });
                              if (validateAndSave()) {
                                setState(() {
                                  isApiCallProcess = true;
                                });
                                _irisProfileRequestModel.mobileNo =
                                    _mobileNoController.text;
                                IrisUpdateProfileAPIService apiService =
                                    IrisUpdateProfileAPIService();
                                apiService
                                    .updateProfileApiCall(
                                        _irisProfileRequestModel)
                                    .then((value) {
                                  if (value == "User Updated Succesfully.") {
                                    setState(() {
                                      isApiCallProcess = false;
                                    });
                                    showDialog(
                                        useRootNavigator: false,
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return PopScope(
                                            canPop: false,
                                            child: ConfirmationDialogBox(
                                              title:
                                                  'User Updated Successfully.',
                                              press: () {
                                                Navigator.of(context).pop();
                                                // Navigator.of(context).pushReplacement(
                                                //     MaterialPageRoute(
                                                //         builder: (BuildContext
                                                //                 context) =>
                                                //             IrisHomeScreen()));
                                              },
                                              color: Colors.white,
                                              text: 'Done',
                                            ),
                                          );
                                        });
                                  }
                                });
                              } else {
                                setState(() {
                                  phoneReadOnly = false;
                                  isSubmitVisible = true;
                                });
                              }
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String> getStringValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.getString(key) ?? "";
  }

  Future<String> getPhoneNumber() async {
    return MySharedPreferences.instance.getStringValue('IRIS_MOBILE_NO');
  }

  Future<String> getUserName() {
    return MySharedPreferences.instance.getStringValue('IRIS_USER_NAME');
  }

  Future<String> getEmail() {
    return MySharedPreferences.instance.getStringValue('email_id');
  }

  bool validateAndSave() {
    final form = globalFormKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}