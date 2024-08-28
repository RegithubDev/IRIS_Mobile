import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:resus_test/Utility/internetCheck.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../Screens/home/home.dart';
import '../../../Utility/confirmationDialogBox.dart';
import '../../../Utility/progressHUD.dart';
import '../../../Utility/shared_preferences_string.dart';
import '../../../Utility/utils/constants.dart';
import '../../../custom_sharedPreference.dart';
import '../Iris_Profile/iris_profile_screen.dart';
import '../api/iris_collect_api_service.dart';
import '../iris_home_screen.dart';
import '../model/collect_preview_model.dart';
import '../model/iris_collect_model.dart';

class CollectPreviewScreen extends StatefulWidget {
  final CollectPreviewModel collectPreviewModel;

  const CollectPreviewScreen({super.key, required this.collectPreviewModel});

  @override
  State<CollectPreviewScreen> createState() => _CollectPreviewScreenState();
}

class _CollectPreviewScreenState extends State<CollectPreviewScreen> {
  late final TextEditingController _wasteTypeController =
      TextEditingController();
  final TextEditingController _totalWasteController = TextEditingController();
  late TextEditingController dateInputController = TextEditingController();
  final TextEditingController _siteNameController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  late CollectPreviewModel mCollectPreviewModel;
  bool isApiCallProcess = false;
  late IRISCollectRequestModel irisCollectRequestModel;

  bool isDeviceConnected = false;
  bool isAlertSet = false;

  late SharedPreferences prefs;

  @override
  void initState() {
    mCollectPreviewModel = widget.collectPreviewModel;
    dateInputController.text = mCollectPreviewModel.dateForUI;
    _wasteTypeController.text = mCollectPreviewModel.wasteType;
    _totalWasteController.text = "${mCollectPreviewModel.totalWaste} MT";
    _commentsController.text = mCollectPreviewModel.comments;

    irisCollectRequestModel = IRISCollectRequestModel();
    irisCollectRequestModel.date = mCollectPreviewModel.dateForAPI;
    irisCollectRequestModel.quantity = mCollectPreviewModel.totalWaste;
    irisCollectRequestModel.comments = mCollectPreviewModel.comments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('az');
    return ProgressHUD(
      inAsyncCall: isApiCallProcess,
      opacity: 0.3,
      child: _uiSetup(context),
    );
  }

