import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../Screens/home/home.dart';
import '../../../Utility/confirmationDialogBox.dart';
import '../../../Utility/internetCheck.dart';
import '../../../Utility/progressHUD.dart';
import '../../../Utility/shared_preferences_string.dart';
import '../../../Utility/utils/constants.dart';
import '../../../custom_sharedPreference.dart';
import '../Iris_Profile/iris_profile_screen.dart';
import '../api/msw_pnd_upload_api_service.dart';
import '../iris_home_screen.dart';
import 'msw_p_&_d_request_model.dart';
import 'msw_process_distribute_model.dart';

class MswProcessDistributePreview extends StatefulWidget {
  final MswProcessDistributeModel mswDistributeModel;
  const MswProcessDistributePreview(
      {super.key, required this.mswDistributeModel});

  @override
  State<MswProcessDistributePreview> createState() =>
      _MswProcessDistributePreviewState();
}

class _MswProcessDistributePreviewState
    extends State<MswProcessDistributePreview> {
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  bool isApiCallProcess = false;

  late MswProcessDistributeModel _mswDistributeModel;
  late MswPNDRequestModel mswPNDRequestModel;

  String totalWaste = "";
  String totalCompost = "";
  String totalRDF = "";
  String totalRecyclable = "";
  String totalInerts = "";
  String vendorNameCompost = "";
  String vendorNameRDF = "";
  String vendorNameRecyclable = "";
  String vendorNameInerts = "";
  String compost = "";
  String rdf = "";
  String rdfToWte = "";
  String recyclable = "";
  String recyclableToRecycleUnit = "";
  String inerts = "";
  String selectedDate = "";
  String location = "";
  String siteName = "";
  String comments = "";

  @override
  void initState() {
    _mswDistributeModel = widget.mswDistributeModel;
    mswPNDRequestModel = MswPNDRequestModel();

    DateTime dateTime = DateTime.parse(_mswDistributeModel.selectedDate);
    String date = DateFormat('yyyy-MM-dd').format(dateTime);

    mswPNDRequestModel.total_waste = _mswDistributeModel.totalWaste;
    mswPNDRequestModel.total_compost = _mswDistributeModel.totalCompost;
    mswPNDRequestModel.total_rdf = _mswDistributeModel.totalRDF;
    mswPNDRequestModel.total_recylables = _mswDistributeModel.totalRecyclable;
    mswPNDRequestModel.total_inerts = _mswDistributeModel.totalInerts;
    mswPNDRequestModel.vendor_name_compost =
        _mswDistributeModel.vendorNameCompost;
    mswPNDRequestModel.vendor_name_rdf = _mswDistributeModel.vendorNameRDF;
    mswPNDRequestModel.vendor_name_recyclables =
        _mswDistributeModel.vendorNameRecyclable;
    mswPNDRequestModel.vendor_name_inserts =
        _mswDistributeModel.vendorNameInerts;
    mswPNDRequestModel.compost = _mswDistributeModel.compost;
    mswPNDRequestModel.rdf = _mswDistributeModel.rdf;
    rdfToWte = _mswDistributeModel.rdfToWte;
    mswPNDRequestModel.recyclables = _mswDistributeModel.recyclable;
    recyclableToRecycleUnit = _mswDistributeModel.recyclableToRecycleUnit;
    mswPNDRequestModel.inserts = _mswDistributeModel.inerts;
    mswPNDRequestModel.date = date;
    mswPNDRequestModel.site = _mswDistributeModel.location;
    mswPNDRequestModel.site = _mswDistributeModel.siteName;
    mswPNDRequestModel.comments = _mswDistributeModel.comments;

    totalWaste = _mswDistributeModel.totalWaste;
    totalCompost = _mswDistributeModel.totalCompost;
    totalRDF = _mswDistributeModel.totalRDF;
    totalRecyclable = _mswDistributeModel.totalRecyclable;
    totalInerts = _mswDistributeModel.totalInerts;
    vendorNameCompost = _mswDistributeModel.vendorNameCompost;
    vendorNameRDF = _mswDistributeModel.vendorNameRDF;
    vendorNameRecyclable = _mswDistributeModel.vendorNameRecyclable;
    vendorNameInerts = _mswDistributeModel.vendorNameInerts;
    compost = _mswDistributeModel.compost;
    rdf = _mswDistributeModel.rdf;
    recyclable = _mswDistributeModel.recyclable;
    inerts = _mswDistributeModel.inerts;
    selectedDate = DateFormat('dd/MM/yyyy').format(dateTime);
    location = _mswDistributeModel.location;
    siteName = _mswDistributeModel.siteName;
    comments = _mswDistributeModel.comments;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: AppBar(
            centerTitle: true,
            title: const Text(
              "Preview",
              style: TextStyle(
                  fontFamily: "ARIAL",
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            leading: InkWell(
                onTap: () async {
                  Navigator.pop(context);
                },
                child: const Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Icon(Icons.arrow_back_ios),
                )),
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
                  _onBackPressedToHome();
                },
              ),
              InkWell(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Image.asset(
                    "assets/icons/user.png",
                    height: 25.0,
                    width: 25.0,
                  ),
                ),
                onTap: () async {
                  _onBackPressedToProfile();
                },
              ),
            ],
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
                          'Processing',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      const Divider(
                        thickness: 1,
                        color: Color(
                          0xffCBCBCB,
                        ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Waste',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "$totalWaste MT",
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Compost',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "$totalCompost MT",
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total RDF',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "$totalRDF MT",
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Recyclable',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "$totalRecyclable MT",
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Inerts',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "$totalInerts MT",
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
                          'Distribute',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      const Divider(
                        thickness: 1,
                        color: Color(
                          0xffCBCBCB,
                        ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      const Center(
                        child: Text(
                          'Compost Outflow',
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
                            'Vendor Name',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            vendorNameCompost,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Compost',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "$compost MT",
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
                      const Center(
                        child: Text(
                          'RDF Outflow',
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
                            'Vendor Name',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            vendorNameRDF,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'RDF',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "$rdf MT",
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'RDF to WTE',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "$rdfToWte MT",
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
                      const Center(
                        child: Text(
                          'Recyclable Outflow',
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
                            'Vendor Name',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            vendorNameRecyclable,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recyclable',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "$recyclable MT",
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recyclable to Recycle Unit',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "$recyclableToRecycleUnit MT",
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
                      const Center(
                        child: Text(
                          'Inerts Outflow',
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
                            'Vendor Name',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            vendorNameInerts,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Inerts',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "$inerts MT",
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
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
                        height: 3.h,
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
                        height: 2.h,
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
                        height: 2.h,
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
                        height: 2.h,
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String siteID = prefs.getString("site").toString();
    if (isApiCallProcess == true) {
      MswPNDAPIService apiService = MswPNDAPIService();
      apiService.mswPNDApiCall(mswPNDRequestModel, siteID).then((value) {
        if (value ==
            "MSW Processing & Distribute Data Uploaded Succesfully.") {
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
                    title: 'MSW PND Data Uploaded Successfully.',
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