import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:resus_test/AppStation/Iris/model/iwm/iwm_form_preview_model.dart';
import 'package:resus_test/Screens/components/custom_timeline.dart';
import 'package:resus_test/Utility/internetCheck.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../../../Screens/home/home.dart';
import '../../../../Utility/utils/constants.dart';
import '../../../../Utility/utils/decimal_textfield_value.dart';
import '../../Iris_Profile/iris_profile_screen.dart';
import '../../api/iwm/iwm_check_openstock_api.dart';
import '../../model/iwm/iwm_openstock_data_model.dart';
import 'iwm_form_preview.dart';

class IwmForm extends StatefulWidget {
  final String formName;
  const IwmForm({super.key, required this.formName});

  @override
  State<IwmForm> createState() => _IwmFormState();
}

class _IwmFormState extends State<IwmForm> {
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  int lastIndex = 3;
  int firstIndex = 0;
  String os = "os";
  String receipt = "receipt";
  String cs = "cs";

  var forms = ["os", "receipt", "cs"];
  bool lastState = false;

  String date = "";

  String formHeader = "";

  String formName = "";

  DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 100)),
    end: DateTime.now(),
  );

  late final TextEditingController _osDate = TextEditingController();
  late final TextEditingController _osDLF = TextEditingController();
  late final TextEditingController _osLAT = TextEditingController();
  late final TextEditingController _osIncineration = TextEditingController();
  late final TextEditingController _osAfrf = TextEditingController();
  late final TextEditingController _osTotalWaste = TextEditingController();

  late final TextEditingController _inciToAfrf = TextEditingController();
  late final TextEditingController _dLF = TextEditingController();
  late final TextEditingController _lAT = TextEditingController();
  late final TextEditingController _incineration = TextEditingController();
  late final TextEditingController _afrf = TextEditingController();
  late final TextEditingController _totalWaste = TextEditingController();
  late final TextEditingController _recycQtyInc = TextEditingController();
  late final TextEditingController _recycQtyAfrf = TextEditingController();
  late final TextEditingController _recycQtyTotal = TextEditingController();

  late final TextEditingController _closeDLF = TextEditingController();
  late final TextEditingController _closeLAT = TextEditingController();
  late final TextEditingController _closeIncineration = TextEditingController();
  late final TextEditingController _closeAfrf = TextEditingController();
  late final TextEditingController _closeTotalWaste = TextEditingController();

  int calculation = 10;
  String selectedDate = "";

  @override
  void initState() {
    formHeader = forms[0];
    formName = widget.formName;
    getConnectivity();
    formName == "Receipt"
        ? WidgetsBinding.instance.addPostFrameCallback((_) async {
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            date = prefs.getString("osLastDate").toString();
            _osDate.text = DateFormat('dd/MM/yyyy').format(
                DateTime.parse(prefs.getString("osLastDate").toString()));
            _osDLF.text = double.tryParse(prefs.getString("osDLF")!)!.toStringAsFixed(2);
            _osLAT.text = double.tryParse(prefs.getString("osLAT")!)!.toStringAsFixed(2);
            _osIncineration.text = double.tryParse(prefs.getString("osInc")!)!.toStringAsFixed(2);
            _osAfrf.text = double.tryParse(prefs.getString("osAfrf")!)!.toStringAsFixed(2);
            _osTotalWaste.text = double.tryParse(prefs.getString("osTotalWaste")!)!.toStringAsFixed(2);
          })
        : WidgetsBinding.instance.addPostFrameCallback((_) async {
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            _inciToAfrf.text = prefs.getString("receiptIncToAfrf") ?? "0.0";
            date = prefs.getString("osLastDate").toString();
            _osDate.text = DateFormat('dd/MM/yyyy').format(
                DateTime.parse(prefs.getString("osLastDate").toString()));
            _osDLF.text = (double.parse(prefs.getString("osDLF").toString()) +
                    double.parse(prefs.getString("receiptDLF").toString()))
                .toStringAsFixed(2);
            _osLAT.text = (double.parse(prefs.getString("osLAT").toString()) +
                    double.parse(prefs.getString("receiptLAT").toString()))
                .toStringAsFixed(2);
            _osIncineration.text =
                (double.parse(prefs.getString("osInc").toString()) +
                        double.parse(prefs.getString("receiptInc").toString()))
                    .toStringAsFixed(2);
            _osAfrf.text = (double.parse(prefs.getString("osAfrf").toString()) +
                    double.parse(prefs.getString("receiptAfrf").toString()))
                .toStringAsFixed(2);
            _osTotalWaste.text =
                (double.parse(prefs.getString("osTotalWaste").toString()) +
                        double.parse(
                            prefs.getString("receiptTotalWaste").toString()))
                    .toStringAsFixed(2);
          });
    super.initState();
  }

  getInit() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String siteID = prefs.getString("site").toString();
    IwmOpenStockDataListRequestModel iwmOpenStockDataListRequestModel =
        IwmOpenStockDataListRequestModel();

    await GetIwmCheckOpenStockDataListAPIService()
        .getIwmCheckOpenStockDataListApiCall(
            iwmOpenStockDataListRequestModel, siteID);
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

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
          appBar: PreferredSize(
            preferredSize: const Size(0, 60),
            child: AppBar(
              centerTitle: true,
              title: Text(
                formName,
                style: TextStyle(
                    fontFamily: "ARIAL",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp),
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
            child: Stack(
              children: [
                Form(
                    key: formKey,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 70.0, left: 20, right: 20),
                      child: Column(
                        children: [
                          formHeader == "os"
                              ? openStockForm(context)
                              : const SizedBox(),
                          formHeader == "receipt"
                              ? form(context)
                              : const SizedBox(),
                          formHeader == "cs"
                              ? closeStockForm(context)
                              : const SizedBox(),
                        ],
                      ),
                    )),
                Positioned(
                    top: 10.0,
                    left: 1.0,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
                      child: SizedBox(
                        height: 90,
                        width: 500,
                        child: ListView(
                          physics: const NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          children: [
                            TimeLine(
                              isFirst: true,
                              isLast: false,
                              isPast:
                                  formHeader == "receipt" || formHeader == "cs"
                                      ? true
                                      : false,
                              eventName: formName == "Receipt"
                                  ? "Opening \nStock"
                                  : "Stock",
                              width: 130,
                            ),
                            TimeLine(
                              isFirst: false,
                              isLast: false,
                              isPast: formHeader == "cs" ? true : false,
                              eventName: formName == "Receipt"
                                  ? "Receipt"
                                  : "Disposal",
                              width: 130,
                            ),
                            TimeLine(
                              isFirst: false,
                              isLast: true,
                              isPast: lastState ? true : false,
                              eventName: formName == "Receipt"
                                  ? "Closing \nStock"
                                  : "Closing Stock",
                              width: 130,
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                formHeader == "receipt" || formHeader == "cs"
                    ? InkWell(
                        onTap: () {
                          if (formHeader == "receipt") {
                            setState(() {
                              lastState = false;
                              formHeader = forms[0];
                            });
                          } else {
                            setState(() {
                              lastState = false;
                              formHeader = forms[1];
                            });
                          }
                        },
                        child: Container(
                          decoration: ShapeDecoration(
                              color: kGreyColor,
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
                      )
                    : const SizedBox(),
                InkWell(
                  onTap: () async {
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    if (formKey.currentState!.validate()) {
                      if (formHeader == "os") {
                        setState(() {
                          formHeader = forms[1];
                        });
                      } else if (formHeader == "cs") {
                        setState(() {
                          lastState = true;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return IwmFormPreview(
                                  formName: formName,
                                  date: date,
                                  iwmFormPreviewModel: IwmFormPreviewModel(
                                      osDLF: _osDLF.text,
                                      osLAT: _osLAT.text,
                                      osIncineration: _osIncineration.text,
                                      osAfrf: _osAfrf.text,
                                      osTotalWaste: _osTotalWaste.text,
                                      dLF: _dLF.text,
                                      lAT: _lAT.text,
                                      incineration: _incineration.text,
                                      afrf: _afrf.text,
                                      totalWaste: _totalWaste.text,
                                      inciToAfrf: _inciToAfrf.text,
                                      recycQtyInc: _recycQtyInc.text,
                                      recycQtyAfrf: _recycQtyAfrf.text,
                                      recycQtyTotal: _recycQtyTotal.text,
                                      closeDLF: _closeDLF.text,
                                      closeLAT: _closeLAT.text,
                                      closeIncineration:
                                          _closeIncineration.text,
                                      closeAfrf: _closeAfrf.text,
                                      closeTotalWaste: _closeTotalWaste.text));
                            },
                          ),
                        );
                      } else {
                        setState(() {
                          formName == "Receipt"
                              ? WidgetsBinding.instance
                                  .addPostFrameCallback((_) async {
                                  _closeDLF.text = "";
                                  double dlf = double.parse(_osDLF.text) +
                                      double.parse(_dLF.text);
                                  _closeDLF.text = dlf.toStringAsFixed(2);

                                  _closeLAT.text = "";
                                  double lat = double.parse(_osLAT.text) +
                                      double.parse(_lAT.text);
                                  _closeLAT.text = lat.toStringAsFixed(2);

                                  _closeIncineration.text = "";
                                  double inc = (double.parse(
                                              _osIncineration.text) +
                                          double.parse(_incineration.text)) -
                                      (0.0 +
                                          double.parse(_inciToAfrf.text) +
                                          0.0);
                                  _closeIncineration.text =
                                      inc.toStringAsFixed(2);

                                  _closeAfrf.text = "";
                                  double afrf = (double.parse(_osAfrf.text) +
                                          double.parse(_afrf.text) +
                                          double.parse(_inciToAfrf.text)) -
                                      (0.0 - 0.0);
                                  _closeAfrf.text = afrf.toStringAsFixed(2);

                                  _closeTotalWaste.text = "";
                                  double total = double.parse(_closeDLF.text) +
                                      double.parse(_closeLAT.text) +
                                      double.parse(_closeIncineration.text) +
                                      double.parse(_closeAfrf.text);
                                  _closeTotalWaste.text =
                                      total.toStringAsFixed(2);
                                })
                              : WidgetsBinding.instance
                                  .addPostFrameCallback((_) async {
                                  String receiptDlf =
                                      prefs.getString("receiptDLF").toString();
                                  String receiptLat =
                                      prefs.getString("receiptLAT").toString();
                                  String receiptInc =
                                      prefs.getString("receiptInc").toString();
                                  String receiptAfrf =
                                      prefs.getString("receiptAfrf").toString();

                                  String osDLF =
                                      prefs.getString("osDLF").toString();
                                  String osLAT =
                                      prefs.getString("osLAT").toString();
                                  String osIncineration =
                                      prefs.getString("osInc").toString();
                                  String osAfrf =
                                      prefs.getString("osAfrf").toString();

                                  _closeDLF.text = "";
                                  double disDlf = (double.parse(osDLF) +
                                          double.parse(receiptDlf)) -
                                      double.parse(_dLF.text);
                                  _closeDLF.text = disDlf.toStringAsFixed(2);

                                  _closeLAT.text = "";
                                  double dislat = (double.parse(osLAT) +
                                          double.parse(receiptLat)) -
                                      double.parse(_lAT.text);
                                  _closeLAT.text = dislat.toStringAsFixed(2);

                                  _closeIncineration.text = "";
                                  double disinc = (double.parse(
                                              osIncineration) +
                                          double.parse(receiptInc)) -
                                      (double.parse(_incineration.text) +
                                          double.parse(_inciToAfrf.text) +
                                          double.parse(_recycQtyTotal.text));
                                  _closeIncineration.text =
                                      disinc.toStringAsFixed(2);

                                  _closeAfrf.text = "";
                                  double disafrf = (double.parse(osAfrf) +
                                          double.parse(receiptAfrf) +
                                          double.parse(_inciToAfrf.text)) -
                                      (double.parse(_afrf.text) +
                                          double.parse(_recycQtyTotal.text));
                                  _closeAfrf.text = disafrf.toStringAsFixed(2);

                                  _closeTotalWaste.text = "";
                                  double total = double.parse(_closeDLF.text) +
                                      double.parse(_closeLAT.text) +
                                      double.parse(_closeIncineration.text) +
                                      double.parse(_closeAfrf.text);
                                  _closeTotalWaste.text =
                                      total.toStringAsFixed(2);
                                });
                          formHeader = forms[2];
                        });
                      }
                    }
                  },
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
                        "Next",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget openStockForm(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 5.h,
        ),
        TextFormField(
          controller: _osDate,
          readOnly: true,
          inputFormatters: [
            LengthLimitingTextInputFormatter(9),
            DecimalTextInputFormatter(decimalRange: 3)
          ],
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: kGreyColor),
              ),
              label: const Text(
                'OS Date',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: kGreyTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              border: const OutlineInputBorder(),),
        ),
        SizedBox(
          height: 2.h,
        ),
        Text(
          formName == "receipt" ? 'Opening Stock' : 'Stock',
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 3.h,
        ),
        TextFormField(
          controller: _osDLF,
          readOnly: true,
          inputFormatters: [
            LengthLimitingTextInputFormatter(9),
            DecimalTextInputFormatter(decimalRange: 3)
          ],
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: kGreyColor),
              ),
              label: const Text(
                'DLF',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: kGreyTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              border: const OutlineInputBorder(),
              suffixText: "MT"),
        ),
        SizedBox(
          height: 3.h,
        ),
        TextFormField(
          controller: _osLAT,
          readOnly: true,
          inputFormatters: [
            LengthLimitingTextInputFormatter(9),
            DecimalTextInputFormatter(decimalRange: 3)
          ],
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: kGreyColor),
              ),
              label: const Text(
                'LAT',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: kGreyTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              border: const OutlineInputBorder(),
              suffixText: "MT"),
        ),
        SizedBox(
          height: 3.h,
        ),
        TextFormField(
          controller: _osIncineration,
          readOnly: true,
          inputFormatters: [
            LengthLimitingTextInputFormatter(9),
            DecimalTextInputFormatter(decimalRange: 3)
          ],
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: kGreyColor),
              ),
              label: const Text(
                'Incineration',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: kGreyTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              border: const OutlineInputBorder(),
              suffixText: "MT"),
        ),
        SizedBox(
          height: 3.h,
        ),
        TextFormField(
          controller: _osAfrf,
          readOnly: true,
          inputFormatters: [
            LengthLimitingTextInputFormatter(9),
            DecimalTextInputFormatter(decimalRange: 3)
          ],
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: kGreyColor),
              ),
              label: const Text(
                'AFRF',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: kGreyTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              border: const OutlineInputBorder(),
              suffixText: "MT"),
        ),
        SizedBox(
          height: 3.h,
        ),
        TextFormField(
          controller: _osTotalWaste,
          readOnly: true,
          inputFormatters: [
            LengthLimitingTextInputFormatter(9),
            DecimalTextInputFormatter(decimalRange: 3)
          ],
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: kGreyColor),
              ),
              label: const Text(
                'Total Waste',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: kGreyTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              border: const OutlineInputBorder(),
              suffixText: "MT"),
        ),
        SizedBox(
          height: 1.h,
        ),
      ],
    );
  }

  Widget form(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 5.h,
        ),
        Text(
          formName == 'Receipt' ? "Receipt" : "Disposal",
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 3.h,
        ),
        TextFormField(
          controller: _dLF,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Enter DLF";
            }
            return null;
          },
          onChanged: (value) {
            _totalWaste.text = "";
            double ac = (double.tryParse(_dLF.text) ?? 0.0) +
                (double.tryParse(_lAT.text) ?? 0.0) +
                (double.tryParse(_incineration.text) ?? 0.0) +
                (double.tryParse(_afrf.text) ?? 0.0);
            _totalWaste.text = ac.toStringAsFixed(2);
          },
          keyboardType: const TextInputType.numberWithOptions(
            signed: true,
            decimal: true,
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(9),
            DecimalTextInputFormatter(decimalRange: 3)
          ],
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(width: 1, color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide:
                    const BorderSide(width: 1, color: kReSustainabilityRed),
              ),
              floatingLabelAlignment: FloatingLabelAlignment.start,
              label: const Text(
                'DLF',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: kGreyTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              border: const OutlineInputBorder(),
              suffixText: "MT"),
        ),
        SizedBox(
          height: 3.h,
        ),
        TextFormField(
          controller: _lAT,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Enter LAT";
            }
            return null;
          },
          onChanged: (value) {
            _totalWaste.text = "";
            double ac = (double.tryParse(_dLF.text) ?? 0.0) +
                (double.tryParse(_lAT.text) ?? 0.0) +
                (double.tryParse(_incineration.text) ?? 0.0) +
                (double.tryParse(_afrf.text) ?? 0.0);
            _totalWaste.text = ac.toStringAsFixed(2);
          },
          keyboardType: const TextInputType.numberWithOptions(
            signed: true,
            decimal: true,
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(9),
            DecimalTextInputFormatter(decimalRange: 3)
          ],
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(width: 1, color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide:
                    const BorderSide(width: 1, color: kReSustainabilityRed),
              ),
              floatingLabelAlignment: FloatingLabelAlignment.start,
              label: const Text(
                'LAT',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: kGreyTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              border: const OutlineInputBorder(),
              suffixText: "MT"),
        ),
        SizedBox(
          height: 3.h,
        ),
        TextFormField(
          controller: _incineration,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Enter Incineration";
            }
            return null;
          },
          onChanged: (value) {
            _totalWaste.text = "";
            double ac = (double.tryParse(_dLF.text) ?? 0.0) +
                (double.tryParse(_lAT.text) ?? 0.0) +
                (double.tryParse(_incineration.text) ?? 0.0) +
                (double.tryParse(_afrf.text) ?? 0.0);
            _totalWaste.text = ac.toStringAsFixed(2);
          },
          keyboardType: const TextInputType.numberWithOptions(
            signed: true,
            decimal: true,
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(9),
            DecimalTextInputFormatter(decimalRange: 3)
          ],
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(width: 1, color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide:
                    const BorderSide(width: 1, color: kReSustainabilityRed),
              ),
              floatingLabelAlignment: FloatingLabelAlignment.start,
              label: const Text(
                'Incineration',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: kGreyTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              border: const OutlineInputBorder(),
              suffixText: "MT"),
        ),
        SizedBox(
          height: 3.h,
        ),
        TextFormField(
          controller: _afrf,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Enter AFRF";
            }
            return null;
          },
          onChanged: (value) async {
            _totalWaste.text = "";
            double ac = (double.tryParse(_dLF.text) ?? 0.0) +
                (double.tryParse(_lAT.text) ?? 0.0) +
                (double.tryParse(_incineration.text) ?? 0.0) +
                (double.tryParse(_afrf.text) ?? 0.0);
            _totalWaste.text = ac.toStringAsFixed(2);
          },
          keyboardType: const TextInputType.numberWithOptions(
            signed: true,
            decimal: true,
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(9),
            DecimalTextInputFormatter(decimalRange: 3)
          ],
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(width: 1, color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide:
                    const BorderSide(width: 1, color: kReSustainabilityRed),
              ),
              floatingLabelAlignment: FloatingLabelAlignment.start,
              label: const Text(
                'AFRF',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: kGreyTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              border: const OutlineInputBorder(),
              suffixText: "MT"),
        ),
        SizedBox(
          height: 3.h,
        ),
        TextFormField(
          controller: _totalWaste,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Enter Total Waste";
            }
            return null;
          },
          readOnly: true,
          keyboardType: const TextInputType.numberWithOptions(
            signed: true,
            decimal: true,
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(9),
            DecimalTextInputFormatter(decimalRange: 3)
          ],
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(width: 1, color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide:
                    const BorderSide(width: 1, color: kReSustainabilityRed),
              ),
              floatingLabelAlignment: FloatingLabelAlignment.start,
              label: const Text(
                'Total Waste',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: kGreyTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              border: const OutlineInputBorder(),
              suffixText: "MT"),
        ),
        SizedBox(
          height: 3.h,
        ),
        TextFormField(
          controller: _inciToAfrf,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Enter Incineration to AFRF";
            }
            return null;
          },
          readOnly: formName == "Receipt" ? false : true,
          keyboardType: const TextInputType.numberWithOptions(
            signed: true,
            decimal: true,
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(9),
            DecimalTextInputFormatter(decimalRange: 3)
          ],
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(width: 1, color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide:
                    const BorderSide(width: 1, color: kReSustainabilityRed),
              ),
              floatingLabelAlignment: FloatingLabelAlignment.start,
              label: const Text(
                'Incineration to AFRF',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: kGreyTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              border: const OutlineInputBorder(),
              suffixText: "MT"),
        ),
        formName == "Disposal"
            ? SizedBox(
                height: 3.h,
              )
            : const SizedBox(),
        formName == "Disposal"
            ? TextFormField(
                controller: _recycQtyInc,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter Recycling Qty to Incineration";
                  }
                  return null;
                },
                onChanged: (value) {
                  _recycQtyTotal.text = "";
                  double ac = (double.tryParse(_recycQtyInc.text) ?? 0.0) +
                      (double.tryParse(_recycQtyAfrf.text) ?? 0.0);
                  _recycQtyTotal.text = ac.toStringAsFixed(2);
                },
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(9),
                  DecimalTextInputFormatter(decimalRange: 3)
                ],
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          const BorderSide(width: 1, color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          width: 1, color: kReSustainabilityRed),
                    ),
                    floatingLabelAlignment: FloatingLabelAlignment.start,
                    label: const Text(
                      'Recycling Qty to Incineration',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        color: kGreyTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    border: const OutlineInputBorder(),
                    suffixText: "MT"),
              )
            : const SizedBox(),
        formName == "Disposal"
            ? SizedBox(
                height: 3.h,
              )
            : const SizedBox(),
        formName == "Disposal"
            ? TextFormField(
                controller: _recycQtyAfrf,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter Recycling Qty to Afrf";
                  }
                  return null;
                },
                onChanged: (value) {
                  _recycQtyTotal.text = "";
                  double ac = (double.tryParse(_recycQtyInc.text) ?? 0.0) +
                      (double.tryParse(_recycQtyAfrf.text) ?? 0.0);
                  _recycQtyTotal.text = ac.toStringAsFixed(2);
                },
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(9),
                  DecimalTextInputFormatter(decimalRange: 3)
                ],
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          const BorderSide(width: 1, color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          width: 1, color: kReSustainabilityRed),
                    ),
                    floatingLabelAlignment: FloatingLabelAlignment.start,
                    label: const Text(
                      'Recycling Qty to Afrf',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        color: kGreyTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    border: const OutlineInputBorder(),
                    suffixText: "MT"),
              )
            : const SizedBox(),
        formName == "Disposal"
            ? SizedBox(
                height: 3.h,
              )
            : const SizedBox(),
        formName == "Disposal"
            ? TextFormField(
                controller: _recycQtyTotal,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter Total Recycling Qty";
                  }
                  return null;
                },
                readOnly: true,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(9),
                  DecimalTextInputFormatter(decimalRange: 3)
                ],
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          const BorderSide(width: 1, color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          width: 1, color: kReSustainabilityRed),
                    ),
                    floatingLabelAlignment: FloatingLabelAlignment.start,
                    label: const Text(
                      'Total Recycling Qty',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        color: kGreyTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    border: const OutlineInputBorder(),
                    suffixText: "MT"),
              )
            : const SizedBox(),
      ],
    );
  }

  Widget closeStockForm(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 5.h,
        ),
        const Text(
          'Closing Stock',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 3.h,
        ),
        TextFormField(
          controller: _closeDLF,
          readOnly: true,
          validator: (value) {
            if (double.parse(value!) < 0) {
              return "Stock is not Adequate for disposal";
            }
            return null;
          },
          inputFormatters: [
            LengthLimitingTextInputFormatter(9),
            DecimalTextInputFormatter(decimalRange: 3)
          ],
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: kGreyColor),
              ),
              label: const Text(
                'DLF',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: kGreyTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              border: const OutlineInputBorder(),
              suffixText: "MT"),
        ),
        SizedBox(
          height: 3.h,
        ),
        TextFormField(
          controller: _closeLAT,
          validator: (value) {
            if (double.parse(value!) < 0) {
              return "Stock is not Adequate for disposal";
            }
            return null;
          },
          readOnly: true,
          inputFormatters: [
            LengthLimitingTextInputFormatter(9),
            DecimalTextInputFormatter(decimalRange: 3)
          ],
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: kGreyColor),
              ),
              label: const Text(
                'LAT',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: kGreyTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              border: const OutlineInputBorder(),
              suffixText: "MT"),
        ),
        SizedBox(
          height: 3.h,
        ),
        TextFormField(
          controller: _closeIncineration,
          validator: (value) {
            if (double.parse(value!) < 0) {
              return "Stock is not Adequate for disposal";
            }
            return null;
          },
          readOnly: true,
          inputFormatters: [
            LengthLimitingTextInputFormatter(9),
            DecimalTextInputFormatter(decimalRange: 3)
          ],
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: kGreyColor),
              ),
              label: const Text(
                'Incineration',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: kGreyTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              border: const OutlineInputBorder(),
              suffixText: "MT"),
        ),
        SizedBox(
          height: 3.h,
        ),
        TextFormField(
          controller: _closeAfrf,
          validator: (value) {
            if (double.parse(value!) < 0) {
              return "Stock is not Adequate for disposal";
            }
            return null;
          },
          readOnly: true,
          inputFormatters: [
            LengthLimitingTextInputFormatter(9),
            DecimalTextInputFormatter(decimalRange: 3)
          ],
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: kGreyColor),
              ),
              label: const Text(
                'AFRF',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: kGreyTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              border: const OutlineInputBorder(),
              suffixText: "MT"),
        ),
        SizedBox(
          height: 3.h,
        ),
        TextFormField(
          controller: _closeTotalWaste,
          validator: (value) {
            if (double.parse(value!) < 0) {
              return "Stock is not Adequate for disposal";
            }
            return null;
          },
          readOnly: true,
          inputFormatters: [
            LengthLimitingTextInputFormatter(9),
            DecimalTextInputFormatter(decimalRange: 3)
          ],
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: kGreyColor),
              ),
              label: const Text(
                'Total Waste',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: kGreyTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              border: const OutlineInputBorder(),
              suffixText: "MT"),
        ),
        SizedBox(
          height: 1.h,
        ),
      ],
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
            content: const Text('Do you want go back?\nDraft will be lost !',
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
                    {Navigator.of(context).pop(), Navigator.of(context).pop()},
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

  Future _onBackPressedToHome() async {
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
                'Do you want to go back to Home?\nDraft will be lost !'),
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
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Home(
                              googleSignInAccount: null,
                              userId: "",
                              emailId: "",
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
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const IrisProfileScreen()));
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
      useRootNavigator: false,
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          // False will prevent and true will allow to dismiss
          child: AlertDialog(
            title: const Text('Go Back'),
            content: const Text('Do you want go back?\nDraft will be lost !'),
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