import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:custom_searchable_dropdown/custom_searchable_dropdown.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:recase/recase.dart';
import 'package:resus_test/Utility/internetCheck.dart';
import 'package:resus_test/database/themes/model_themes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../../../Utility/MySharedPreferences.dart';
import '../../../Utility/confirmationDialogBox.dart';
import '../../../Utility/gps_dialogbox.dart';
import '../../../Utility/network_error_dialogbox.dart';
import '../../../Utility/showDialogBox.dart';
import '../../../Utility/submit_loader.dart';
import '../../../Utility/utils/constants.dart';
import '../../../database/database.dart';
import '../../Utility/submit_idea_photo_preview_popup.dart';
import 'API Call/roleMappingBrainBoxApi.dart';
import 'API Call/submitIdeaApiCall.dart';
import 'Models/IdeaRequest.dart';
import 'ideas_tabview_screen.dart';

class SubmitIdea extends StatefulWidget {
  const SubmitIdea({Key? key}) : super(key: key);

  @override
  State<SubmitIdea> createState() => _SubmitIdeaState();
}

class _SubmitIdeaState extends State<SubmitIdea> {
  TextEditingController ideaInShortController = TextEditingController();
  TextEditingController ideaInDetailController = TextEditingController();
  final TextEditingController _photoController = TextEditingController();
  String deviceName = '';
  String deviceVersion = '';
  String identifier = '';

  bool buttonClick = false;

  var photoCount = "0";
  late final String imagePath;

  late BuildContext dialogContext; // global declaration
  bool isFile = false;
  bool visible = false;
  late String base64File = "";

  late ScaffoldMessengerState scaffoldMessenger;
  List<String> imageList = <String>[];
  List<String> fileNameList = <String>[];
  List<FileDetails> fileListidea = <FileDetails>[];
  final ImagePicker _picker = ImagePicker();
  File? imageFile;
  bool isAnonymous = false;

  void onToggle(bool value) {
    if (mounted == true) {
      setState(() {
        isAnonymous = value;
      });
    }
    if (kDebugMode) {
      print(isAnonymous);
    }
  }

  final TextEditingController _themeController = TextEditingController();
  String selectedThemesCode = "";
  late List themesList;

  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  bool isVisible = false;
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final FocusNode _focusNode = FocusNode();

  bool isSwitched = true;

  @override
  void initState() {
    getConnectivity();
    _gpsService();
    super.initState();
  }

