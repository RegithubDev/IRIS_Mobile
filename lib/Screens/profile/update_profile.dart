import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:custom_searchable_dropdown/custom_searchable_dropdown.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:resus_test/Utility/internetCheck.dart';
import 'package:resus_test/database/user/model_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../Utility/MySharedPreferences.dart';
import '../../Utility/api_Url.dart';
import '../../Utility/confirmationDialogBox.dart';
import '../../Utility/gps_dialogbox.dart';
import '../../Utility/network_error_dialogbox.dart';
import '../../Utility/showDialogBox.dart';
import '../../Utility/submit_loader.dart';
import '../../Utility/utils/constants.dart';
import '../../database/database.dart';
import '../../database/department/model_department.dart';
import '../../database/project/model_project.dart';
import '../../database/sbu/model_sbu.dart';

class UpdateProfile extends StatefulWidget {
  final String sbuDefaultValue;
  final String departmentDefaultValue;
  final String projectDefaultValue;
  final String reportingToDefaultValue;

  final String sbuDefaultCode;
  final String departmentDefaultCode;
  final String projectDefaultCode;
  final String reportingToDefaultCode;

  const UpdateProfile({
    super.key,
    required this.sbuDefaultValue,
    required this.departmentDefaultValue,
    required this.projectDefaultValue,
    required this.reportingToDefaultValue,
    required this.sbuDefaultCode,
    required this.departmentDefaultCode,
    required this.projectDefaultCode,
    required this.reportingToDefaultCode,
  });

  @override
  State<UpdateProfile> createState() => _UpdateProfileState(
      sbuDefaultValue,
      departmentDefaultValue,
      projectDefaultValue,
      reportingToDefaultValue,
      sbuDefaultCode,
      departmentDefaultCode,
      projectDefaultCode,
      reportingToDefaultCode);
}

class _UpdateProfileState extends State<UpdateProfile> {
  late BuildContext dialogContext;
  late FlutterDatabase database; // global declaration

  late List sbuList;
  List sbuListToSearch = [];
  final TextEditingController _sbuController = TextEditingController();
  String selectedSbuCode = "";
  String selectedSbuName = "";

  late List departmentList;
  List DepartmentListToSearch = [];
  final TextEditingController _departmentController = TextEditingController();
  String selectedDepartmentCode = "";

  late List projectList;
  List ProjectListToSearch = [];
  final TextEditingController _projectController = TextEditingController();
  String selectedProjectCode = "";

  late List userList;
  List UserListToSearch = [];
  final TextEditingController _userController = TextEditingController();
  String selectedUserCode = "";
  String sbuDefaultValue = "Choose";

  String m_sbuDefaultValue;
  String m_departmentDefaultValue;
  String m_projectDefaultValue;
  String m_reportingToDefaultValue;

  String m_sbuDefaultCode;
  String m_departmentDefaultCode;
  String m_projectDefaultCode;
  String m_reportingToDefaultCode;

  bool isDeviceConnected = false;
  bool isAlertSet = false;
  bool buttonClick = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _UpdateProfileState(
      this.m_sbuDefaultValue,
      this.m_departmentDefaultValue,
      this.m_projectDefaultValue,
      this.m_reportingToDefaultValue,
      this.m_sbuDefaultCode,
      this.m_departmentDefaultCode,
      this.m_projectDefaultCode,
      this.m_reportingToDefaultCode);

