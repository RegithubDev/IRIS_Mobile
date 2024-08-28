import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:resus_test/Screens/drawer/privacy_policy.dart';
import 'package:resus_test/Utility/internetCheck.dart';
import 'package:resus_test/Utility/utils/constants.dart';
import 'package:sizer/sizer.dart';
import '../../Utility/network_error_dialogbox.dart';
import '../../Utility/showDialogBox.dart';
import '../components/custom_button.dart';
import '../components/labeled_text_form_field.dart';
import '../drawer/terms_and_conditions.dart';
import '../otp_verification/login_with_otp.dart';
import 'loginApiCall.dart';
import 'widgets/social_login_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // final _emailController = TextEditingController(text: "@resustainability.com");
  final TextEditingController _emailController = TextEditingController();

  String deviceName = '';
  String deviceVersion = '';
  String identifier = '';

  bool isDeviceConnected = false;
  bool isAlertSet = false;

  List<String> suggestons = ["@resustainability.com"];

  @override
  void initState() {
    getConnectivity();
    super.initState();
    _deviceDetails();
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
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('loginContainer'),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 0.0.h, top: 15.h),
              child: Center(
                child: Image.asset(
                  'assets/images/reone_logo_updated.png',
                  height: MediaQuery.of(context).size.height * 0.17,
                  scale: 0.02,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 150, bottom: 0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                color: kReSustainabilityRed,
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 2.h, right: 2.h, bottom: 2.h),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 7.h,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email',
                          style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'ARIAL',
                              color: Colors.white),
                        ),
                        LabeledTextFormField(
                          key: const Key('email'),
                          title: '',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          hintText: 'Resustainability Email Only',
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomButton(
                      key: const Key('login_btn'),
                      onPressed: () async {
                        if (_emailController.text.isEmpty) {
                          showDialog(
                              useRootNavigator: false,
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => const ShowDialogBox(
                                    title: 'Please Enter Email-Id',
                                  ));
                          return;
                        }
                        if (!_emailController.text
                            .contains("@resustainability.com")) {
                          showDialog(
                              useRootNavigator: false,
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => const ShowDialogBox(
                                    title:
                                        'Invalid Email-Id. \nPlease Use Only Resustainability Email-Id.',
                                  ));
                          return;
                        }

                        var isConnected =
                            await Future.value(checkInternetConnection())
                                .timeout(const Duration(seconds: 2));
                        if (!isConnected) {
                          showDialog(
                              useRootNavigator: false,
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => const NetworkErrorDialog());
                          return;
                        }

                        PackageInfo packageInfo =
                            await PackageInfo.fromPlatform();
                        LoginApiCall loginApiCall = LoginApiCall(
                          _emailController.text,
                          deviceName,
                          "1",
                          packageInfo.version,
                        );

                        var response = await loginApiCall.callLoginAPi();
                        if (response?.statusCode == 200) {
                          String output = await loginApiCall.userLogin(
                            _emailController.text,
                            deviceName,
                            "1",
                            packageInfo.version,
                          );
                          if (output.isNotEmpty) {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => LoginWithOtpScreen(
                                emailId: _emailController.text.toString(),
                              ),
                            ));
                          } else {
                            showDialog(
                                useRootNavigator: false,
                                barrierDismissible: false,
                                context: context,
                                builder: (_) => const ShowDialogBox(
                                      title:
                                          'Authentication failed.\nPlease Enter a Valid Email-Id.',
                                    ));
                          }
                        }
                      },
                      text: 'Continue to Get OTP',
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Or",
                          style:
                              TextStyle(color: Colors.white, fontSize: 10.sp),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Login With',
                          style:
                              TextStyle(color: Colors.white, fontSize: 10.sp),
                        )
                      ],
                    ),
                    const Center(child: SocialLoginWidget()),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: kReSustainabilityRed,
                      height: 11.h,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                  onPressed: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return const TermsAndConditions();
                                        },
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                      color: Colors.white,
                                      width: 1.0, // Underline thickness
                                    ))),
                                    child: Text(
                                      "Terms and Conditions",
                                      style: TextStyle(
                                          // decoration: TextDecoration.underline,
                                          color: Colors.grey.shade300,
                                          fontSize: 11.sp),
                                    ),
                                  )),
                              Text(
                                "&",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11.sp),
                              ),
                              TextButton(
                                  onPressed: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return const PrivacyPolicy();
                                        },
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                      color: Colors.white,
                                      width: 1.0, // Underline thickness
                                    ))),
                                    child: Text(
                                      "Privacy Policy",
                                      style: TextStyle(
                                          color: Colors.grey.shade300,
                                          fontSize: 11.sp),
                                    ),
                                  )),
                            ],
                          ),
                          FutureBuilder<PackageInfo>(
                            future: PackageInfo.fromPlatform(),
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.done:
                                  return Align(
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(' V${snapshot.data!.version}',
                                            style: TextStyle(
                                              fontFamily: 'PTSans-Bold',
                                              color: Colors.white,
                                              fontSize: 11.sp,
                                              fontWeight:
                                                  FontWeight.normal, // italic
                                            )),
                                        const SizedBox(
                                          width: 1,
                                        ),
                                        Icon(
                                          Icons.copyright,
                                          color: Colors.white,
                                          size: 11.sp,
                                        ),
                                        Text(' 2023 ',
                                            style: TextStyle(
                                              fontFamily: 'PTSans-Bold',
                                              color: Colors.white,
                                              fontSize: 11.sp,
                                              fontWeight:
                                                  FontWeight.normal, // italic
                                            )),
                                        const SizedBox(
                                          width: 1,
                                        ),
                                        SvgPicture.asset(
                                          'assets/icons/re.svg',
                                          height: 1.5.h,
                                          width: 1.5.h,
                                          color: Colors.white,
                                        )
                                      ],
                                    ),
                                  );
                                default:
                                  return const SizedBox();
                              }
                            },
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

  Future<void> _deviceDetails() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        setState(() {
          deviceName = build.model;
          deviceVersion = build.version.toString();
        });
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        setState(() {
          deviceName = data.name;
          deviceVersion = data.systemVersion;
          identifier = data.identifierForVendor!;
        }); //UUID for iOS
      }
    } on PlatformException {
      if (kDebugMode) {
        print('Failed to get platform version');
      }
    }
  }

  static Size boundingTextSize(String text, TextStyle style,
      {int maxLines = 2 ^ 31, double maxWidth = double.infinity}) {
    if (text.isEmpty) {
      return Size.zero;
    }
    final TextPainter textPainter = TextPainter(
        textDirection: ui.TextDirection.ltr,
        text: TextSpan(text: text, style: style),
        maxLines: maxLines)
      ..layout(maxWidth: maxWidth);
    return textPainter.size;
  }

  Widget email() {
    return Container(
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            TextField(
              style: const TextStyle(color: Colors.white),
              controller: _emailController,
              onChanged: (text) {
                setState(() {});
              },
            ),
            Positioned(
              left: boundingTextSize(
                      _emailController.text,
                      const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.white))
                  .width,
              child: Visibility(
                  visible: _emailController.text.isNotEmpty,
                  child: const Text(
                    "@resustainability.com",
                    style: TextStyle(color: Colors.white),
                  )),
            ),
          ],
        ));
  }
}
