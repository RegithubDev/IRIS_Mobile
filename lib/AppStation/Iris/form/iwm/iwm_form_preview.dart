import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:resus_test/AppStation/Iris/api/iwm/post_disposal_api.dart';
import 'package:resus_test/AppStation/Iris/api/iwm/post_receipt_api.dart';
import 'package:resus_test/AppStation/Iris/model/iwm/iwm_form_preview_model.dart';
import 'package:resus_test/AppStation/Iris/model/iwm/iwm_open_stock_form_fetch_model.dart';
import 'package:resus_test/AppStation/Iris/model/iwm/post_disposal_model.dart';
import 'package:resus_test/AppStation/Iris/model/iwm/post_receipt_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../../../Screens/home/home.dart';
import '../../../../Utility/confirmationDialogBox.dart';
import '../../../../Utility/internetCheck.dart';
import '../../../../Utility/progressHUD.dart';
import '../../../../Utility/shared_preferences_string.dart';
import '../../../../Utility/utils/constants.dart';
import '../../../../custom_sharedPreference.dart';
import '../../Iris_Profile/iris_profile_screen.dart';
import '../../api/iwm/get_iwm_open_stock_form_api.dart';
import '../../iris_home_screen.dart';

class IwmFormPreview extends StatefulWidget {
  final IwmFormPreviewModel iwmFormPreviewModel;
  final String formName;
  final String date;
  const IwmFormPreview(
      {super.key,
      required this.iwmFormPreviewModel,
      required this.formName,
      required this.date});

  @override
  State<IwmFormPreview> createState() => _IwmFormPreviewState();
}

class _IwmFormPreviewState extends State<IwmFormPreview> {
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  bool isApiCallProcess = false;

  late IwmFormPreviewModel _iwmFormPreviewModel;
  late PostReceiptRequestModel _postReceiptRequestModel;
  late PostDisposalRequestModel _postDisposalRequestModel;
  late IwmOpenStockFormDataListRequestModel _iwmOpenStockFormDataListRequestModel;

  late SharedPreferences prefs;

  String formName = "";
  String osDLF = "";
  String osLAT = "";
  String osIncineration = "";
  String osAfrf = "";
  String osTotalWaste = "";

  String dLF = "";
  String lAT = "";
  String incineration = "";
  String afrf = "";
  String totalWaste = "";
  String inciToAfrf = "";
  String recycQtyInc = "";
  String recycQtyAfrf = "";
  String recycQtyTotal = "";

  String closeDLF = "";
  String closeLAT = "";
  String closeIncineration = "";
  String closeAfrf = "";
  String closeTotalWaste = "";

