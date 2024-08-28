// ignore_for_file: non_constant_identifier_names
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:resus_test/AppStation/Iris/api/msw_wte_date_checking_api.dart';
import 'package:resus_test/AppStation/Iris/form/msw_wte_preview.dart';
import 'package:resus_test/AppStation/Iris/model/msw_wte_model.dart';
import 'package:resus_test/Screens/components/custom_timeline.dart';
import 'package:resus_test/Utility/internetCheck.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../../Screens/home/home.dart';
import '../../../Utility/showDialogBox.dart';
import '../../../Utility/utils/constants.dart';
import '../../../Utility/utils/decimal_textfield_value.dart';
import '../Iris_Profile/iris_profile_screen.dart';
import '../model/msw_wte_data_list_model.dart';

class MswWteForm extends StatefulWidget {
  const MswWteForm({super.key});

  @override
  State<MswWteForm> createState() => _WteFormState();
}

class _WteFormState extends State<MswWteForm> {
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  int lastIndex = 3;
  int firstIndex = 0;
  String RDF = "RDF";
  String Generation = "Gen";
  String Ash = "Ash";

  var forms = ["RDF", "GEN", "ASH"];
  bool lastState = false;

  String formHeader = "";

  late MswWteDataListRequestModel _mswWteDateListRequestModel;

  DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 100)),
    end: DateTime.now(),
  );

  late final TextEditingController _rdfReceiptController =
      TextEditingController();
  late final TextEditingController _rdfCombustedController =
      TextEditingController();

  late final TextEditingController _streamGenController =
      TextEditingController();
  late final TextEditingController _powerGenController =
      TextEditingController();
  late final TextEditingController _powerExportController =
      TextEditingController();
  late final TextEditingController _auxillaryConsumptionController =
      TextEditingController();
  late final TextEditingController _powerGenCapacityController =
      TextEditingController();
  late final TextEditingController _plantLoadFactorController =
      TextEditingController();

  late final TextEditingController _bottomAshController =
      TextEditingController();
  late final TextEditingController _flyAshController = TextEditingController();
  late final TextEditingController _totalAshController =
      TextEditingController();

  late final TextEditingController _dateInputController =
      TextEditingController();
  late final TextEditingController _locationController =
      TextEditingController();
  late final TextEditingController _siteNameController =
      TextEditingController();
  late final TextEditingController _commentsController =
      TextEditingController();

  final FocusNode _focusNode = FocusNode();

  int calculation = 10;
  String selectedDate = "";

  @override
  void initState() {
    formHeader = forms[0];
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _locationController.text = await getSiteName();
      _siteNameController.text = await getSiteName();
    });
    getConnectivity();
    super.initState();
  }

  getInit() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String siteID = prefs.getString("site").toString();
    _mswWteDateListRequestModel = MswWteDataListRequestModel();
    GetMswWteDateCheckingListAPIService getMswWteDateCheckingListAPIService =
        GetMswWteDateCheckingListAPIService();
    getMswWteDateCheckingListAPIService.getMswWteDateListApiCall(
        _mswWteDateListRequestModel,
        _dateInputController.value.text == ""
            ? ""
            : DateFormat('yyyy-MM-dd').format(dateRange.start),
        _dateInputController.value.text == ""
            ? ""
            : DateFormat('yyyy-MM-dd').format(dateRange.end),
        siteID);
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
                "WTE Form",
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
                          SizedBox(
                            height: 2.h,
                          ),
                          formHeader == "RDF"
                              ? const Text(
                                  'RDF Data',
                                  style: TextStyle(
                                    fontFamily:
                                        'Roboto', // Specify Roboto font family
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : const SizedBox(),
                          formHeader == "RDF"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "RDF"
                              ? TextFormField(
                                  controller: _rdfReceiptController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter RDF Receipt";
                                    }
                                    return null;
                                  },
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    signed: true,
                                    decimal: true,
                                  ),
                                  inputFormatters: [
                                    //LengthLimitingTextInputFormatter(8),
                                    DecimalTextInputFormatter(decimalRange: 3)
                                  ],
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: const BorderSide(
                                            width: 1, color: Colors.black),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: const BorderSide(
                                            width: 1,
                                            color: kReSustainabilityRed),
                                      ),
                                      floatingLabelAlignment:
                                          FloatingLabelAlignment.start,
                                      label: const Text(
                                        'RDF Receipt',
                                        style: TextStyle(
                                          fontFamily:
                                              'Roboto', // Specify Roboto font family
                                          fontSize: 14,
                                          color: kGreyTextColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      border: const OutlineInputBorder(),
                                      suffixText: "MT"),
                                )
                              : const SizedBox(),
                          formHeader == "RDF"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "RDF"
                              ? TextFormField(
                                  controller: _rdfCombustedController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter RDF Combusted";
                                    }
                                    return null;
                                  },
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    signed: true,
                                    decimal: true,
                                  ),
                                  inputFormatters: [
                                    //LengthLimitingTextInputFormatter(8),
                                    DecimalTextInputFormatter(decimalRange: 3)
                                  ],
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: const BorderSide(
                                            width: 1, color: Colors.black),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: const BorderSide(
                                            width: 1,
                                            color: kReSustainabilityRed),
                                      ),
                                      floatingLabelAlignment:
                                          FloatingLabelAlignment.start,
                                      label: const Text(
                                        'RDF Combusted',
                                        style: TextStyle(
                                          fontFamily:
                                              'Roboto', // Specify Roboto font family
                                          fontSize: 14,
                                          color: kGreyTextColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      border: const OutlineInputBorder(),
                                      suffixText: "MT"),
                                )
                              : const SizedBox(),
                          SizedBox(
                            height: 1.h,
                          ),
                          formHeader == "GEN"
                              ? const Text(
                                  'Generation Data',
                                  style: TextStyle(
                                    fontFamily:
                                        'Roboto', // Specify Roboto font family
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : const SizedBox(),
                          formHeader == "GEN"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "GEN"
                              ? TextFormField(
                                  controller: _streamGenController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter Steam Generation";
                                    }
                                    return null;
                                  },
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    signed: true,
                                    decimal: true,
                                  ),
                                  inputFormatters: [
                                    //LengthLimitingTextInputFormatter(8),
                                    DecimalTextInputFormatter(decimalRange: 3)
                                  ],
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: const BorderSide(
                                            width: 1, color: Colors.black),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: const BorderSide(
                                            width: 1,
                                            color: kReSustainabilityRed),
                                      ),
                                      floatingLabelAlignment:
                                          FloatingLabelAlignment.start,
                                      label: const Text(
                                        'Steam Generation',
                                        style: TextStyle(
                                          fontFamily:
                                              'Roboto', // Specify Roboto font family
                                          fontSize: 14,
                                          color: kGreyTextColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      border: const OutlineInputBorder(),
                                      suffixText: "TPD"),
                                )
                              : const SizedBox(),
                          formHeader == "GEN"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "GEN"
                              ? TextFormField(
                                  controller: _powerGenController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter Power Generation";
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    _auxillaryConsumptionController.text = "";
                                    _plantLoadFactorController.text = "0.0";
                                    double ac = (double.tryParse(
                                                _powerGenController.text) ??
                                            0.0) -
                                        (double.tryParse(
                                                _powerExportController.text) ??
                                            0.0);
                                    _auxillaryConsumptionController.text =
                                        ac.toString();
                                    double plf = ((double.tryParse(
                                                    _powerGenController.text) ??
                                                0.0) /
                                            (double.tryParse(
                                                    _powerGenCapacityController
                                                        .text) ??
                                                0.0)) *
                                        100;
                                    String total = plf.toStringAsFixed(2);
                                    _plantLoadFactorController.text = total;
                                  },
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    signed: true,
                                    decimal: true,
                                  ),
                                  inputFormatters: [
                                    //LengthLimitingTextInputFormatter(8),
                                    DecimalTextInputFormatter(decimalRange: 3)
                                  ],
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: const BorderSide(
                                            width: 1, color: Colors.black),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: const BorderSide(
                                            width: 1,
                                            color: kReSustainabilityRed),
                                      ),
                                      floatingLabelAlignment:
                                          FloatingLabelAlignment.start,
                                      label: const Text(
                                        'Power Generation',
                                        style: TextStyle(
                                          fontFamily:
                                              'Roboto', // Specify Roboto font family
                                          fontSize: 14,
                                          color: kGreyTextColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      border: const OutlineInputBorder(),
                                      suffixText: "MW"),
                                )
                              : const SizedBox(),
                          formHeader == "GEN"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "GEN"
                              ? TextFormField(
                                  controller: _powerExportController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter Power Export";
                                    }
                                    if ((double.tryParse(
                                                _powerGenController.text) ??
                                            0.0) <
                                        (double.tryParse(
                                                _powerExportController.text) ??
                                            0.0)) {
                                      _powerExportController.text = "";
                                      return "Enter Power Export value less than Power Generation";
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    _auxillaryConsumptionController.text = "";
                                    double sum = (double.tryParse(
                                                _powerGenController.text) ??
                                            0.0) -
                                        (double.tryParse(
                                                _powerExportController.text) ??
                                            0.0);
                                    _auxillaryConsumptionController.text =
                                        sum.toString();
                                  },
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    signed: true,
                                    decimal: true,
                                  ),
                                  inputFormatters: [
                                    //LengthLimitingTextInputFormatter(8),
                                    DecimalTextInputFormatter(decimalRange: 3)
                                  ],
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: const BorderSide(
                                            width: 1, color: Colors.black),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: const BorderSide(
                                            width: 1,
                                            color: kReSustainabilityRed),
                                      ),
                                      floatingLabelAlignment:
                                          FloatingLabelAlignment.start,
                                      label: const Text(
                                        ' Power Export',
                                        style: TextStyle(
                                          fontFamily:
                                              'Roboto', // Specify Roboto font family
                                          fontSize: 14,
                                          color: kGreyTextColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      border: const OutlineInputBorder(),
                                      suffixText: "MW"),
                                )
                              : const SizedBox(),
                          formHeader == "GEN"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "GEN"
                              ? TextFormField(
                                  controller: _auxillaryConsumptionController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter Auxiliary Consumption";
                                    }
                                    return null;
                                  },
                                  readOnly: true,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    signed: true,
                                    decimal: true,
                                  ),
                                  inputFormatters: [
                                    //LengthLimitingTextInputFormatter(8),
                                    DecimalTextInputFormatter(decimalRange: 3)
                                  ],
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: const BorderSide(
                                            width: 1, color: Colors.black),
                                      ),
                                      floatingLabelAlignment:
                                          FloatingLabelAlignment.start,
                                      label: const Text(
                                        'Auxiliary Consumption',
                                        style: TextStyle(
                                          fontFamily:
                                              'Roboto', // Specify Roboto font family
                                          fontSize: 14,
                                          color: kGreyTextColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      border: const OutlineInputBorder(),
                                      suffixText: "MW"),
                                )
                              : const SizedBox(),
                          formHeader == "GEN"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "GEN"
                              ? TextFormField(
                                  controller: _powerGenCapacityController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter Power Generation Capacity";
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    _plantLoadFactorController.text = "";
                                    double plf = ((double.tryParse(
                                                    _powerGenController.text) ??
                                                0.0) /
                                            (double.tryParse(
                                                    _powerGenCapacityController
                                                        .text) ??
                                                0.0)) *
                                        100;
                                    String total = plf.toStringAsFixed(2);
                                    _plantLoadFactorController.text = total;
                                  },
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    signed: true,
                                    decimal: true,
                                  ),
                                  inputFormatters: [
                                    //LengthLimitingTextInputFormatter(8),
                                    DecimalTextInputFormatter(decimalRange: 3)
                                  ],
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: const BorderSide(
                                            width: 1, color: Colors.black),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: const BorderSide(
                                            width: 1,
                                            color: kReSustainabilityRed),
                                      ),
                                      floatingLabelAlignment:
                                          FloatingLabelAlignment.start,
                                      label: const Text(
                                        'Power Generation Capacity',
                                        style: TextStyle(
                                          fontFamily:
                                              'Roboto', // Specify Roboto font family
                                          fontSize: 14,
                                          color: kGreyTextColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      border: const OutlineInputBorder(),
                                      suffixText: "MW"),
                                )
                              : const SizedBox(),
                          formHeader == "GEN"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "GEN"
                              ? TextFormField(
                                  controller: _plantLoadFactorController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter Plant Load Factor";
                                    }
                                    return null;
                                  },
                                  readOnly: true,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    signed: true,
                                    decimal: true,
                                  ),
                                  inputFormatters: [
                                    //LengthLimitingTextInputFormatter(8),
                                    DecimalTextInputFormatter(decimalRange: 3)
                                  ],
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: const BorderSide(
                                            width: 1, color: Colors.black),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: const BorderSide(
                                            width: 1,
                                            color: kReSustainabilityRed),
                                      ),
                                      floatingLabelAlignment:
                                          FloatingLabelAlignment.start,
                                      label: const Text(
                                        'Power Load Factor',
                                        style: TextStyle(
                                          fontFamily:
                                              'Roboto', // Specify Roboto font family
                                          fontSize: 14,
                                          color: kGreyTextColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      border: const OutlineInputBorder(),
                                      suffixText: "%"),
                                )
                              : const SizedBox(),
                          formHeader == "GEN"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "ASH"
                              ? const Text(
                                  'Ash Data',
                                  style: TextStyle(
                                    fontFamily:
                                        'Roboto', // Specify Roboto font family
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : const SizedBox(),
                          formHeader == "ASH"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "ASH"
                              ? TextFormField(
                                  controller: _bottomAshController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter Bottom Ash";
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    _totalAshController.text = "";
                                    double bottomAshValue = double.tryParse(
                                            _bottomAshController.text) ??
                                        0.0;
                                    double flyAshValue = double.tryParse(
                                            _flyAshController.text) ??
                                        0.0;
                                    double sum = bottomAshValue + flyAshValue;
                                    String total = sum.toStringAsFixed(2);
                                    _totalAshController.text = total;
                                  },
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    signed: true,
                                    decimal: true,
                                  ),
                                  inputFormatters: [
                                    //LengthLimitingTextInputFormatter(8),
                                    DecimalTextInputFormatter(decimalRange: 3)
                                  ],
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: const BorderSide(
                                            width: 1, color: Colors.black),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: const BorderSide(
                                            width: 1,
                                            color: kReSustainabilityRed),
                                      ),
                                      floatingLabelAlignment:
                                          FloatingLabelAlignment.start,
                                      label: const Text(
                                        'Bottom Ash',
                                        style: TextStyle(
                                          fontFamily:
                                              'Roboto', // Specify Roboto font family
                                          fontSize: 14,
                                          color: kGreyTextColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      border: const OutlineInputBorder(),
                                      suffixText: "MT"),
                                )
                              : const SizedBox(),
                          formHeader == "ASH"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "ASH"
                              ? TextFormField(
                                  controller: _flyAshController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter Fly Ash";
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    double bottomAshValue = double.tryParse(
                                            _bottomAshController.text) ??
                                        0.0;
                                    double flyAshValue = double.tryParse(
                                            _flyAshController.text) ??
                                        0.0;
                                    double sum = bottomAshValue + flyAshValue;
                                    String total = sum.toStringAsFixed(2);
                                    _totalAshController.text = total;
                                  },
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    signed: true,
                                    decimal: true,
                                  ),
                                  inputFormatters: [
                                    //LengthLimitingTextInputFormatter(8),
                                    DecimalTextInputFormatter(decimalRange: 3)
                                  ],
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: const BorderSide(
                                            width: 1, color: Colors.black),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: const BorderSide(
                                            width: 1,
                                            color: kReSustainabilityRed),
                                      ),
                                      floatingLabelAlignment:
                                          FloatingLabelAlignment.start,
                                      label: const Text(
                                        'Fly Ash',
                                        style: TextStyle(
                                          fontFamily:
                                              'Roboto', // Specify Roboto font family
                                          fontSize: 14,
                                          color: kGreyTextColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      border: const OutlineInputBorder(),
                                      suffixText: "MT"),
                                )
                              : const SizedBox(),
                          formHeader == "ASH"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "ASH"
                              ? TextFormField(
                                  controller: _totalAshController,
                                  readOnly: true,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    signed: true,
                                    decimal: true,
                                  ),
                                  inputFormatters: [
                                    //LengthLimitingTextInputFormatter(8),
                                    DecimalTextInputFormatter(decimalRange: 3)
                                  ],
                                  focusNode: FocusNode(canRequestFocus: true),
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: const BorderSide(
                                            width: 1, color: Colors.black),
                                      ),
                                      floatingLabelAlignment:
                                          FloatingLabelAlignment.start,
                                      label: const Text(
                                        'Total Ash',
                                        style: TextStyle(
                                          fontFamily:
                                              'Roboto', // Specify Roboto font family
                                          fontSize: 14,
                                          color: kGreyTextColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      border: const OutlineInputBorder(),
                                      suffixText: "MT"),
                                )
                              : const SizedBox(),
                          formHeader == "ASH"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "ASH"
                              ? const Text(
                                  'Others',
                                  style: TextStyle(
                                    fontFamily:
                                        'Roboto', // Specify Roboto font family
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : const SizedBox(),
                          formHeader == "ASH"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "ASH"
                              ? ValueListenableBuilder(
                                  valueListenable: mswWteDateChecking,
                                  builder: (BuildContext ctx,
                                      List<MswWteDataListResponseModel>
                                          mswDataList,
                                      Widget? child) {
                                    if (mswDataList.isNotEmpty) {
                                      return TextFormField(
                                          controller: _dateInputController,
                                          readOnly: true,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Please Select Date ";
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: const BorderSide(
                                                  width: 1,
                                                  color: Colors.black),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: const BorderSide(
                                                  width: 1,
                                                  color: kReSustainabilityRed),
                                            ),
                                            floatingLabelAlignment:
                                                FloatingLabelAlignment.start,
                                            label: const Text(
                                              'Select Date',
                                              style: TextStyle(
                                                fontFamily:
                                                    'Roboto', // Specify Roboto font family
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            labelStyle: const TextStyle(
                                                color: Colors.black),
                                            border: const OutlineInputBorder(),
                                            suffixIcon: const Icon(
                                              Icons.calendar_month_outlined,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          onTap: () async {
                                            SystemChannels.textInput
                                                .invokeMethod('TextInput.hide');
                                            DateTime? pickedDate =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2024, 1),
                                              lastDate: DateTime.now(),
                                              useRootNavigator: false,
                                              initialEntryMode:
                                                  DatePickerEntryMode
                                                      .calendarOnly,
                                            );

                                            if (pickedDate != null) {
                                              selectedDate =
                                                  DateFormat('yyyy-MM-dd')
                                                      .format(pickedDate);
                                              bool flagDataAvailable = false;
                                              for (MswWteDataListResponseModel data
                                                  in mswDataList) {
                                                if (data.mswWteDate ==
                                                    selectedDate) {
                                                  _dateInputController.text =
                                                      "";
                                                  flagDataAvailable = true;
                                                  break;
                                                }
                                              }
                                              if (flagDataAvailable) {
                                                showDialog(
                                                    useRootNavigator: false,
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder: (_) =>
                                                        const ShowDialogBox(
                                                          title:
                                                              'Data is already available in that day',
                                                        ));
                                                return;
                                              } else {
                                                selectedDate =
                                                    DateFormat('yyyy-MM-dd')
                                                        .format(pickedDate);
                                              }
                                              _dateInputController.text =
                                                  DateFormat('dd/MM/yyyy')
                                                      .format(pickedDate);
                                            }
                                          });
                                    } else {
                                      return TextFormField(
                                          controller: _dateInputController,
                                          readOnly: true,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Please Select Date ";
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: const BorderSide(
                                                  width: 1,
                                                  color: Colors.black),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: const BorderSide(
                                                  width: 1,
                                                  color: kReSustainabilityRed),
                                            ),
                                            floatingLabelAlignment:
                                                FloatingLabelAlignment.start,
                                            label: const Text(
                                              'Select Date',
                                              style: TextStyle(
                                                fontFamily:
                                                    'Roboto', // Specify Roboto font family
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            labelStyle: const TextStyle(
                                                color: Colors.black),
                                            border: const OutlineInputBorder(),
                                            suffixIcon: const Icon(
                                              Icons.calendar_month_outlined,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          onTap: () async {
                                            SystemChannels.textInput
                                                .invokeMethod('TextInput.hide');
                                            DateTime? pickedDate =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2024, 1),
                                              lastDate: DateTime.now(),
                                              useRootNavigator: false,
                                              initialEntryMode:
                                                  DatePickerEntryMode
                                                      .calendarOnly,
                                            );

                                            if (pickedDate != null) {
                                              _dateInputController.text =
                                                  DateFormat('dd/MM/yyyy')
                                                      .format(pickedDate);
                                              selectedDate =
                                                  DateFormat('yyyy-MM-dd')
                                                      .format(pickedDate);
                                            }
                                          });
                                    }
                                  })
                              : const SizedBox(),
                          formHeader == "ASH"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "ASH"
                              ? TextFormField(
                                  controller: _locationController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter Location";
                                    }
                                    return null;
                                  },
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                          width: 1, color: Colors.black),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                          width: 1,
                                          color: kReSustainabilityRed),
                                    ),
                                    floatingLabelAlignment:
                                        FloatingLabelAlignment.start,
                                    label: const Text(
                                      'Location',
                                      style: TextStyle(
                                        fontFamily:
                                            'Roboto', // Specify Roboto font family
                                        fontSize: 14,
                                        color: kGreyTextColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    border: const OutlineInputBorder(),
                                  ),
                                )
                              : const SizedBox(),
                          formHeader == "ASH"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "ASH"
                              ? TextFormField(
                                  controller: _siteNameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter Site Name";
                                    }
                                    return null;
                                  },
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                          width: 1, color: Colors.black),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                          width: 1,
                                          color: kReSustainabilityRed),
                                    ),
                                    floatingLabelAlignment:
                                        FloatingLabelAlignment.start,
                                    label: const Text(
                                      'Site Name',
                                      style: TextStyle(
                                        fontFamily:
                                            'Roboto', // Specify Roboto font family
                                        fontSize: 14,
                                        color: kGreyTextColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    border: const OutlineInputBorder(),
                                  ),
                                )
                              : const SizedBox(),
                          formHeader == "ASH"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "ASH"
                              ? Stack(
                                  children: [
                                    TextFormField(
                                      focusNode: _focusNode,
                                      onChanged: (value) {
                                        _commentsController.text = value;
                                      },
                                      controller: _commentsController,
                                      maxLines: 3,
                                      keyboardType: TextInputType.multiline,
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: const BorderSide(
                                              width: 1, color: Colors.black),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: const BorderSide(
                                              width: 1,
                                              color: kReSustainabilityRed),
                                        ),
                                        floatingLabelAlignment:
                                            FloatingLabelAlignment.start,
                                        label: const Text(
                                          'Comments',
                                          style: TextStyle(
                                            fontFamily:
                                                'Roboto', // Specify Roboto font family
                                            fontSize: 14,
                                            color: kGreyTextColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 2,
                                      right: 2,
                                      child: GestureDetector(
                                        onTap: () =>
                                            FocusScope.of(context)
                                                .unfocus(),
                                        child: const Icon(
                                            Icons.arrow_forward,
                                            color: Colors.black,
                                            size: 25),
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          formHeader == "ASH"
                              ? SizedBox(
                                  height: 3.h,
                                )
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
                        height: 70,
                        width: 500,
                        child: ListView(
                          physics: const NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          children: [
                            TimeLine(
                              isFirst: true,
                              isLast: false,
                              isPast: formHeader == "GEN" || formHeader == "ASH"
                                  ? true
                                  : false,
                              eventName: "RDF",
                              width: 130,
                            ),
                            TimeLine(
                              isFirst: false,
                              isLast: false,
                              isPast: formHeader == "ASH" ? true : false,
                              eventName: "Generation",
                              width: 130,
                            ),
                            TimeLine(
                              isFirst: false,
                              isLast: true,
                              isPast: lastState ? true : false,
                              eventName: "Ash",
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
                formHeader == "GEN" || formHeader == "ASH"
                    ? InkWell(
                        onTap: () {
                          if (formHeader == "GEN") {
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
                  onTap: () {
                    if (formKey.currentState!.validate()) {
                      if (formHeader == "RDF") {
                        setState(() {
                          formHeader = forms[1];
                        });
                      } else if (formHeader == "ASH") {
                        setState(() {
                          lastState = true;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return MswWtePreview(
                                  mswWteModel: MswWteModel(
                                      rdfReceipt: _rdfReceiptController.text,
                                      rdfCombusted:
                                          _rdfCombustedController.text,
                                      streamGeneration:
                                          _streamGenController.text,
                                      powerGeneration: _powerGenController.text,
                                      powerExport: _powerExportController.text,
                                      auxillaryConsumption:
                                          _auxillaryConsumptionController.text,
                                      powerGenerationCapacity:
                                          _powerGenCapacityController.text,
                                      plantLoadFactor:
                                          _plantLoadFactorController.text,
                                      bottomAsh: _bottomAshController.text,
                                      flyAsh: _flyAshController.text,
                                      totalAsh: _totalAshController.text,
                                      siteName: _siteNameController.text,
                                      location: _locationController.text,
                                      selectedDate: selectedDate,
                                      comments: _commentsController.text));
                            },
                          ),
                        );
                      } else {
                        setState(() {
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