  @override
  void initState() {
    getConnectivity();
    _gpsService();
    super.initState();
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

  getInit() async {
    Geolocator.requestPermission();
    sbuList = [];
    _getSbuList();
    departmentList = [];
    _getDepartmentList();
    projectList = [];
    _getProjectList();
    userList = [];
    _getUserList();

    if (buttonClick == true) {
      showDialog(
          useRootNavigator: false,
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return SubmitLoader();
          });
      doValidation();

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Navigator.of(context).pop();
        _showDialogForLocationPermission(
            context, "Please Enable Location Permission");
        return;
      }

      if (!(await Geolocator.isLocationServiceEnabled())) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        // ignore: use_build_context_synchronously
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
            .getCityStringValue('JSESSIONID')
            .then((session) async {
          MySharedPreferences.instance
              .getCityStringValue('contact_number')
              .then((contactNumber) async {
            final UpdateProfileRequest mProfile = UpdateProfileRequest(
                m_sbuDefaultCode,
                m_projectDefaultCode,
                m_departmentDefaultCode,
                m_reportingToDefaultCode,
                contactNumber);
            final String requestBody = json.encoder.convert(mProfile);

            calUpdateProfileAPi(session, requestBody);
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

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: kReSustainabilityRed,
          title: const Text(
            'Edit Profile',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'ARIAL',
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 20.0, left: 20, right: 20, bottom: 20),
              child: body(),
            ),
            Align(
              alignment: FractionalOffset.bottomCenter,
              child: GestureDetector(
                child: Container(
                  decoration: const BoxDecoration(
                    color: kReSustainabilityRed,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  margin: const EdgeInsets.only(
                      bottom: 20, top: 10, left: 20, right: 20),
                  height: 5.h,
                  width: 100.w,
                  child: Center(
                      child: Text(
                    "Update",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ARIAL'),
                  )),
                ),
                onTap: () async {
                  setState(() {
                    buttonClick = true;
                  });
                  getConnectivity();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  calUpdateProfileAPi(String m_sessionId, String m_requestBody) async {
    var dio = Dio();
    try {
      var response = await dio.post(UPDATE_PROFILE,
          data: m_requestBody,
          options: Options(
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json',
              'Cookie': m_sessionId
            },
          ));

      if (response.toString() == "Updating User is failed. Try again.") {
        Navigator.pop(context);
        showDialog(
            useRootNavigator: false,
            barrierDismissible: false,
            context: context,
            builder: (_) => const ShowDialogBox(
                  title: 'Updating User is failed. Try again.',
                ));
      } else {
        saveDataToSharedPreference(response);
        // ignore: use_build_context_synchronously
        showDialog(
            useRootNavigator: false,
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return PopScope(
                canPop: false,
                child: ConfirmationDialogBox(
                  title: 'Profile Updated Successfully',
                  press: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  color: Colors.white,
                  text: 'Done',
                ),
              );
            });
        final service = FlutterBackgroundService();
        var isRunning = await service.isRunning();
        if (!isRunning) {
          service.startService();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

  doValidation() async {
    var isConnected = await Future.value(checkInternetConnection())
        .timeout(const Duration(seconds: 2));
    if (!isConnected) {
      Navigator.pop(context); // ignore: use_build_context_synchronously
      showDialog(
          useRootNavigator: false,
          barrierDismissible: false,
          context: context,
          builder: (_) => const NetworkErrorDialog());
      return;
    }
    if (m_sbuDefaultCode == "" || m_sbuDefaultCode == null) {
      Navigator.pop(context); // ignore: use_build_context_synchronously
      showDialog(
          useRootNavigator: false,
          barrierDismissible: false,
          context: context,
          builder: (_) => const ShowDialogBox(
                title: 'Please Select SBU',
              ));
      return;
    }
    if (m_departmentDefaultCode == "" || m_departmentDefaultCode == null) {
      Navigator.pop(context); // ignore: use_build_context_synchronously
      showDialog(
          useRootNavigator: false,
          barrierDismissible: false,
          context: context,
          builder: (_) => const ShowDialogBox(
                title: 'Please Select Department',
              ));
      return;
    }
    if (m_projectDefaultCode == "" || m_projectDefaultCode == null) {
      Navigator.pop(context); // ignore: use_build_context_synchronously
      showDialog(
          useRootNavigator: false,
          barrierDismissible: false,
          context: context,
          builder: (_) => const ShowDialogBox(
                title: 'Please Select Project',
              ));
      return;
    }
  }

  saveDataToSharedPreference(Response? response) {
    if (response.toString() == "Updating User is failed. Try again.") {
      return;
    }
    if (response!.data["Project"] == null) {
      response.data["Project"] = '';
    }
    if (response.data["DEPARTMENT_NAME"] == null) {
      response.data["DEPARTMENT_NAME"] = '';
    }
    if (response.data["SBU_NAME"] == null) {
      response.data["SBU_NAME"] = '';
    }
    if (response.data["REPORTING_TO_NAME"] == null) {
      response.data["REPORTING_TO_NAME"] = '';
    }
    if (response.data["SBU"] == null) {
      response.data["SBU"] = '';
    }
    if (response.data["PROJECT_CODE"] == null) {
      response.data["PROJECT_CODE"] = '';
    }
    if (response.data["DEPARTMENT"] == null) {
      response.data["DEPARTMENT"] = '';
    }
    if (response.data["REPORTING_TO"] == null) {
      response.data["REPORTING_TO"] = '';
    }
    MySharedPreferences.instance
        .setStringValue("SBU_NAME", response.data["SBU_NAME"]);
    MySharedPreferences.instance
        .setStringValue("Project", response.data["Project"]);
    MySharedPreferences.instance
        .setStringValue("DEPARTMENT_NAME", response.data["DEPARTMENT_NAME"]);
    MySharedPreferences.instance.setStringValue(
        "REPORTING_TO_NAME", response.data["REPORTING_TO_NAME"]);
    MySharedPreferences.instance.setStringValue("SBU", response.data["SBU"]);
    MySharedPreferences.instance
        .setStringValue("PROJECT_CODE", response.data["PROJECT_CODE"]);
    MySharedPreferences.instance
        .setStringValue("DEPARTMENT", response.data["DEPARTMENT"]);
    MySharedPreferences.instance
        .setStringValue("REPORTING_TO", response.data["REPORTING_TO"]);
  }

  Widget body() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 25,
          ),
          const SizedBox(height: 15),
          RichText(
              text: const TextSpan(
                  style: kInputTextStyle, //apply style to all
                  children: [
                TextSpan(
                  text: 'SBU ',
                ),
                TextSpan(
                    text: '*',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kReSustainabilityRed)),
              ])),
          const SizedBox(height: 15),
          sbuDropDown(),
          const SizedBox(height: 10),
          RichText(
              text: const TextSpan(
                  style: kInputTextStyle, //apply style to all
                  children: [
                TextSpan(
                  text: 'Department ',
                ),
                TextSpan(
                    text: '*',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kReSustainabilityRed)),
              ])),
          const SizedBox(height: 15),
          departmentDropDown(),
          const SizedBox(height: 10),
          RichText(
              text: const TextSpan(
                  style: kInputTextStyle, //apply style to all
                  children: [
                TextSpan(
                  text: 'Project ',
                ),
                TextSpan(
                    text: '*',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kReSustainabilityRed)),
              ])),
          const SizedBox(height: 15),
          projectDropDown(),
          const SizedBox(height: 10),
          const Text(
            'User Reporting To',
            style: kInputTextStyle,
          ),
          const SizedBox(height: 15),
          userDropDown()
        ],
      ),
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

  _getSbuList() async {
    final database = await $FloorFlutterDatabase
        .databaseBuilder('flutter_database.db')
        .build();
    final dao = database.modelSBU;
    sbuList = await dao.findAllSBUs();

    for (model_sbu sbu in sbuList) {
      setState(() {
        sbuListToSearch
            .add({'sbu_name': sbu.sbu_name, 'sbu_code': sbu.sbu_code});
      });
    }
  }

  Widget _selectSbuSpinner(controller, TextInputType textInputType) {
    return CustomSearchableDropDown(
      menuPadding: const EdgeInsets.fromLTRB(20, 50, 20, 50),
      dropdownHintText: 'Search For Sbu Here... ',
      showLabelInMenu: false,
      dropdownItemStyle: const TextStyle(color: Colors.black, fontSize: 14),
      primaryColor: Colors.black,
      menuMode: false,
      labelStyle: const TextStyle(
          color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
      items: sbuListToSearch,
      label: m_sbuDefaultValue,
      // prefixIcon: const Icon(Icons.search),
      dropDownMenuItems: sbuListToSearch.map((item) {
        return item['sbu_name'];
      }).toList(),
      onChanged: (value) {
        FocusManager.instance.primaryFocus?.unfocus();
        if (value != null) {
          setState(() {
            m_sbuDefaultCode = value['sbu_code'];
          });
        }
      },
    );
  }

  Widget sbuDropDown() {
    return Container(
        key: const ValueKey('dropdownSbu'),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: _selectSbuSpinner(_sbuController, TextInputType.emailAddress));
  }

  Future<List> _getDepartmentList() async {
    List DepartmentListToSearch = [];

    final database = await $FloorFlutterDatabase
        .databaseBuilder('flutter_database.db')
        .build();
    final dao = database.modelDepartment;
    departmentList = await dao.findAllDepartments();
    for (model_department dept in await dao.findAllDepartments()) {
      setState(() {
        DepartmentListToSearch.add({
          'department_name': dept.department_name,
          'department_code': dept.department_code
        });
      });
    }
    return DepartmentListToSearch;
  }

  Widget _selectDepartmentSpinner(controller, TextInputType textInputType) {
    return FutureBuilder<List<dynamic>?>(
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
                  fontWeight: FontWeight.bold),
              items: snapshot.data!,
              label: m_departmentDefaultValue,
              dropDownMenuItems: snapshot.data!.map((item) {
                return item['department_name'];
              }).toList(),
              onChanged: (value) {
                FocusManager.instance.primaryFocus?.unfocus();
                if (value != null) {
                  // selectedDepartmentCode = value['department_code'];
                  setState(() {
                    m_departmentDefaultCode = value['department_code'];
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
        });
  }

  Widget departmentDropDown() {
    return Container(
      key: const ValueKey('dropdowndept'),
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

    for (model_project project in projectList) {
      setState(() {
        ProjectListToSearch.add({
          'project_name': project.project_name,
          'project_code': project.project_code
        });
      });
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
          color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
      items: ProjectListToSearch,
      label: m_projectDefaultValue,
      // prefixIcon: const Icon(Icons.search),
      dropDownMenuItems: ProjectListToSearch.map((item) {
        return item['project_name'];
      }).toList(),
      onChanged: (value) {
        FocusManager.instance.primaryFocus?.unfocus();
        if (value != null) {
          // selectedProjectCode = value['project_code'];
          setState(() {
            m_projectDefaultCode = value['project_code'];
          });
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

  _getUserList() async {
    final database = await $FloorFlutterDatabase
        .databaseBuilder('flutter_database.db')
        .build();
    final dao = database.modelUser;
    userList = await dao.findAllUsers();

    for (model_user user in userList) {
      setState(() {
        UserListToSearch.add(
            {'user_name': user.user_name, 'user_id': user.user_id});
      });
    }
  }

  Widget _selectUserSpinner(controller, TextInputType textInputType) {
    return CustomSearchableDropDown(
      menuPadding: const EdgeInsets.fromLTRB(20, 50, 20, 50),
      dropdownHintText: 'Search For User Here... ',
      showLabelInMenu: false,
      dropdownItemStyle: const TextStyle(color: Colors.black, fontSize: 14),
      primaryColor: Colors.black,
      menuMode: false,
      labelStyle: const TextStyle(
          color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
      items: UserListToSearch,
      label: m_reportingToDefaultValue,
      dropDownMenuItems: UserListToSearch.map((item) {
        return item['user_name'];
      }).toList(),
      onChanged: (value) {
        FocusManager.instance.primaryFocus?.unfocus();
        if (value != null) {
          setState(() {
            m_reportingToDefaultCode = value['user_id'];
          });
        }
      },
    );
  }

  Widget userDropDown() {
    return Container(
        key: const ValueKey('dropdownUser'),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: _selectUserSpinner(_userController, TextInputType.emailAddress));
  }

  Future<String> getStringValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.getString(key) ?? "";
  }

  void _showDialogForLocationPermission(BuildContext context, title) {
    showDialog(
      useRootNavigator: false,
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
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
          ),
        );
      },
    );
  }
}

Future<String> getDepartmentListAPICall(http.Client http) async {
  Uri dashboardAPIURL = Uri.parse(GET_DEPARTMENT_LIST);
  final response = await http.get(
    dashboardAPIURL,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
    },
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body)["id"];
  } else {
    return 'Failed to fetch Department list response';
  }
}

Future<String> getSbuListAPICall(http.Client http) async {
  Uri dashboardAPIURL = Uri.parse(GET_SBU_LIST);
  final response = await http.get(
    dashboardAPIURL,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
    },
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body)["id"];
  } else {
    return 'Failed to fetch SBU list response';
  }
}

Future<String> getProjectListAPICall(http.Client http) async {
  Uri dashboardAPIURL = Uri.parse(GET_PROJECTS_LIST);
  final response = await http.get(
    dashboardAPIURL,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
    },
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body)["id"];
  } else {
    return 'Failed to fetch Project list response';
  }
}

Future<String> getUserListAPICall(http.Client http) async {
  Uri dashboardAPIURL = Uri.parse(GET_USER_LIST);
  final response = await http.get(
    dashboardAPIURL,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
    },
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body)["user_id"];
  } else {
    return 'Failed to fetch User list response';
  }
}

class UpdateProfileRequest {
  String base_sbu;
  String base_project;
  String base_department;
  String reporting_to;
  String contact_no;

  UpdateProfileRequest(this.base_sbu, this.base_project, this.base_department,
      this.reporting_to, this.contact_no);

  Map<String, dynamic> toJson() => <String, dynamic>{
        "base_sbu": base_sbu,
        "base_project": base_project,
        "base_department": base_department,
        "reporting_to": reporting_to,
        "contact_number": contact_no
      };
}