  getInit() async {
    Geolocator.requestPermission();
    themesList = [];
    _getThemesList();
    _deviceDetails();
    if (buttonClick == true) {
      showDialog(
          barrierDismissible: false,
          context: context,
          useRootNavigator: false,
          builder: (BuildContext context) {
            return SubmitLoader();
          });

      var isConnected = await Future.value(checkInternetConnection())
          .timeout(const Duration(seconds: 2));
      if (!isConnected) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        // ignore: use_build_context_synchronously
        showDialog(
            barrierDismissible: false,
            context: context,
            useRootNavigator: false,
            builder: (_) => const NetworkErrorDialog());
        return;
      }

      if (ideaInShortController.text == "") {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        showDialog(
            barrierDismissible: false,
            context: context,
            useRootNavigator: false,
            builder: (_) => const ShowDialogBox(
                  title: 'Please Enter Idea in Short',
                ));
        return;
      }

      if (selectedThemesCode == "") {
        // ignore: use_build_context_synchronously
        // Navigator.pop(dialogContext);
        Navigator.pop(context);

        showDialog(
            barrierDismissible: false,
            context: context,
            useRootNavigator: false,
            builder: (_) => const ShowDialogBox(
                  title: 'Please Select Theme',
                ));
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
            barrierDismissible: false,
            context: context,
            useRootNavigator: false,
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
            .then((email) async {
          MySharedPreferences.instance
              .getCityStringValue('email_id')
              .then((emailID) async {
            MySharedPreferences.instance
                .getCityStringValue('SBU')
                .then((sbuCode) async {
              MySharedPreferences.instance
                  .getCityStringValue("employee_code")
                  .then((approverCode) async {
                MySharedPreferences.instance
                    .getCityStringValue('JSESSIONID')
                    .then((session) async {
                  MySharedPreferences.instance
                      .getCityStringValue('role_code')
                      .then((approverType) async {
                    MySharedPreferences.instance
                        .getCityStringValue('PROJECT_CODE')
                        .then((projectCode) async {
                      MySharedPreferences.instance
                          .getCityStringValue('DEPARTMENT')
                          .then((departmentCode) async {
                        MySharedPreferences.instance
                            .getCityStringValue('user_id')
                            .then((userId) async {
                          MySharedPreferences.instance
                              .getCityStringValue('user_name')
                              .then((userName) async {
                            final IdeaRequest mIdeaRequest = IdeaRequest(
                                ideaInShortController.text,
                                selectedThemesCode,
                                ideaInDetailController.text,
                                sbuCode,
                                projectCode,
                                departmentCode,
                                isAnonymous.toString(),
                                imageList,
                                fileNameList,
                                approverCode,
                                approverType,
                                emailID,
                                email,
                                userId,
                                userName,
                                deviceName,
                                "1");
                            final String requestBody =
                                json.encoder.convert(mIdeaRequest);

                            SubmitIdeaApi sng =
                                SubmitIdeaApi(session, requestBody);
                            var res = await sng.callSubmitIdeaAPi();
                            if (res!.data
                                .toString()
                                .contains("Added Succesfully.")) {
                              // ignore: use_build_context_synchronously
                              Navigator.pop(
                                  context); // ignore: use_build_context_synchronously
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  useRootNavigator: false,
                                  builder: (BuildContext context) {
                                    return PopScope(
                                      canPop: false,
                                      child: ConfirmationDialogBox(
                                        title: 'Idea Submitted Successfully.',
                                        press: () {
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    IdeasTabviewScreen(0)),
                                          );
                                        },
                                        color: Colors.white,
                                        text: 'Done',
                                      ),
                                    );
                                  });

                              // showNotification();
                              // final service =
                              //     FlutterBackgroundService();
                              // var isRunning =
                              //     await service.isRunning();
                              // if (!isRunning) {
                              //   service.startService();
                              // }
                            } else {
                              // ignore: use_build_context_synchronously
                              Navigator.pop(
                                  context); // ignore: use_build_context_synchronously
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  useRootNavigator: false,
                                  builder: (_) => const ShowDialogBox(
                                        title: 'Idea Submission Failed',
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
          barrierDismissible: false,
          context: context,
          useRootNavigator: false,
          builder: (_) => const GPSDialog());
      return;
    }
  }

  @override
  dispose() {
    //subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    scaffoldMessenger = ScaffoldMessenger.of(context);
    // dialogContext = context;
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
          // key: _scaffoldKey,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: kReSustainabilityRed,
            title: const Text(
              'Submit Idea',
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
                  setState(() {
                    buttonClick = true;
                  });
                  _gpsService();
                  getConnectivity();
                  // showLoaderDialog(context);
                },
                child: const Text(
                  "Submit Idea",
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
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
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
                  text: 'Idea in Short ',
                ),
                TextSpan(
                    text: '*',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kReSustainabilityRed)),
              ])),
        ),
        SizedBox(
          height: 1.h,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            inputFormatters: [
              NoLeadingSpaceFormatter(),
            ],
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w500, fontSize: 15),
            controller: ideaInShortController,
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            decoration: const InputDecoration(
                hintText: "",
                hintStyle: TextStyle(fontFamily: "ARIAL"),
                border: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.grey))),
          ),
        ),
        SizedBox(
          height: 1.h,
        ),
        Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              'Idea in Detail ',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontFamily: 'ARIAL',
                fontWeight: FontWeight.w400,
              ),
            )),
        SizedBox(
          height: 1.h,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              TextFormField(
                focusNode: _focusNode,
                onChanged: (value) {
                    ideaInDetailController.text = value;
                },
                inputFormatters: [
                  NoLeadingSpaceFormatter(),
                ],
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w500, fontSize: 15),
                controller: ideaInDetailController,
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                decoration: const InputDecoration(
                    hintText: "",
                    hintStyle: TextStyle(fontFamily: "ARIAL"),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.grey))),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: ValueListenableBuilder(
                  valueListenable: ideaInDetailController,
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
                    text: 'Select Idea Theme ',
                  ),
                  TextSpan(
                      text: '*',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kReSustainabilityRed)),
                ]))),
        SizedBox(
          height: 1.h,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(child: themesDropDown()),
        ),
        SizedBox(
          height: 1.h,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5.0, top: 5.0, right: 10.0),
          child: _attachPhoto(_photoController),
        ),
        SizedBox(
          height: 2.h,
        ),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                // key: const Key("otp_login_btn"),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    // backgroundColor: const Color(0xff00cc00),
                    backgroundColor: isAnonymous
                        ? Colors.grey.shade400
                        : const Color(0xff07C168),
                    minimumSize: const Size(0, 40)),
                onPressed: () async {},
                child: const Text(
                  'Public',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                      fontFamily: "ARIAL"),
                ),
              ),
              Switch(
                value: isAnonymous,
                onChanged: onToggle,
                activeTrackColor: Colors.grey,
                activeColor: const Color(0xff07C168),
              ),
              ElevatedButton(
                // key: const Key("otp_login_btn"),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    // backgroundColor: Colors.grey.shade400,
                    backgroundColor: isAnonymous
                        ? const Color(0xff07C168)
                        : Colors.grey.shade400,
                    minimumSize: const Size(0, 40)),
                onPressed: () async {},
                child: const Text(
                  'Anonymous',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                      fontFamily: "ARIAL"),
                ),
              ),
            ],
          ),
        ),
        // Padding(
        //     padding: EdgeInsets.only(
        //         bottom: MediaQuery.of(context).viewInsets.bottom)),
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

  Future<List> _getThemesList() async {
    List themesListToSearch = [];

    final database = await $FloorFlutterDatabase
        .databaseBuilder('flutter_database.db')
        .build();
    final dao = database.modelThemes;
    themesList = await dao.findAllThemes();
    if (themesList.isNotEmpty) {
      for (model_themes dept in await dao.findAllThemes()) {
        if (mounted == true) {
          setState(() {
            themesListToSearch.add(
                {'theme_code': dept.theme_code, 'theme_name': dept.theme_name});
          });
        }
      }
      return themesListToSearch;
    } else {
      return themesListToSearch;
    }
  }

  Widget _selectThemeSpinner(controller, TextInputType textInputType) {
    return Container(
        key: const ValueKey('c3'),
        child: FutureBuilder<List<dynamic>?>(
            future: _getThemesList(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return CustomSearchableDropDown(
                  menuPadding: const EdgeInsets.fromLTRB(20, 50, 20, 50),
                  dropdownHintText: 'Search For Themes Here... ',
                  showLabelInMenu: false,
                  dropdownItemStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                  primaryColor: Colors.black,
                  menuMode: false,
                  labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                  items: snapshot.data!,
                  label: 'Choose',
                  dropDownMenuItems: snapshot.data!.map((item) {
                    return item['theme_name'];
                  }).toList(),
                  onChanged: (value) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    if (value != null) {
                      selectedThemesCode = value['theme_code'];

                      MySharedPreferences.instance
                          .getCityStringValue('JSESSIONID')
                          .then((session) async {
                        RoleMappingBrainBoxApi sng =
                            RoleMappingBrainBoxApi(session, "Evaluator");
                        http.Response res =
                            await sng.callRoleMappingBrainBoxAPi();
                        if (res.body == "[]" || res.body == "") {
                          return;
                        }
                        MySharedPreferences.instance.setStringValue(
                            "employee_code",
                            jsonDecode(res.body)[0]["employee_code"]);
                        MySharedPreferences.instance.setStringValue(
                            "email", jsonDecode(res.body)[0]["email_id"]);
                        MySharedPreferences.instance.setStringValue(
                            "role_code", jsonDecode(res.body)[0]["role_code"]);
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

  Widget themesDropDown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: _selectThemeSpinner(_themeController, TextInputType.emailAddress),
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
                        if (fileListidea.isEmpty) {
                          return;
                        }
                        showDialog(
                                barrierDismissible: false,
                                context: context,
                                useRootNavigator: false,
                                builder: (BuildContext context) =>
                                    SubmitPhotoPreviewDialogPopUp(
                                        fileList: fileListidea))
                            .then((valueFromDialog) {
                          if (mounted == true) {
                            setState(() {
                              if (valueFromDialog.length == 0) {
                                imageList.clear();
                                fileNameList.clear();
                                fileListidea.clear();
                                photoCount = fileListidea.length.toString();
                              } else if (valueFromDialog.length != null) {
                                fileListidea = valueFromDialog;
                                photoCount = fileListidea.length.toString();
                                imageList.clear();
                                fileNameList.clear();
                                for (FileDetails fileData in fileListidea) {
                                  imageList.add(fileData.base64);
                                  fileNameList.add(fileData.fileName);
                                }
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
      fileListidea.add(FileDetails(
          fileName: file.name, filePath: file.path, base64: fileInBase64));
      photoCount = fileListidea.length.toString();
    } else {
      showDialog(
          barrierDismissible: false,
          context: context,
          useRootNavigator: false,
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
      fileListidea.add(FileDetails(
          fileName: file.name, filePath: file.path, base64: fileInBase64));
      photoCount = fileListidea.length.toString();
    }
  }

  Future<bool?> _showBackDialog() {
    return showDialog<bool>(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text('Please confirm',
                style: TextStyle(color: Colors.black, fontFamily: "ARIAL")),
            content: const Text('Do you want go back?\nDraft will be lost !',
                style: TextStyle(color: Colors.black, fontFamily: "ARIAL")),
            actions: <Widget>[
              TextButton(
                child: const Text('No',
                    style: TextStyle(
                        color: kReSustainabilityRed, fontFamily: "ARIAL")),
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
                      color: kReSustainabilityRed, fontFamily: "ARIAL"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDialogForLocationPermission(BuildContext context, title) {
    showDialog(
      barrierDismissible: false,
      context: context,
      useRootNavigator: false,
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

  Future<void> _deviceDetails() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        if (mounted == true) {
          setState(() {
            deviceName = build.model;
            deviceVersion = build.version.toString();
          });
        }
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        if (mounted == true) {
          setState(() {
            deviceName = data.name;
            deviceVersion = data.systemVersion;
            identifier = data.identifierForVendor!;
          });
        } //UUID for iOS
      }
    } on PlatformException {
      if (kDebugMode) {
        print('Failed to get platform version');
      }
    }
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
