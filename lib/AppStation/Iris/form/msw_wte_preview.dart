import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resus_test/AppStation/Iris/model/msw_wte_collect_model.dart';
import 'package:resus_test/AppStation/Iris/model/msw_wte_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/cupertino.dart';
import '../../../Screens/home/home.dart';
import '../../../Utility/confirmationDialogBox.dart';
import '../../../Utility/internetCheck.dart';
import '../../../Utility/progressHUD.dart';
import '../../../Utility/shared_preferences_string.dart';
import '../../../Utility/utils/constants.dart';
import '../../../custom_sharedPreference.dart';
import '../Iris_Profile/iris_profile_screen.dart';
import '../api/msw_wte_collect_api.dart';
import '../iris_home_screen.dart';

class MswWtePreview extends StatefulWidget {
  final MswWteModel mswWteModel;
  const MswWtePreview({super.key, required this.mswWteModel});

  @override
  State<MswWtePreview> createState() => _MswWtePreviewState();
}

class _MswWtePreviewState extends State<MswWtePreview> {
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  bool isApiCallProcess = false;

  late MswWteModel _mswWteModel;
  late MswWteCollectRequestModel mswWteRequestModel;

  late SharedPreferences prefs;

  String rdfReceipt = "";
  String rdfCombusted = "";
  String streamGeneration = "";
  String powerExport = "";
  String powerGeneration = "";
  String auxillaryConsumption = "";
  String powerGenerationCapacity = "";
  String plantLoadfactor = "";
  String bottomAsh = "";
  String flyAsh = "";
  String totalAsh = "";
  String selectedDate = "";
  String location = "";
  String siteName = "";
  String comments = "";

  @override
  void initState() {
    _mswWteModel = widget.mswWteModel;
    mswWteRequestModel = MswWteCollectRequestModel();

    DateTime dateTime = DateTime.parse(_mswWteModel.selectedDate);
    String date = DateFormat('yyyy-MM-dd').format(dateTime);

    mswWteRequestModel.rdfReceipt = _mswWteModel.rdfReceipt;
    mswWteRequestModel.rdfCombusted = _mswWteModel.rdfCombusted;
    mswWteRequestModel.streamGeneration = _mswWteModel.streamGeneration;
    mswWteRequestModel.powerExport = _mswWteModel.powerExport;
    mswWteRequestModel.powerGeneration = _mswWteModel.powerGeneration;
    mswWteRequestModel.auxillaryConsumption = _mswWteModel.auxillaryConsumption;
    mswWteRequestModel.powerGenerationCapacity =
        _mswWteModel.powerGenerationCapacity;
    mswWteRequestModel.plantLoadFactor = _mswWteModel.plantLoadFactor;
    mswWteRequestModel.bottomAsh = _mswWteModel.bottomAsh;
    mswWteRequestModel.flyAsh = _mswWteModel.flyAsh;
    mswWteRequestModel.totalAsh = _mswWteModel.totalAsh;
    mswWteRequestModel.date = date;
    mswWteRequestModel.siteId = _mswWteModel.siteName;
    mswWteRequestModel.comments = _mswWteModel.comments;

    rdfReceipt = _mswWteModel.rdfReceipt;
    rdfCombusted = _mswWteModel.rdfCombusted;
    streamGeneration = _mswWteModel.streamGeneration;
    powerExport = _mswWteModel.powerExport;
    powerGeneration = _mswWteModel.powerGeneration;
    auxillaryConsumption = _mswWteModel.auxillaryConsumption;
    powerGenerationCapacity = _mswWteModel.powerGenerationCapacity;
    plantLoadfactor = _mswWteModel.plantLoadFactor;
    bottomAsh = _mswWteModel.bottomAsh;
    flyAsh = _mswWteModel.flyAsh;
    totalAsh = _mswWteModel.totalAsh;
    selectedDate = DateFormat('dd/MM/yyyy').format(dateTime);
    location = _mswWteModel.location;
    siteName = _mswWteModel.siteName;
    comments = _mswWteModel.comments;

    super.initState();
  }

  getPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      inAsyncCall: isApiCallProcess,
      opacity: 0.5,
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
        appBar: PreferredSize(
          preferredSize: const Size(0, 60),
          child: AppBar(
            centerTitle: true,
            title: Text(
              "WTE Preview",
              style: TextStyle(
                  fontFamily: "ARIAL",
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp),
            ),
            leading: InkWell(
                onTap: () async {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 2.5.h,
                )),
            actions: [
              InkWell(
                child: Image.asset(
                  "assets/icons/home.png",
                  height: 25.0,
                  width: 25.0,
                ),
                onTap: () async {
                  _onBackPressedToHome();
                },
              ),
              SizedBox(
                width: 1.h,
              ),
              InkWell(
                child: Image.asset(
                  "assets/icons/user.png",
                  height: 25.0,
                  width: 25.0,
                ),
                onTap: () async {
                  _onBackPressedToProfile();
                },
              ),
              SizedBox(
                width: 2.h,
              )
            ],
            elevation: 0,
            backgroundColor: kReSustainabilityRed,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Card(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                elevation: 5.0,
                surfaceTintColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 15.0, bottom: 20.0, right: 20.0, left: 20.0),
                  child: Column(
                    children: [
                      const Center(
                        child: Text(
                          'RDF Data',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'RDF Receipt',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "$rdfReceipt MT",
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: kGreyTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'RDF Combusted',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "$rdfCombusted MT",
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: kGreyTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 3.h,
              ),
              Card(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                elevation: 5.0,
                surfaceTintColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 15.0, bottom: 20.0, right: 20.0, left: 20.0),
                  child: Column(
                    children: [
                      const Center(
                        child: Text(
                          'Generation Data',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Steam Generation',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "$streamGeneration TPD",
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: kGreyTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Power Generation',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "$powerGeneration MW",
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: kGreyTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Power Export',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "$powerExport MW",
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: kGreyTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Auxiliary Consumption',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "$auxillaryConsumption MW",
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: kGreyTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Power Generation Capacity',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "$powerGenerationCapacity MW",
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: kGreyTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Plant Load Factor',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "$plantLoadfactor %",
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: kGreyTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 3.h,
              ),
              Card(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                elevation: 5.0,
                surfaceTintColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 15.0, bottom: 20.0, right: 20.0, left: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Ash Data',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Bottom Ash',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "$bottomAsh MT",
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: kGreyTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Fly Ash',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "$flyAsh MT",
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: kGreyTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Ash',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "$totalAsh MT",
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: kGreyTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      const Center(
                        child: Text(
                          'Others',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Date',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            selectedDate,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: kGreyTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Location',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            location,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: kGreyTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Site Name',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            siteName,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: kGreyTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Comments',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comments,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: kGreyTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        )),
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
      useRootNavigator: false,
      context: context,
      barrierDismissible: false,
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
      useRootNavigator: false,
      context: context,
      barrierDismissible: false,
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

  getInit() async {
    prefs = await SharedPreferences.getInstance();
    String siteID = prefs.getString('site').toString();
    if (isApiCallProcess == true) {
      MswWteAPIService apiService = MswWteAPIService();
      apiService.mswWteDataApiCall(mswWteRequestModel, siteID).then((value) {
        if (value == "MSW Wte Data Uploaded Succesfully.") {
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
                    title: 'MSW Wte Data Uploaded Successfully.',
                    press: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return IrisHomeScreen(
                            sbuCode: "MSW",
                            userRole: prefs.getString("roleName").toString(),
                            departmentName:
                                prefs.getString("department").toString(),
                          );
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
}