  @override
  void initState() {
    _iwmFormPreviewModel = widget.iwmFormPreviewModel;

    formName = widget.formName;

    _postReceiptRequestModel = PostReceiptRequestModel();
    _postDisposalRequestModel = PostDisposalRequestModel();
    _iwmOpenStockFormDataListRequestModel = IwmOpenStockFormDataListRequestModel();

    _postReceiptRequestModel.date = widget.date;
    _postReceiptRequestModel.receiptDlf = _iwmFormPreviewModel.dLF;
    _postReceiptRequestModel.receiptLat = _iwmFormPreviewModel.lAT;
    _postReceiptRequestModel.receiptIncineration =
        _iwmFormPreviewModel.incineration;
    _postReceiptRequestModel.receiptAfrf = _iwmFormPreviewModel.afrf;
    _postReceiptRequestModel.receiptTotalWaste =
        _iwmFormPreviewModel.totalWaste;
    _postReceiptRequestModel.incinerationToAfrf =
        _iwmFormPreviewModel.inciToAfrf;

    _postDisposalRequestModel.date = widget.date;
    _postDisposalRequestModel.disposalDlf = _iwmFormPreviewModel.dLF;
    _postDisposalRequestModel.disposalLat = _iwmFormPreviewModel.lAT;
    _postDisposalRequestModel.disposalIncineration =
        _iwmFormPreviewModel.incineration;
    _postDisposalRequestModel.disposalAfrf = _iwmFormPreviewModel.afrf;
    _postDisposalRequestModel.disposalTotalWaste =
        _iwmFormPreviewModel.totalWaste;
    _postDisposalRequestModel.recyclingQtyToInc =
        _iwmFormPreviewModel.recycQtyInc;
    _postDisposalRequestModel.recyclingQtyToAfrf =
        _iwmFormPreviewModel.recycQtyAfrf;
    _postDisposalRequestModel.incinerationToAfrf =
        _iwmFormPreviewModel.inciToAfrf;
    _postDisposalRequestModel.recyclingQtyTotal =
        _iwmFormPreviewModel.recycQtyTotal;

    osDLF = _iwmFormPreviewModel.osDLF;
    osLAT = _iwmFormPreviewModel.osLAT;
    osIncineration = _iwmFormPreviewModel.osIncineration;
    osAfrf = _iwmFormPreviewModel.osAfrf;
    osTotalWaste = _iwmFormPreviewModel.osTotalWaste;

    dLF = _iwmFormPreviewModel.dLF;
    lAT = _iwmFormPreviewModel.lAT;
    incineration = _iwmFormPreviewModel.incineration;
    afrf = _iwmFormPreviewModel.afrf;
    totalWaste = _iwmFormPreviewModel.totalWaste;
    inciToAfrf = _iwmFormPreviewModel.inciToAfrf;
    recycQtyInc = _iwmFormPreviewModel.recycQtyInc;
    recycQtyAfrf = _iwmFormPreviewModel.recycQtyAfrf;
    recycQtyTotal = _iwmFormPreviewModel.recycQtyTotal;

    closeDLF = _iwmFormPreviewModel.closeDLF;
    closeLAT = _iwmFormPreviewModel.closeLAT;
    closeIncineration = _iwmFormPreviewModel.closeIncineration;
    closeAfrf = _iwmFormPreviewModel.closeAfrf;
    closeTotalWaste = _iwmFormPreviewModel.closeTotalWaste;

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
              "Preview",
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
                      top: 15.0, bottom: 20.0, right: 10.0, left: 10.0),
                  child: Column(
                    children: [
                      const Center(
                        child: Text(
                          'Opening Stock',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      const Divider(
                        color: kGreyColor,
                        height: 10.0,
                        thickness: 0.5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, bottom: 10.0, right: 10.0, left: 10.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "DLF",
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "$osDLF MT",
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
                                  'LAT',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "$osLAT MT",
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
                                  'Incineration',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "$osIncineration MT",
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
                                  'AFRF',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "$osAfrf MT",
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
                                  'Total Waste',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "$osTotalWaste MT",
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
                      top: 15.0, bottom: 20.0, right: 10.0, left: 10.0),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          formName == 'Receipt' ? "Receipt" : "Disposal",
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      const Divider(
                        color: kGreyColor,
                        height: 10.0,
                        thickness: 0.5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, bottom: 10.0, right: 10.0, left: 10.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "DLF",
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "$dLF MT",
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
                                  'LAT',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "$lAT MT",
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
                                  'Incineration',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "$incineration MT",
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
                                  'AFRF',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "$afrf MT",
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
                              height: 3.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Incineration to AFRF',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "$inciToAfrf MT",
                                  style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    color: kGreyTextColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            formName == "Disposal"
                                ? SizedBox(
                                    height: 3.h,
                                  )
                                : const SizedBox(),
                            formName == "Disposal"
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Recycling Qty to Incineration',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        "$recycQtyInc MT",
                                        style: const TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 14,
                                          color: kGreyTextColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox(),
                            formName == "Disposal"
                                ? SizedBox(
                                    height: 3.h,
                                  )
                                : const SizedBox(),
                            formName == "Disposal"
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Recycling Qty to AFRF',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        "$recycQtyAfrf MT",
                                        style: const TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 14,
                                          color: kGreyTextColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox(),
                            formName == "Disposal"
                                ? SizedBox(
                                    height: 3.h,
                                  )
                                : const SizedBox(),
                            formName == "Disposal"
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Recycling Total Qty',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        "$recycQtyTotal MT",
                                        style: const TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 14,
                                          color: kGreyTextColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox(),
                          ],
                        ),
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
                      top: 15.0, bottom: 20.0, right: 10.0, left: 10.0),
                  child: Column(
                    children: [
                      const Center(
                        child: Text(
                          'Closing Stock',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      const Divider(
                        color: kGreyColor,
                        height: 10.0,
                        thickness: 0.5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, bottom: 10.0, right: 10.0, left: 10.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "DLF",
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "$closeDLF MT",
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
                                  'LAT',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "$closeLAT MT",
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
                                  'Incineration',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "$closeIncineration MT",
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
                                  'AFRF',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "$closeAfrf MT",
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
                                  'Total Waste',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "$closeTotalWaste MT",
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
      PostReceiptAPIService postReceiptAPIService = PostReceiptAPIService();
      PostDisposalAPIService postDisposalAPIService = PostDisposalAPIService();
      formName == "Receipt"
          ? postReceiptAPIService
              .postReceiptApiCall(_postReceiptRequestModel, siteID)
              .then((value) {
              if (value == "IWM Receipt Data Uploaded Succesfully.") {
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
                          title: 'IWM Receipt Data Uploaded Successfully',
                          press: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return IrisHomeScreen(
                                  sbuCode: "IWM",
                                  userRole:
                                      prefs.getString("roleName").toString(),
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
            })
          : postDisposalAPIService
              .postDisposalApiCall(_postDisposalRequestModel, siteID)
              .then((value) {
              if (value == "IWM Disposal Data Uploaded Succesfully.") {
                setState(() {
                  isApiCallProcess = false;
                });
                // GetIwmOpenStockFormDataListAPIService().getIwmOpenStockFormDataListApiCall(_iwmOpenStockFormDataListRequestModel, siteID);
                showDialog(
                    useRootNavigator: false,
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) {
                      return PopScope(
                        canPop: false,
                        child: ConfirmationDialogBox(
                          title: 'IWM Disposal Data Uploaded Successfully',
                          press: () async{
                            await GetIwmOpenStockFormDataListAPIService().getIwmOpenStockFormDataListApiCall(_iwmOpenStockFormDataListRequestModel, siteID);

                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return IrisHomeScreen(
                                  sbuCode: "IWM",
                                  userRole:
                                      prefs.getString("roleName").toString(),
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