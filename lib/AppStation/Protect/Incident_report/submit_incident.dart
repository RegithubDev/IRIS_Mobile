import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:custom_searchable_dropdown/custom_searchable_dropdown.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:recase/recase.dart';
import 'package:resus_test/AppStation/Protect/api_call/roleMappingtApiCall.dart';
import 'package:resus_test/Utility/internetCheck.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../../../Utility/MySharedPreferences.dart';
import '../../../Utility/confirmationDialogBox.dart';
import '../../../Utility/gps_dialogbox.dart';
import '../../../Utility/network_error_dialogbox.dart';
import '../../../Utility/photo_preview_popup.dart';
import '../../../Utility/showDialogBox.dart';
import '../../../Utility/submit_loader.dart';
import '../../../Utility/utils/constants.dart';
import '../../../database/database.dart';
import '../../../database/department/model_department.dart';
import '../../../database/project/model_project.dart';
import '../api_call/submitIncidentApiCall.dart';
import 'DataModel/IncidentRequest.dart';
import 'DataModel/IncidentTypeModel.dart';
import 'incident_tabview_screen.dart';

class SubmitIncident extends StatefulWidget {
  const SubmitIncident({Key? key}) : super(key: key);

  @override
  State<SubmitIncident> createState() => _SubmitIncidentState();
}

class _SubmitIncidentState extends State<SubmitIncident> {
  TextEditingController descriptionController = TextEditingController();
  final TextEditingController _incidentTypeController = TextEditingController();
  final TextEditingController _incidentCategoryController =
      TextEditingController();
  final TextEditingController _photoController = TextEditingController();

  final FocusNode _focusNode = FocusNode();

  var photoCount = "0";
  late final String imagePath;

  late BuildContext dialogContext; // global declaration
  bool isFile = false;
  bool visible = false;
  late String base64File = "";

  bool buttonClick = false;

  late ScaffoldMessengerState scaffoldMessenger;
  List<String> imageList = <String>[];
  List<String> fileNameList = <String>[];
  //List<String> pdfList = <String>[];
  List<FileDetails> fileList = <FileDetails>[];
  final ImagePicker _picker = ImagePicker();
  File? imageFile;

  final itemsIncidentCategory = [
    'Injury',
    'Fire Or Explosion',
    'Animal Attack',
    'Falling Object',
    'Human Attack'
  ];

  String? _selectedIncidentType;
  String? _selectedIncidentName;

  late List<IncidentTypeModel> itemIncidentTypes = [];

  final TextEditingController _departmentController = TextEditingController();
  String selectedDepartmentCode = "";

  late List projectList;
  List projectListToSearch = [];
  final TextEditingController _projectController = TextEditingController();
  String selectedProjectCode = "";
  String selectedProjectName = "";
  late List departmentList;

  bool isDeviceConnected = false;
  bool isAlertSet = false;