  Widget _uiSetup(BuildContext context) {
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Preview",
            style: TextStyle(
                fontFamily: "ARIAL",
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp),
          ),
          leading: InkWell(
              onTap: () async {
                _onBackButtonClicked();
              },
              child: Icon(
                Icons.arrow_back_ios,
                size: 2.5.h,
              )),
          actions: [
            InkWell(
              child: const Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Icon(Icons.home_outlined, color: Colors.white),
              ),
              onTap: () async {
                _onBackPressedToHome();
              },
            ),
            InkWell(
              child: const Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Icon(Icons.person_outline_outlined, color: Colors.white),
              ),
              onTap: () async {
                _onBackPressedToProfile();
              },
            ),
          ],
          elevation: 0,
          backgroundColor: kReSustainabilityRed,
        ),
        body: SingleChildScrollView(
          child: Stack(
            key: const ValueKey('appStationContainer1'),
            children: [
              Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20, top: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Waste Type",
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            SizedBox(
                              height: 5.h,
                              child: TextFormField(
                                controller: _wasteTypeController,
                                style: TextStyle(
                                    color: kGreyTextColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12.sp),
                                showCursor: false,
                                autofocus: false,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 10.0),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20, top: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total Waste",
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            SizedBox(
                              height: 5.h,
                              child: TextFormField(
                                controller: _totalWasteController,
                                style: TextStyle(
                                    color: kGreyTextColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12.sp),
                                showCursor: false,
                                autofocus: false,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 10.0),
                                  hintText: '1.4 MT',
                                  hintStyle: TextStyle(
                                    fontFamily: "ARIAL",
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20, top: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Date",
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            SizedBox(
                              height: 5.h,
                              child: TextFormField(
                                controller: dateInputController,
                                style: TextStyle(
                                    color: kGreyTextColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12.sp),
                                showCursor: false,
                                autofocus: false,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 10.0),
                                  hintText: '08-08-2024 15:23:48',
                                  hintStyle: TextStyle(
                                      fontFamily: "ARIAL",
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20, top: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Site Name",
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            SizedBox(
                              height: 5.h,
                              child: FutureBuilder<String>(
                                  future: getSiteName(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<String> snapshot) {
                                    if (snapshot.hasData) {
                                      _siteNameController.text = snapshot.data!;
                                      return TextFormField(
                                        controller: _siteNameController,
                                        style: TextStyle(
                                            color: kGreyTextColor,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12.sp),
                                        showCursor: false,
                                        autofocus: false,
                                        readOnly: true,
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.fromLTRB(
                                              0.0, 20.0, 0.0, 10.0),
                                          hintText: 'Kalyani',
                                          hintStyle: TextStyle(
                                              fontFamily: "ARIAL",
                                              fontWeight: FontWeight.w400),
                                        ),
                                      );
                                    } else {
                                      return TextFormField(
                                        controller: _siteNameController,
                                        style: const TextStyle(
                                            color: kGreyTextColor,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15),
                                        showCursor: false,
                                        autofocus: false,
                                        readOnly: false,
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.fromLTRB(
                                              0.0, 20.0, 0.0, 10.0),
                                          hintText: '',
                                          hintStyle: TextStyle(
                                              fontFamily: "ARIAL",
                                              fontWeight: FontWeight.w500),
                                        ),
                                      );
                                    }
                                  }),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20, top: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Comments",
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            const SizedBox(height: 10.0),
                            SizedBox(
                              height: 20.h,
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      mCollectPreviewModel.comments,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                          color: kGreyTextColor,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12.sp),
                                    ),
                                  ),
                                  const Divider(color: Colors.black)
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          color: Colors.white,
          height: 100,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20),
                  child: GestureDetector(
                    child: Container(
                      decoration: ShapeDecoration(
                          color: Colors.grey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          shadows: [
                            BoxShadow(
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: const Offset(0, 2),
                                color: Colors.grey.shade400)
                          ]),
                      height: 5.h,
                      width: 35.w,
                      child: Center(
                        child: Text(
                          "Back",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              Expanded(
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
                      height: 5.h,
                      width: 35.w,
                      child: Center(
                        child: Text(
                          "Submit",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        isApiCallProcess = true;
                      });
                      getConnectivity();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
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
            content: const Text('Do you want go back !',
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
                onPressed: () =>
                    {Navigator.pop(context), Navigator.pop(context)},
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

  Future _onBackPressedToProfile() async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          // False will prevent and true will allow to dismiss
          child: AlertDialog(
            title: const Text('Go Back'),
            content: const Text(
                'Do you want to go to Iris Profile?\nDraft will be lost !'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel',
                    style: TextStyle(
                      color: kReSustainabilityRed,
                      fontFamily: 'Poppins',
                    )),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const IrisProfileScreen();
                      },
                    ),
                  );
                },
                child: const Text('Yes',
                    style: TextStyle(
                      color: kReSustainabilityRed,
                      fontFamily: 'Poppins',
                    )),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _onBackPressedToHome() async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          // False will prevent and true will allow to dismiss
          child: AlertDialog(
            title: const Text('Go Back'),
            content: const Text(
                'Do you want to go back to Home?\n Draft will be lost !'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel',
                    style: TextStyle(
                      color: kReSustainabilityRed,
                      fontFamily: 'Poppins',
                    )),
              ),
              TextButton(
                onPressed: () async {
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
                child: const Text('Yes',
                    style: TextStyle(
                      color: kReSustainabilityRed,
                      fontFamily: 'Poppins',
                    )),
              ),
            ],
          ),
        );
      },
    );
  }

  _onBackButtonClicked() async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          // False will prevent and true will allow to dismiss
          child: AlertDialog(
            title: const Text('Go Back'),
            content: const Text('Do you want go back !'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel',
                    style: TextStyle(
                      color: kReSustainabilityRed,
                      fontFamily: 'Poppins',
                    )),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Yes',
                    style: TextStyle(
                      color: kReSustainabilityRed,
                      fontFamily: 'Poppins',
                    )),
              ),
            ],
          ),
        );
      },
    );
  }

  getInit() async {
    prefs = await SharedPreferences.getInstance();
    String siteID = prefs.getString("site").toString();
    if (isApiCallProcess == true) {
      IrisCollectAPIService apiService = IrisCollectAPIService();
      apiService
          .collectDataApiCall(irisCollectRequestModel, siteID)
          .then((value) {
        if (value == "Collect Data Uploaded Succesfully.") {
          setState(() {
            isApiCallProcess = false;
          });
          showDialog(
              barrierDismissible: false,
              context: context,
              useRootNavigator: false,
              builder: (BuildContext context) {
                return PopScope(
                  canPop: false,
                  child: ConfirmationDialogBox(
                    title: 'Collect Data Uploaded Successfully.',
                    press: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return IrisHomeScreen(
                              sbuCode: mCollectPreviewModel.wasteType,
                              userRole: prefs.getString("roleName").toString(),
                              departmentName:
                                  prefs.getString("department").toString());
                        },
                      ));
                    },
                    color: Colors.white,
                    text: 'Done',
                  ),
                );
              });
        }
      });
    }
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

  Future<String> getSiteName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("SITE_NAME").toString();
  }
}