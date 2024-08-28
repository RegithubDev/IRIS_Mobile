import "package:flutter/cupertino.dart";
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:resus_test/AppStation/Iris/Processing/processing_preview_screen.dart';
import 'package:resus_test/AppStation/Iris/api/get_processing_Date_checking.dart';
import 'package:resus_test/AppStation/Iris/model/process_preview_model.dart';
import 'package:resus_test/Utility/internetCheck.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../../Screens/home/home.dart';
import '../../../Utility/shared_preferences_string.dart';
import '../../../Utility/showDialogBox.dart';
import '../../../Utility/utils/constants.dart';
import '../../../Utility/utils/decimal_textfield_value.dart';
import '../../../custom_sharedPreference.dart';
import '../Iris_Profile/iris_profile_screen.dart';
import '../model/processing_data_list_model.dart';

class ProcessingScreen extends StatefulWidget {
  final String wasteType;
  final String siteID;
  const ProcessingScreen(
      {super.key, required this.wasteType, required this.siteID});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  late final TextEditingController _incinerationController =
      TextEditingController();
  late final TextEditingController _autoClaveController =
      TextEditingController();
  late final TextEditingController _totalWasteController =
      TextEditingController();
  late TextEditingController dateInputController = TextEditingController();
  late final TextEditingController _siteNameController =
      TextEditingController();
  late final TextEditingController _commentsController =
      TextEditingController();

  final FocusNode _focusNode = FocusNode();

  String selectedDate = "";

  late ProcessingDataListRequestModel _processingDataListRequestModel;

  DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 100)),
    end: DateTime.now(),
  );

  bool isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void initState() {
    super.initState();
    getConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('az');
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
            "Processing",
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
                            top: 30.0, left: 10, right: 10),
                        child: TextFormField(
                          onChanged: (value) {
                            if (value != "" &&
                                _autoClaveController.text != "") {
                              _totalWasteController
                                  .text = (double.parse(value) +
                                      double.parse(_autoClaveController.text))
                                  .toString();
                            } else {
                              _totalWasteController.text = "";
                            }
                          },
                          controller: _incinerationController,
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                            decimal: true,
                          ),
                          inputFormatters: [
                            // FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                            //LengthLimitingTextInputFormatter(8),
                            DecimalTextInputFormatter(decimalRange: 3)
                          ],
                          decoration: InputDecoration(
                            suffixText: 'MT',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.black),
                              //<-- SEE HERE
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.black),
                            ),
                            floatingLabelAlignment:
                                FloatingLabelAlignment.start,
                            label: RichText(
                                text: const TextSpan(children: [
                              TextSpan(
                                text: 'Incineration',
                                style: TextStyle(
                                  fontFamily:
                                      'Roboto', // Specify Roboto font family
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextSpan(
                                text: '*',
                                style: TextStyle(
                                  fontFamily:
                                      'Roboto', // Specify Roboto font family
                                  fontSize: 20,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ])),
                            labelStyle: const TextStyle(color: Colors.black),
                            // hintText: 'Incineration',
                            // hintStyle: const TextStyle(color: Colors.grey),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, left: 10, right: 10),
                        child: TextFormField(
                          onChanged: (value) {
                            if (value != "" &&
                                _incinerationController.text != "") {
                              _totalWasteController.text =
                                  (double.parse(value) +
                                          double.parse(
                                              _incinerationController.text))
                                      .toString();
                            } else {
                              _totalWasteController.text = "";
                            }
                          },
                          controller: _autoClaveController,
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                            decimal: true,
                          ),
                          inputFormatters: [
                            // FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                            //LengthLimitingTextInputFormatter(8),
                            DecimalTextInputFormatter(decimalRange: 3)
                          ],
                          decoration: InputDecoration(
                            suffixText: 'MT',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.black),
                              //<-- SEE HERE
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.black),
                            ),
                            floatingLabelAlignment:
                                FloatingLabelAlignment.start,
                            label: RichText(
                                text: const TextSpan(children: [
                              TextSpan(
                                text: 'Auto Clave',
                                style: TextStyle(
                                  fontFamily:
                                      'Roboto', // Specify Roboto font family
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextSpan(
                                text: '*',
                                style: TextStyle(
                                  fontFamily:
                                      'Roboto', // Specify Roboto font family
                                  fontSize: 20,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ])),
                            labelStyle: const TextStyle(color: Colors.black),
                            //T hintText: 'Auto Clave',
                            // hintStyle: const TextStyle(color: Colors.grey),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, left: 10, right: 10),
                        child: TextFormField(
                          readOnly: true,
                          controller: _totalWasteController,
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                            decimal: true,
                          ),
                          inputFormatters: [
                            // FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                            //LengthLimitingTextInputFormatter(8),
                            DecimalTextInputFormatter(decimalRange: 3)
                          ],
                          decoration: InputDecoration(
                            suffixText: 'MT',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.black),
                              //<-- SEE HERE
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.black),
                            ),
                            floatingLabelAlignment:
                                FloatingLabelAlignment.start,
                            label: RichText(
                                text: const TextSpan(children: [
                              TextSpan(
                                text: 'Total Waste',
                                style: TextStyle(
                                  fontFamily:
                                      'Roboto', // Specify Roboto font family
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextSpan(
                                text: '*',
                                style: TextStyle(
                                  fontFamily:
                                      'Roboto', // Specify Roboto font family
                                  fontSize: 20,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ])),
                            labelStyle: const TextStyle(color: Colors.black),
                            // hintText: 'Total Waste',
                            // hintStyle: const TextStyle(color: Colors.grey),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, left: 10, right: 10),
                        child: ValueListenableBuilder(
                          valueListenable: processingDateChecking,
                          builder: (BuildContext ctx,
                              List<ProcessingDataListResponseModel> dataList,
                              Widget? child) {
                            if (dataList.isNotEmpty) {
                              return TextFormField(
                                  readOnly: true,
                                  controller: dateInputController,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                          width: 1, color: Colors.black),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                          width: 1, color: Colors.black),
                                    ),
                                    floatingLabelAlignment:
                                        FloatingLabelAlignment.start,
                                    label: RichText(
                                        text: const TextSpan(children: [
                                      TextSpan(
                                        text: 'Select Date',
                                        style: TextStyle(
                                          fontFamily:
                                              'Roboto', // Specify Roboto font family
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '*',
                                        style: TextStyle(
                                          fontFamily:
                                              'Roboto', // Specify Roboto font family
                                          fontSize: 20,
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ])),
                                    labelStyle:
                                        const TextStyle(color: Colors.black),
                                    border: const OutlineInputBorder(),
                                    suffixIcon: const Icon(
                                      Icons.calendar_month,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  onTap: () async {
                                    SystemChannels.textInput
                                        .invokeMethod('TextInput.hide');
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2024, 1),
                                      lastDate: DateTime.now(),
                                      useRootNavigator: false,
                                      initialEntryMode:
                                          DatePickerEntryMode.calendarOnly,
                                    );

                                    if (pickedDate != null) {
                                      selectedDate = DateFormat('yyyy-MM-dd')
                                          .format(pickedDate);
                                      bool flagDataAvailable = false;
                                      for (ProcessingDataListResponseModel data
                                          in dataList) {
                                        if (data.processingDate ==
                                            selectedDate) {
                                          flagDataAvailable = true;
                                          break;
                                        }
                                      }
                                      if (flagDataAvailable) {
                                        showDialog(
                                            useRootNavigator: false,
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (_) => const ShowDialogBox(
                                                  title:
                                                      'Data is already available in that day',
                                                ));
                                        return;
                                      }
                                      dateInputController.text =
                                          DateFormat('dd/MM/yyyy')
                                              .format(pickedDate);
                                    }
                                  });
                            } else {
                              return TextFormField(
                                  readOnly: true,
                                  controller: dateInputController,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                          width: 1, color: Colors.black),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                          width: 1, color: Colors.black),
                                    ),
                                    floatingLabelAlignment:
                                        FloatingLabelAlignment.start,
                                    labelText: 'Select Date',
                                    labelStyle:
                                        const TextStyle(color: Colors.black),
                                    border: const OutlineInputBorder(),
                                    suffixIcon: const Icon(
                                      Icons.calendar_month,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  onTap: () async {
                                    SystemChannels.textInput
                                        .invokeMethod('TextInput.hide');
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2024, 1),
                                      lastDate: DateTime.now(),
                                      useRootNavigator: false,
                                      initialEntryMode:
                                          DatePickerEntryMode.calendarOnly,
                                    );

                                    if (pickedDate != null) {
                                      dateInputController.text =
                                          DateFormat('dd-MM-yyyy')
                                              .format(pickedDate);
                                      selectedDate = DateFormat('yyyy-MM-dd')
                                          .format(pickedDate);
                                    }
                                  });
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, left: 10, right: 10),
                        child: FutureBuilder<String>(
                            future: getSiteName(),
                            builder: (BuildContext context,
                                AsyncSnapshot<String> snapshot) {
                              if (snapshot.hasData) {
                                return TextFormField(
                                  readOnly: true,
                                  controller: _siteNameController,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                          width: 1, color: Colors.black),
                                      //<-- SEE HERE
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                          width: 1, color: Colors.black),
                                    ),
                                    floatingLabelAlignment:
                                        FloatingLabelAlignment.start,
                                    label: RichText(
                                        text: const TextSpan(children: [
                                      TextSpan(
                                        text: 'Site Name',
                                        style: TextStyle(
                                          fontFamily:
                                              'Roboto', // Specify Roboto font family
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '*',
                                        style: TextStyle(
                                          fontFamily:
                                              'Roboto', // Specify Roboto font family
                                          fontSize: 20,
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ])),
                                    labelStyle:
                                        const TextStyle(color: Colors.black),
                                    // hintText: 'Site Name',
                                    // hintStyle: const TextStyle(color: Colors.grey),
                                    border: const OutlineInputBorder(),
                                  ),
                                );
                              } else {
                                return TextFormField(
                                  controller: _siteNameController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                          width: 1, color: Colors.black),
                                      //<-- SEE HERE
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                          width: 1, color: Colors.black),
                                    ),
                                    floatingLabelAlignment:
                                        FloatingLabelAlignment.start,
                                    label: RichText(
                                        text: const TextSpan(children: [
                                      TextSpan(
                                        text: 'Site Name',
                                        style: TextStyle(
                                          fontFamily:
                                              'Roboto', // Specify Roboto font family
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '*',
                                        style: TextStyle(
                                          fontFamily:
                                              'Roboto', // Specify Roboto font family
                                          fontSize: 20,
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ])),
                                    labelStyle:
                                        const TextStyle(color: Colors.black),
                                    // hintText: 'Site Name',
                                    // hintStyle: const TextStyle(color: Colors.grey),
                                    border: const OutlineInputBorder(),
                                  ),
                                );
                              }
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, left: 10, right: 10),
                        child: Stack(
                          children: [
                            TextFormField(
                              onChanged: (value) {
                                _commentsController.text = value;
                              },
                              controller: _commentsController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                      width: 1, color: Colors.black),
                                  //<-- SEE HERE
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                      width: 1, color: Colors.black),
                                ),
                                floatingLabelAlignment:
                                    FloatingLabelAlignment.start,
                                label: RichText(
                                    text: const TextSpan(children: [
                                  TextSpan(
                                    text: 'Comments',
                                    style: TextStyle(
                                      fontFamily:
                                          'Roboto', // Specify Roboto font family
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '*',
                                    style: TextStyle(
                                      fontFamily:
                                          'Roboto', // Specify Roboto font family
                                      fontSize: 20,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ])),
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                                // hintText: 'Comments',
                                // hintStyle: const TextStyle(color: Colors.grey),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: ValueListenableBuilder(
                                valueListenable: _commentsController,
                                builder:
                                    (context, TextEditingValue value, child) {
                                  return value.text.isEmpty
                                      ? const SizedBox()
                                      : GestureDetector(
                                          onTap: () =>
                                              FocusScope.of(context).unfocus(),
                                          child: const Icon(Icons.arrow_forward,
                                              color: Colors.black, size: 25),
                                        );
                                },
                              ),
                            ),
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Center(
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 1.0, right: 30, bottom: 20),
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
                          "Preview",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    onTap: () {
                      if (_incinerationController.text == "") {
                        showDialog(
                            useRootNavigator: false,
                            barrierDismissible: false,
                            context: context,
                            builder: (_) => const ShowDialogBox(
                                  title: 'Please enter Incineration Value',
                                ));
                        return;
                      }
                      if (_autoClaveController.text == "") {
                        showDialog(
                            useRootNavigator: false,
                            barrierDismissible: false,
                            context: context,
                            builder: (_) => const ShowDialogBox(
                                  title: 'Please enter Auto Clave Value',
                                ));
                        return;
                      }
                      if (dateInputController.text == "") {
                        showDialog(
                            useRootNavigator: false,
                            barrierDismissible: false,
                            context: context,
                            builder: (_) => const ShowDialogBox(
                                  title: 'Please select Date',
                                ));
                        return;
                      }
                      if (_totalWasteController.text == "") {
                        showDialog(
                            useRootNavigator: false,
                            barrierDismissible: false,
                            context: context,
                            builder: (_) => const ShowDialogBox(
                                  title: 'Please enter Total waste Value',
                                ));
                        return;
                      }
                      if (_commentsController.text == "") {
                        showDialog(
                            useRootNavigator: false,
                            barrierDismissible: false,
                            context: context,
                            builder: (_) => const ShowDialogBox(
                                  title: 'Please enter the comments',
                                ));
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ProcessingPreviewScreen(
                                processPreviewModel: ProcessPreviewModel(
                                    wasteType: widget.wasteType,
                                    incinerationQty:
                                        _incinerationController.text,
                                    autoClaveQty: _autoClaveController.text,
                                    totalWasteQty: _totalWasteController.text,
                                    dateForUI: dateInputController.text,
                                    dateForAPI: selectedDate,
                                    comments: _commentsController.text));
                          },
                        ),
                      );
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
            content: const Text('Do you want to go back to Home?'),
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

  getInit() {
    getSiteName();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _siteNameController.text = await getSiteName();
    });
    _processingDataListRequestModel = ProcessingDataListRequestModel();
    GetProcessingDateCheckingListAPIService getProcessingDataListAPIService =
        GetProcessingDateCheckingListAPIService();
    getProcessingDataListAPIService.getProcessingDateCheckingListApiCall(
        _processingDataListRequestModel,
        DateFormat('yyyy-MM-dd').format(dateRange.start),
        DateFormat('yyyy-MM-dd').format(dateRange.end),
        widget.wasteType,
        widget.siteID);
  }

  Future<String> getSiteName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("SITE_NAME").toString();
  }
}