  bool isVisible = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    getConnectivity();
    _gpsService();
    super.initState();
  }

  getInit() async {
    Geolocator.requestPermission();
    departmentList = [];
    _getDepartmentList();

    itemIncidentTypes.add(IncidentTypeModel("Accident", "AC"));
    itemIncidentTypes.add(IncidentTypeModel("Near Miss", "NM"));
    itemIncidentTypes.add(IncidentTypeModel("Unsafe Act", "UA"));
    itemIncidentTypes.add(IncidentTypeModel("Unsafe Condition", "UC"));

    MySharedPreferences.instance
        .getCityStringValue('base_role')
        .then((baseRole) async {
      if (baseRole == "Management") {
        projectList = [];
        _getProjectList();
        if (mounted == true) {
          setState(() {
            isVisible = true;
          });
        }
      } else {
        if (mounted == true) {
          setState(() {
            isVisible = false;
          });
        }
      }
    });
    if (buttonClick == true) {
      showDialog(
          useRootNavigator: false,
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return SubmitLoader();
          });
      if (isVisible == true && selectedProjectCode == "") {
        // ignore: use_build_context_synchronously
        // Navigator.pop(dialogContext);
        Navigator.pop(context);

        showDialog(
            useRootNavigator: false,
            barrierDismissible: false,
            context: context,
            builder: (_) => const ShowDialogBox(
                  title: 'Please Select Project',
                ));
        return;
      }

      if (selectedDepartmentCode == "") {
        // ignore: use_build_context_synchronously
        // Navigator.pop(dialogContext);
        Navigator.pop(context);

        showDialog(
            useRootNavigator: false,
            barrierDismissible: false,
            context: context,
            builder: (_) => const ShowDialogBox(
                  title: 'Please Select Department',
                ));
        return;
      }
      if (_selectedIncidentType == null) {
        // ignore: use_build_context_synchronously
        // Navigator.pop(dialogContext);
        Navigator.pop(context);

        showDialog(
            useRootNavigator: false,
            barrierDismissible: false,
            context: context,
            builder: (_) => const ShowDialogBox(
                  title: 'Please Select Incident Type',
                ));
        return;
      }
      if (_incidentCategoryController.text == "") {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        showDialog(
            useRootNavigator: false,
            barrierDismissible: false,
            context: context,
            builder: (_) => const ShowDialogBox(
                  title: 'Please Select Incident Category',
                ));
        return;
      }
      if (descriptionController.text == "") {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        showDialog(
            useRootNavigator: false,
            barrierDismissible: false,
            context: context,
            builder: (_) => const ShowDialogBox(
                  title: 'Please Enter Incident Description',
                ));
        return;
      }

      var isConnected = await Future.value(checkInternetConnection())
          .timeout(const Duration(seconds: 2));
      if (!isConnected) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        // ignore: use_build_context_synchronously
        showDialog(
            useRootNavigator: false,
            barrierDismissible: false,
            context: context,
            builder: (_) => const NetworkErrorDialog());
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Navigator.of(context).pop();
        _showDialogForLocationPermission(
            context, "Please Enable Location Permission");
        return;
      }

      if (!(await Geolocator.isLocationServiceEnabled())) {
        Navigator.pop(context);
        showDialog(
            useRootNavigator: false,
            barrierDismissible: false,
            context: context,
            builder: (_) => const GPSDialog());
        return;
      } else {
        Position? position;
        try {
          position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.best,
              timeLimit: const Duration(milliseconds: 20));
        } catch (e) {
          position = await Geolocator.getLastKnownPosition();
        }

        MySharedPreferences.instance
            .getCityStringValue('email')
            .then((emilId) async {
          MySharedPreferences.instance
              .getCityStringValue('PROJECT_CODE')
              .then((projectCode) async {
            MySharedPreferences.instance
                .getCityStringValue('employee_code')
                .then((approverCode) async {
              MySharedPreferences.instance
                  .getCityStringValue('JSESSIONID')
                  .then((session) async {
                MySharedPreferences.instance
                    .getCityStringValue('role_code')
                    .then((approverType) async {
                  MySharedPreferences.instance
                      .getCityStringValue('Project')
                      .then((projectName) async {
                    MySharedPreferences.instance
                        .getCityStringValue('base_role')
                        .then((baseRole) async {
                      MySharedPreferences.instance
                          .getCityStringValue('user_id')
                          .then((userId) async {
                        if (baseRole == "Management") {
                          projectCode = selectedProjectCode;
                          projectName = selectedProjectName;
                        }

                        final IncidentRequest mIncidentRequest =
                            IncidentRequest(
                                projectCode,
                                selectedDepartmentCode,
                                _selectedIncidentType!,
                                _incidentCategoryController.text,
                                descriptionController.text,
                                approverCode,
                                emilId,
                                emilId,
                                approverType,
                                imageList,
                                fileNameList,
                                "${position!.latitude},${position.longitude}",
                                projectName,
                                _selectedIncidentName!,
                                userId);
                        final String requestBody =
                            json.encoder.convert(mIncidentRequest);
                        debugPrint(userId);
                        SubmitIncidentApi sng =
                            SubmitIncidentApi(session, requestBody);
                        var res = await sng.callSubmitIncidentAPi();
                        if (res!.data == "Incident Submitted Succesfully.") {
                          // ignore: use_build_context_synchronously
                          Navigator.pop(
                              context); // ignore: use_build_context_synchronously
                          showDialog(
                              useRootNavigator: false,
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                return PopScope(
                                  canPop: false,
                                  child: ConfirmationDialogBox(
                                    title: 'Incident Submitted Successfully.',
                                    press: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                IncidentTabviewScreen(0)),
                                      );
                                    },
                                    color: Colors.white,
                                    text: 'Done',
                                  ),
                                );
                              });

                          // showNotification();
                          // final service = FlutterBackgroundService();
                          // var isRunning = await service
                          //     .isRunning();
                          // if (!isRunning) {
                          //   service.startService();
                          // }
                        } else {
                          // ignore: use_build_context_synchronously
                          Navigator.pop(
                              context); // ignore: use_build_context_synchronously
                          showDialog(
                              useRootNavigator: false,
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => const ShowDialogBox(
                                    title: 'Incident Submission Failed',
                                  ));
                        }
                      });
                    });
                  });
                });
              });
            });
          });
        });
      }
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

  Future _gpsService() async {
    if (!(await Geolocator.isLocationServiceEnabled())) {
      // ignore: use_build_context_synchronously
      showDialog(
          useRootNavigator: false,
          barrierDismissible: false,
          context: context,
          builder: (_) => const GPSDialog());
      return;
    }
  }

  @override
  dispose() {
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    scaffoldMessenger = ScaffoldMessenger.of(context);
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
      child: Material(
        child: Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: kReSustainabilityRed,
            title: const Text(
              'Submit Incident',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'ARIAL',
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            reverse: true,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20.0, left: 20, right: 20, bottom: 20),
                  child: body(),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            color: Colors.transparent,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 20),
              child: ElevatedButton(
                // key: const Key("otp_login_btn"),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    backgroundColor: kReSustainabilityRed,
                    minimumSize: const Size(0, 45)),
                onPressed: () async {
                  // showLoaderDialog(context);
                  setState(() {
                    buttonClick = true;
                  });
                  getConnectivity();
                },
                child: const Text(
                  "Submit Incident",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: "ARIAL"),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  showLoaderDialog(BuildContext context) {
    showDialog(
      useRootNavigator: false,
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        // dialogContext = context;
        return PopScope(
          canPop: false,
          child: AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(
                  color: Colors.grey,
                ),
                Container(
                    margin: const EdgeInsets.only(left: 7),
                    child: const Text("Loading...",
                        style: TextStyle(
                            fontFamily: 'PTSans-Bold',
                            fontWeight: FontWeight.bold,
                            color: Colors.grey))),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 30,
                backgroundColor: kReSustainabilityRed,
                child: FutureBuilder(
                    future: getStringValue('user_name'),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          snapshot.data.toString()[0].titleCase,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontFamily: 'ARIAL',
                            fontWeight: FontWeight.bold, // italic
                          ),
                        );
                        // your widget
                      } else {
                        return const CircularProgressIndicator();
                      }
                    }),
              ),
              const SizedBox(
                width: 20,
              ),
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
                                      fontWeight: FontWeight.bold, // italic
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
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
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
            ],
          ),
        ),
        SizedBox(height: 3.h),
        Visibility(
          visible: isVisible,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                            fontFamily: 'ARIAL',
                            fontWeight: FontWeight.w400,
                          ), //apply style to all
                          children: const [
                        TextSpan(
                          text: 'Project ',
                        ),
                        TextSpan(
                            text: '*',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kReSustainabilityRed)),
                      ]))),
              SizedBox(height: 2.h),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: projectDropDown(),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: RichText(
                text: TextSpan(
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontFamily: 'ARIAL',
                      fontWeight: FontWeight.w400,
                    ), //apply style to all
                    children: const [
                  TextSpan(
                    text: 'Department ',
                  ),
                  TextSpan(
                      text: '*',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kReSustainabilityRed)),
                ]))),
        SizedBox(height: 2.h),
        Padding(
          padding: const EdgeInsets.only(right: 10.0, left: 10.0),
          child: Center(child: departmentDropDown()),
        ),
        SizedBox(
          height: 2.h,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: RichText(
              text: TextSpan(
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                    fontFamily: 'ARIAL',
                    fontWeight: FontWeight.w400,
                  ), //apply style to all
                  children: const [
                TextSpan(
                  text: 'Incident Type ',
                ),
                TextSpan(
                    text: '*',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kReSustainabilityRed)),
              ])),
        ),
        SizedBox(
          height: 2.h,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10.0, left: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: _selectIncidentType(_incidentTypeController,
                "Select Incident *", TextInputType.text),
          ),
        ),
        SizedBox(
          height: 2.h,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: RichText(
              text: TextSpan(
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                    fontFamily: 'ARIAL',
                    fontWeight: FontWeight.w400,
                  ), //apply style to all
                  children: const [
                TextSpan(
                  text: 'Incident Category ',
                ),
                TextSpan(
                    text: '*',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kReSustainabilityRed)),
              ])),
        ),
        SizedBox(
          height: 2.h,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10.0, left: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: _selectIncidentCategory(_incidentCategoryController,
                "Select Incident Category *", TextInputType.text),
          ),
        ),
        SizedBox(
          height: 2.h,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: RichText(
              text: TextSpan(
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                    fontFamily: 'ARIAL',
                    fontWeight: FontWeight.w400,
                  ), //apply style to all
                  children: const [
                TextSpan(
                  text: 'Enter Incident Description',
                ),
                TextSpan(
                    text: '*',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kReSustainabilityRed)),
              ])),
        ),
        const SizedBox(
          height: 5,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              TextFormField(
                focusNode: _focusNode,
                onChanged: (value) {
                    descriptionController.text = value;
                },
                inputFormatters: [
                  NoLeadingSpaceFormatter(),
                ],
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w500, fontSize: 15),
                controller: descriptionController,
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                cursorColor: kReSustainabilityRed,
                decoration: const InputDecoration(
                    hintText: "",
                    hintStyle: TextStyle(fontFamily: "ARIAL"),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.grey))),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child:ValueListenableBuilder(
                  valueListenable: descriptionController,
                  builder: (context, TextEditingValue value, child) {
                    return value.text.isEmpty
                        ? const SizedBox()
                        : GestureDetector(
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: const Icon(Icons.arrow_forward, color: Colors.black, size: 25),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 1.h,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5.0, top: 5.0, right: 10.0),
          child: _attachPhoto(_photoController),
        ),
        Padding(
            // this is new
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom)),
      ],
    );
  }

  Future<bool> checkInternetConnection() async {
    bool isConnected = true;
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isConnected = true;
      }
    } on SocketException catch (_) {
      isConnected = false;
    }
    return isConnected;
  }

  Future<String> getStringValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.getString(key) ?? "";
  }

  Widget _selectIncidentType(controller, title, TextInputType textInputType) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      width: 100.w,
      child: Row(
        children: <Widget>[
          Flexible(
            child: Container(
              height: 40,
              padding: const EdgeInsets.only(
                right: 10,
              ),
              child: TextFormField(
                key: const ValueKey('dropdownIncidentCategory'),
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 15),
                showCursor: false,
                autofocus: false,
                readOnly: true,
                controller: controller,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 10.0),
                  hintText: 'Choose',
                  hintStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                  suffixIcon: PopupMenuButton<IncidentTypeModel>(
                    offset: const Offset(0, 40),
                    padding: const EdgeInsets.only(bottom: 5, left: 70),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      size: 25,
                    ),
                    onSelected: (IncidentTypeModel value) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      controller.text = value.incident_type_name;
                      _selectedIncidentType = value.incident_type_code;
                      _selectedIncidentName = value.incident_type_name;
                    },
                    itemBuilder: (BuildContext context) {
                      return itemIncidentTypes
                          .map<PopupMenuItem<IncidentTypeModel>>(
                              (IncidentTypeModel value) {
                        return PopupMenuItem(
                            value: value,
                            child: Text(
                              value.incident_type_name,
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ));
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _selectIncidentCategory(
      controller, title, TextInputType textInputType) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      width: 100.w,
      child: Row(
        children: <Widget>[
          Flexible(
            child: Container(
              height: 40,
              padding: const EdgeInsets.only(
                right: 10,
              ),
              child: TextFormField(
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 15),
                showCursor: false,
                autofocus: false,
                readOnly: true,
                controller: controller,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: 'Choose',
                  hintStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                  suffixIcon: PopupMenuButton<String>(
                    offset: const Offset(0, 40),
                    padding: const EdgeInsets.only(bottom: 5, left: 70),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      size: 25,
                    ),
                    onSelected: (String value) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      controller.text = value;
                    },
                    itemBuilder: (BuildContext context) {
                      return itemsIncidentCategory
                          .map<PopupMenuItem<String>>((String value) {
                        return PopupMenuItem(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
                            ));
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<List> _getDepartmentList() async {
    List departmentListToSearch = [];

    final database = await $FloorFlutterDatabase
        .databaseBuilder('flutter_database.db')
        .build();
    final dao = database.modelDepartment;
    departmentList = await dao.findAllDepartments();
    if (departmentList.isNotEmpty) {
      for (model_department dept in await dao.findAllDepartments()) {
        if (mounted == true) {
          setState(() {
            departmentListToSearch.add({
              'department_name': dept.department_name,
              'department_code': dept.department_code
            });
          });
        }
      }
      return departmentListToSearch;
    } else {
      return departmentListToSearch;
    }
  }

  Widget _selectDepartmentSpinner(controller, TextInputType textInputType) {
    return Container(
        key: const ValueKey('c3'),
        child: FutureBuilder<List<dynamic>?>(
            future: _getDepartmentList(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return CustomSearchableDropDown(
                  menuPadding: const EdgeInsets.fromLTRB(20, 50, 20, 50),
                  dropdownHintText: 'Search For department Here... ',
                  showLabelInMenu: false,
                  dropdownItemStyle:
                      const TextStyle(color: Colors.black, fontSize: 14),
                  primaryColor: Colors.black,
                  menuMode: false,
                  labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                  items: snapshot.data!,
                  label: 'Choose',
                  dropDownMenuItems: snapshot.data!.map((item) {
                    return item['department_name'];
                  }).toList(),
                  onChanged: (value) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    if (value != null) {
                      selectedDepartmentCode = value['department_code'];

                      MySharedPreferences.instance
                          .getCityStringValue('PROJECT_CODE')
                          .then((projectCode) async {
                        MySharedPreferences.instance
                            .getCityStringValue('JSESSIONID')
                            .then((session) async {
                          RoleMappingApi sng = RoleMappingApi(
                              session, projectCode, selectedDepartmentCode);
                          http.Response res = await sng.callRoleMappingAPi();
                          if (res.body == "[]" || res.body == "") {
                            return;
                          }
                          MySharedPreferences.instance.setStringValue(
                              "employee_code",
                              jsonDecode(res.body)[0]["employee_code"]);
                          debugPrint(jsonDecode(res.body)[0]["email_id"]);
                          MySharedPreferences.instance.setStringValue(
                              "email", jsonDecode(res.body)[0]["email_id"]);
                          MySharedPreferences.instance.setStringValue(
                              "role_code",
                              jsonDecode(res.body)[0]["role_code"]);
                        });
                      });
                    }
                  },
                );
              } else {
                return const SizedBox(
                  height: 20.0,
                  width: 20.0,
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }

  Widget departmentDropDown() {
    return Container(
      key: const ValueKey('dropdownDepartment'),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: _selectDepartmentSpinner(
          _departmentController, TextInputType.emailAddress),
    );
  }

  _getProjectList() async {
    final database = await $FloorFlutterDatabase
        .databaseBuilder('flutter_database.db')
        .build();
    final dao = database.modelProject;
    projectList = await dao.findAllProjects();

    if (projectList.isNotEmpty) {
      for (model_project project in projectList) {
        if (mounted == true) {
          setState(() {
            projectListToSearch.add({
              'project_name': project.project_name,
              'project_code': project.project_code
            });
          });
        }
      }
      return projectListToSearch;
    } else {
      return projectListToSearch;
    }
  }

  Widget _selectProjectSpinner(controller, TextInputType textInputType) {
    return CustomSearchableDropDown(
      menuPadding: const EdgeInsets.fromLTRB(20, 50, 20, 50),
      dropdownHintText: 'Search For project Here... ',
      showLabelInMenu: false,
      dropdownItemStyle: const TextStyle(color: Colors.black, fontSize: 14),
      primaryColor: Colors.black,
      menuMode: false,
      labelStyle: const TextStyle(
          color: Colors.black, fontSize: 14, fontWeight: FontWeight.w400),
      items: projectListToSearch,
      label: 'Choose',
      // prefixIcon: const Icon(Icons.search),
      dropDownMenuItems: projectListToSearch.map((item) {
        return item['project_name'];
      }).toList(),
      onChanged: (value) {
        FocusManager.instance.primaryFocus?.unfocus();
        if (value != null) {
          // selectedProjectCode = value['project_code'];
          if (mounted == true) {
            setState(() {
              selectedProjectCode = value['project_code'];
              selectedProjectName = value['project_name'];
            });
          }
        }
      },
    );
  }

  Widget projectDropDown() {
    return Container(
      key: const ValueKey('dropdownProject'),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child:
          _selectProjectSpinner(_projectController, TextInputType.emailAddress),
    );
  }

  _attachPhoto(controller) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          Container(
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                color: Colors.white,
              ),
              height: 50,
              child: TextField(
                controller: _photoController,
                showCursor: false,
                autofocus: false,
                readOnly: true,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(top: 15, left: 10),
                  hintText: "$photoCount Attachments Added",
                  hintStyle: const TextStyle(color: Colors.black),
                  prefixIcon: InkWell(
                      child: const Icon(Icons.remove_red_eye_outlined,
                          color: kReSustainabilityRed),
                      onTap: () {
                        if (fileList.isEmpty) {
                          return;
                        }
                        showDialog(
                                useRootNavigator: false,
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) =>
                                    PhotoPreviewDialogPopUp(fileList: fileList))
                            .then((valueFromDialog) {
                          if (mounted == true) {
                            setState(() {
                              if (valueFromDialog.length == 0) {
                                fileList.clear();
                                photoCount = fileList.length.toString();
                              } else if (valueFromDialog.length != null) {
                                fileList = valueFromDialog;
                                photoCount = fileList.length.toString();
                              }
                            });
                          }
                        });
                      }),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: SizedBox(
                      height: 40,
                      width: 70,
                      child: Row(
                        children: [
                          InkWell(
                            child: const Icon(Icons.attach_file,
                                color: kReSustainabilityRed),
                            onTap: () async {
                              final result =
                                  await FilePicker.platform.pickFiles(
                                allowMultiple: true,
                              );
                              result?.files.forEach((fetchedFile) async {
                                convertToBase64(fetchedFile);
                              });
                            },
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          InkWell(
                            child: const Icon(Icons.camera_alt_outlined,
                                color: kReSustainabilityRed),
                            onTap: () async {
                              // CapturedImageDetails photoCaptured =
                              //     await Navigator.push(
                              //         context,
                              //         MaterialPageRoute(
                              //           builder: (context) =>
                              //               CameraPreviewScreen(),
                              //         ));
                              //
                              // setState(() {
                              //   FocusManager.instance.primaryFocus?.unfocus();
                              //   fileList.add(FileDetails(fileName:photoCaptured.imageName, filePath: "", base64: photoCaptured.image));
                              //   photoCount = fileList.length.toString();
                              // });

                              picImage(ImageSource.camera);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ))
        ]);
  }

  convertToBase64(file) async {
    if (file == null) return "";
    if (lookupMimeType(file.name.toString()) == "image/jpeg" ||
        lookupMimeType(file.name.toString()) == "application/pdf" ||
        lookupMimeType(file.name.toString()) == "image/png") {
      File imgFile = File(file.path);

      List<int> fileInByte = imgFile.readAsBytesSync();
      String fileInBase64 = base64Encode(fileInByte);
      imageList.add(fileInBase64);
      fileNameList.add(file.name);
      fileList.add(FileDetails(
          fileName: file.name, filePath: file.path, base64: fileInBase64));
      photoCount = fileList.length.toString();
    } else {
      showDialog(
          useRootNavigator: false,
          barrierDismissible: false,
          context: context,
          builder: (_) => const ShowDialogBox(
                title:
                    'Invalid file format!\nOnly Images and Documents Allowed.',
              ));
    }
  }

  Future picImage(ImageSource source) async {
    final file = await _picker.pickImage(source: source);
    if (file?.path != null) {
      imageFile = File(file!.path);
      final result = await FlutterImageCompress.compressWithFile(
        file.path,
        quality: 90,
        minWidth: 1024,
        minHeight: 1024,
        rotate: 360,
      );
      String fileInBase64 = base64Encode(result!);
      imageList.add(fileInBase64);
      fileNameList.add(file.name);
      fileList.add(FileDetails(
          fileName: file.name, filePath: file.path, base64: fileInBase64));
      photoCount = fileList.length.toString();
    }
  }

  Future<bool> _onWillPop(BuildContext context) async {
    bool? exitResult = await showDialog(
      useRootNavigator: false,
      barrierDismissible: false,
      context: context,
      builder: (context) => _buildExitDialog(context),
    );
    return exitResult ?? false;
  }

  AlertDialog _buildExitDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Please confirm',
          style: TextStyle(color: Colors.black, fontFamily: "ARIAL")),
      content: const Text('Do you want go back?\nDraft will be lost !',
          style: TextStyle(color: Colors.black, fontFamily: "ARIAL")),
      actions: <Widget>[
        TextButton(
          child: const Text('No',
              style:
                  TextStyle(color: kReSustainabilityRed, fontFamily: "ARIAL")),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          onPressed: () =>
              {Navigator.of(context).pop(), Navigator.of(context).pop()},
          child: const Text(
            'Yes',
            style: TextStyle(color: kReSustainabilityRed, fontFamily: "ARIAL"),
          ),
        ),
      ],
    );
  }

  void _showDialogForLocationPermission(BuildContext context, title) {
    showDialog(
      useRootNavigator: false,
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Alert!!",
            style: TextStyle(color: kReSustainabilityRed),
          ),
          content: Text(title),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "OK",
                style: TextStyle(color: kReSustainabilityRed),
              ),
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                openAppSettings();
                Navigator.pop(context); //close Dial
              },
            ),
          ],
        );
      },
    );
  }
}

class CapturedImageDetails {
  final String imageName;
  final String image;

  CapturedImageDetails({required this.imageName, required this.image});
}

class FileDetails {
  final String fileName;
  final String filePath;
  final String base64;

  FileDetails(
      {required this.fileName, required this.filePath, required this.base64});
}

class NoLeadingSpaceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.startsWith(' ')) {
      final String trimedText = newValue.text.trimLeft();

      return TextEditingValue(
        text: trimedText,
        selection: TextSelection(
          baseOffset: trimedText.length,
          extentOffset: trimedText.length,
        ),
      );
    }

    return newValue;
  }
}
