import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:resus_test/AppStation/Iris/msw_operaton_head_screens/data_models/msw_process_data_list_model.dart';
import 'package:resus_test/Screens/components/custom_timeline.dart';
import 'package:resus_test/Utility/internetCheck.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../../Screens/home/home.dart';
import '../../../Utility/showDialogBox.dart';
import '../../../Utility/utils/constants.dart';
import '../../../Utility/utils/decimal_textfield_value.dart';
import '../Iris_Profile/iris_profile_screen.dart';
import 'apis/msw_process_date_checking_api.dart';
import 'msw_process_distribute_model.dart';
import 'msw_process_distribute_preview.dart';

class MSWPAndDScreen extends StatefulWidget {
  const MSWPAndDScreen({super.key});

  @override
  State<MSWPAndDScreen> createState() => _MSWPAndDScreenState();
}

class _MSWPAndDScreenState extends State<MSWPAndDScreen> {
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  var forms = ["COM", "RDF", "REC", "INERTS"];
  bool lastState = false;

  String formHeader = "";

  late final TextEditingController _totalWasteController =
      TextEditingController();
  late final TextEditingController _totalRDFController =
      TextEditingController();
  late final TextEditingController _totalInertsController =
      TextEditingController();
  late final TextEditingController _totalCompostController =
      TextEditingController();
  late final TextEditingController _totalRecyclablesController =
      TextEditingController();

  late final TextEditingController _vendornameCompostController =
      TextEditingController();
  late final TextEditingController _vendornameRDFController =
      TextEditingController();
  late final TextEditingController _vendornameRecyclableController =
      TextEditingController();
  late final TextEditingController _vendornameInertsController =
      TextEditingController();

  late final TextEditingController _compostController = TextEditingController();

  late final TextEditingController _rdfController = TextEditingController();
  late final TextEditingController _rdfToWteController =
      TextEditingController();

  late final TextEditingController _recyclableController =
      TextEditingController();
  late final TextEditingController _recyclableToRecycleUnitController =
      TextEditingController();

  late final TextEditingController _inertsController = TextEditingController();
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

  DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 100)),
    end: DateTime.now(),
  );

  late MswProcessingDataListRequestModel _mswProcessingDataListRequestModel;

  @override
  void initState() {
    formHeader = forms[0];
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _locationController.text = await getSiteName();
      _siteNameController.text = await getSiteName();
    });
    _mswProcessingDataListRequestModel = MswProcessingDataListRequestModel();
    GetMswProcessDateCheckingListAPIService
        getMswProcessDateCheckingListAPIService =
        GetMswProcessDateCheckingListAPIService();
    getMswProcessDateCheckingListAPIService.getMswProcessDateListApiCall(
        _mswProcessingDataListRequestModel,
        _dateInputController.value.text == ""
            ? ""
            : DateFormat('yyyy-MM-dd').format(dateRange.start),
        _dateInputController.value.text == ""
            ? ""
            : DateFormat('yyyy-MM-dd').format(dateRange.end));

    super.initState();
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
            preferredSize: const Size.fromHeight(60.0),
            child: AppBar(
              centerTitle: true,
              title: const Text(
                "P & D",
                style: TextStyle(
                    fontFamily: "ARIAL",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              leading: InkWell(
                  onTap: () async {
                    _onBackButtonClicked();
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
                            height: 3.h,
                          ),

                          formHeader == "COM"
                              ? const Text(
                                  'Processing-Compost ',
                                  style: TextStyle(
                                    fontFamily:
                                        'Roboto', // Specify Roboto font family
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : const SizedBox(),
                          formHeader == "COM"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "COM"
                              ? TextFormField(
                                  controller: _totalWasteController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter Total Waste";
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
                                        'Total Waste',
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
                          formHeader == "COM"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "COM"
                              ? TextFormField(
                                  controller: _totalCompostController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter Total Compost";
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
                                        'Total Compost',
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

                          formHeader == "COM"
                              ? SizedBox(
                                  height: 4.h,
                                )
                              : const SizedBox(),

                          formHeader == "COM"
                              ? const Text(
                                  'Distribute-Compost Outflow',
                                  style: TextStyle(
                                    fontFamily:
                                        'Roboto', // Specify Roboto font family
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : const SizedBox(),
                          formHeader == "COM"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "COM"
                              ? TextFormField(
                                  controller: _vendornameCompostController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter Vendor Name";
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.text,
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
                                      'Vendor Name',
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
                          formHeader == "COM"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "COM"
                              ? TextFormField(
                                  controller: _compostController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter Compost";
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
                                        'Compost',
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

                          // SizedBox(height: 1.h,),

                          formHeader == "RDF"
                              ? const Text(
                                  'Processing-RDF ',
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
                                  controller: _totalRDFController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter Total RDF";
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
                                        'Total RDF',
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
                                  height: 4.h,
                                )
                              : const SizedBox(),

                          formHeader == "RDF"
                              ? const Text(
                                  'Distribute-RDF Outflow',
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
                                  controller: _vendornameRDFController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter Vendor Name";
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.text,
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
                                      'Vendor Name',
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
                          formHeader == "RDF"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "RDF"
                              ? TextFormField(
                                  controller: _rdfController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter RDF";
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
                                        'RDF',
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
                                  controller: _rdfToWteController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter RDF to WTE";
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
                                        ' RDF to WTE',
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

                          formHeader == "REC"
                              ? const Text(
                                  'Processing-Recyclable ',
                                  style: TextStyle(
                                    fontFamily:
                                        'Roboto', // Specify Roboto font family
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : const SizedBox(),
                          formHeader == "REC"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "REC"
                              ? TextFormField(
                                  controller: _totalRecyclablesController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter Total Recyclable";
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
                                        'Total Recyclable',
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
                          formHeader == "REC"
                              ? SizedBox(
                                  height: 4.h,
                                )
                              : const SizedBox(),

                          formHeader == "REC"
                              ? const Text(
                                  'Distribute-Recyclable Outflow',
                                  style: TextStyle(
                                    fontFamily:
                                        'Roboto', // Specify Roboto font family
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : const SizedBox(),
                          formHeader == "REC"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "REC"
                              ? TextFormField(
                                  controller: _vendornameRecyclableController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter Vendor Name";
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.text,
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
                                      'Vendor Name',
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
                          formHeader == "REC"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "REC"
                              ? TextFormField(
                                  controller: _recyclableController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter Recyclable";
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
                                        'Recyclable',
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
                          formHeader == "REC"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "REC"
                              ? TextFormField(
                                  controller:
                                      _recyclableToRecycleUnitController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter Recyclable to Recycle Unit";
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
                                        'Recyclable to Recycle Unit',
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

                          formHeader == "INERTS"
                              ? const Text(
                                  'Processing-Inerts ',
                                  style: TextStyle(
                                    fontFamily:
                                        'Roboto', // Specify Roboto font family
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : const SizedBox(),
                          formHeader == "INERTS"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "INERTS"
                              ? TextFormField(
                                  controller: _totalInertsController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter Total Inerts";
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
                                        'Total Inerts',
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
                          formHeader == "INERTS"
                              ? SizedBox(
                                  height: 4.h,
                                )
                              : const SizedBox(),
                          formHeader == "INERTS"
                              ? const SizedBox(
                                  child: Text(
                                    'Distribute-Inerts Outflow',
                                    style: TextStyle(
                                      fontFamily:
                                          'Roboto', // Specify Roboto font family
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                          formHeader == "INERTS"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "INERTS"
                              ? TextFormField(
                                  controller: _vendornameInertsController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter Vendor Name";
                                    }
                                    return null;
                                  },
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[a-zA-Z\s]')),
                                  ],
                                  keyboardType: TextInputType.text,
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
                                      'Vendor Name',
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
                          formHeader == "INERTS"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "INERTS"
                              ? TextFormField(
                                  controller: _inertsController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter Inerts";
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
                                        'Inerts',
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

                          formHeader == "INERTS"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "INERTS"
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
                          formHeader == "INERTS"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "INERTS"
                              ? ValueListenableBuilder(
                                  valueListenable: mswProcessingDateChecking,
                                  builder: (BuildContext ctx,
                                      List<MswProcessDataListResponseModel>
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
                                              for (MswProcessDataListResponseModel data
                                                  in mswDataList) {
                                                if (data.date == selectedDate) {
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
                          formHeader == "INERTS"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "INERTS"
                              ? FutureBuilder(
                                  future: getSiteName(),
                                  builder: (context, snapshot) {
                                    return TextFormField(
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
                                    );
                                  })
                              : const SizedBox(),
                          formHeader == "INERTS"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "INERTS"
                              ? FutureBuilder(
                                  future: getSiteName(),
                                  builder: (context, snapshot) {
                                    return TextFormField(
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
                                    );
                                  })
                              : const SizedBox(),
                          formHeader == "INERTS"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                          formHeader == "INERTS"
                              ? Stack(
                                  children: [
                                    TextFormField(
                                      focusNode: _focusNode,
                                      controller: _commentsController,
                                      onChanged: (value) {
                                        _commentsController.text = value;
                                      },
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
                          formHeader == "INERTS"
                              ? SizedBox(
                                  height: 3.h,
                                )
                              : const SizedBox(),
                        ],
                      ),
                    )),
                Positioned(
                    top: 10.0,
                    left: 10.0,
                    right: 10.0,
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
                              isPast: formHeader == "RDF" ||
                                      formHeader == "REC" ||
                                      formHeader == "INERTS"
                                  ? true
                                  : false,
                              eventName: "Compost",
                              width: 90,
                            ),
                            TimeLine(
                              isFirst: false,
                              isLast: false,
                              isPast:
                                  formHeader == "REC" || formHeader == "INERTS"
                                      ? true
                                      : false,
                              eventName: "RDF",
                              width: 90,
                            ),
                            TimeLine(
                              isFirst: false,
                              isLast: false,
                              isPast: formHeader == "INERTS" ? true : false,
                              eventName: "Recyclable",
                              width: 90,
                            ),
                            TimeLine(
                              isFirst: false,
                              isLast: true,
                              isPast: lastState ? true : false,
                              eventName: "Inerts",
                              width: 90,
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
                formHeader == "RDF" ||
                        formHeader == "REC" ||
                        formHeader == "INERTS"
                    ? InkWell(
                        onTap: () {
                          if (formHeader == "RDF") {
                            setState(() {
                              lastState = false;
                              formHeader = forms[0];
                            });
                          } else if (formHeader == "REC") {
                            setState(() {
                              lastState = false;
                              formHeader = forms[1];
                            });
                          } else {
                            setState(() {
                              lastState = false;
                              formHeader = forms[2];
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
                      if (formHeader == "COM") {
                        setState(() {
                          formHeader = forms[1];
                        });
                      } else if (formHeader == "REC") {
                        setState(() {
                          lastState = false;
                          formHeader = forms[3];
                        });
                      } else if (formHeader == "RDF") {
                        setState(() {
                          lastState = false;
                          formHeader = forms[2];
                        });
                      } else if (formHeader == "INERTS") {
                        setState(() {
                          lastState = true;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return MswProcessDistributePreview(
                                  mswDistributeModel: MswProcessDistributeModel(
                                      vendorNameCompost:
                                          _vendornameCompostController.text,
                                      vendorNameRDF:
                                          _vendornameRDFController.text,
                                      vendorNameRecyclable:
                                          _vendornameRecyclableController.text,
                                      vendorNameInerts:
                                          _vendornameInertsController.text,
                                      compost: _compostController.text,
                                      rdf: _rdfController.text,
                                      rdfToWte: _rdfToWteController.text,
                                      recyclable: _recyclableController.text,
                                      recyclableToRecycleUnit:
                                          _recyclableToRecycleUnitController
                                              .text,
                                      inerts: _inertsController.text,
                                      location: _locationController.text,
                                      siteName: _siteNameController.text,
                                      selectedDate: selectedDate,
                                      comments: _commentsController.text,
                                      totalWaste: _totalWasteController.text,
                                      totalCompost:
                                          _totalCompostController.text,
                                      totalRDF: _totalRDFController.text,
                                      totalRecyclable:
                                          _totalRecyclablesController.text,
                                      totalInerts:
                                          _totalInertsController.text));
                            },
                          ),
                        );
                      } else {
                        setState(() {
                          formHeader = forms[3];
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

  getInit() {}

  Future<String> getSiteName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("SITE_NAME").toString();
  }
}
