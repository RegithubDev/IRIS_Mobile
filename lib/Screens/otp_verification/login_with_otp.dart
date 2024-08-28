import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:resus_test/Screens/otp_verification/OTPVerifyApiCall.dart';
import 'package:resus_test/Utility/internetCheck.dart';
import 'package:sizer/sizer.dart';
import '../../Utility/MySharedPreferences.dart';
import '../../Utility/authentication_loader.dart';
import '../../Utility/shared_preferences_string.dart';
import '../../Utility/showDialogBox.dart';
import '../../Utility/utils/constants.dart';
import '../../custom_sharedPreference.dart';
import '../drawer/privacy_policy.dart';
import '../drawer/terms_and_conditions.dart';
import '../home/home.dart';
import 'OTPExpairyTimeApiCall.dart';
import 'OTPLogApiCall.dart';

class LoginWithOtpScreen extends StatefulWidget {
  final String emailId;

  const LoginWithOtpScreen({super.key, required this.emailId});

  @override
  State<LoginWithOtpScreen> createState() => _LoginWithOtpScreenState(emailId);
}

class _LoginWithOtpScreenState extends State<LoginWithOtpScreen> {
  final GlobalKey<FormState> _FormKey = GlobalKey<FormState>();
  var entered_otp;
  var generated_otp;

  bool buttonClick = false;

  int secondsRemaining = 180;
  bool enableResend = false;
  late Timer _timer;

  final String mEmailId;
  late BuildContext dialogContext; // global declaration

  bool isDeviceConnected = false;
  bool isAlertSet = false;

  String currentText = "";

  _LoginWithOtpScreenState(this.mEmailId);

  Widget buildResendOtpBtn() {
    return Container(
        alignment: Alignment.center,
        child: TextButton(
          key: const Key('resend_otp_btn'),
          onPressed: enableResend ? _resendCode : null,
          child: Text(
            'RESEND',
            style: TextStyle(
                color: getTextColor(),
                fontWeight: FontWeight.bold,
                fontSize: 9.sp),
          ),
        ));
  }

  Color getTextColor() {
    if (!enableResend) {
      return Colors.grey;
    } else {
      return const Color(0xff000000);
    }
  }

  void _resendCode() {
    setState(() {
      MySharedPreferences.instance
          .getCityStringValue('JSESSIONID')
          .then((session) async {
        generated_otp = generateOTP();
        OTPVerifyApiCall ot =
            OTPVerifyApiCall(session, mEmailId, generated_otp);
        ot.callOTPVerifyAPi();
        MySharedPreferences.instance.setStringValue("saved_otp", generated_otp);
      });

      secondsRemaining = 180;
      enableResend = false;
    });
  }

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secondsRemaining != 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        setState(() {
          enableResend = true;
        });
      }
    });
    getConnectivity();
    super.initState();
  }

  getInit() {
    MySharedPreferences.instance
        .getCityStringValue('JSESSIONID')
        .then((session) async {
      generated_otp = generateOTP();
      OTPVerifyApiCall ot = OTPVerifyApiCall(session, mEmailId, generated_otp);
      await ot.callOTPVerifyAPi();
      MySharedPreferences.instance.setStringValue("saved_otp", generated_otp);
    });
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

  @override
  dispose() {
    _timer.cancel();
    // subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    // dialogContext = context;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 5.h,
                    ),
                    Center(
                      child: Image.asset(
                        'assets/images/reone_logo_updated.png',
                        height: height * 0.02.h,
                        scale: 0.09.h,
                      ),
                    ),
                    SizedBox(
                      height: 12.h,
                    ),
                    Text(
                      'Enter The Verification Code Just Sent To Your Email ID',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: "ARIAL",
                          fontSize: 10.sp),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    Form(
                      key: _FormKey,
                      child: Padding(
                        padding: EdgeInsets.only(right: 6.h),
                        child: PinCodeTextField(
                          animationType: AnimationType.none,
                          length: 6,
                          appContext: context,
                          autoFocus: false,
                          keyboardType: TextInputType.number,
                          showCursor: true,
                          cursorColor: kReSustainabilityRed,
                          cursorWidth: 2,
                          onChanged: (value) {
                            setState(() {
                              currentText = value;
                            });
                          },
                          // onSubmitted: (String verificationCode) {
                          //   currentText = verificationCode;
                          // },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Not Received?",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: "ARIAL",
                            fontSize: 9.sp,
                          ),
                        ),
                        buildResendOtpBtn(),
                        Text(
                          'Resend OTP in $secondsRemaining Seconds',
                          style: TextStyle(
                              color: kReSustainabilityRed,
                              fontSize: 9.sp,
                              fontFamily: "ARIAL"),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 4.h,
                    ),
                    SizedBox(
                      width: 90.w,
                      child: ElevatedButton(
                        key: const Key("otp_login_btn"),
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            backgroundColor: kReSustainabilityRed,
                            minimumSize: Size(0, 6.h)),
                        onPressed: () {
                          showDialog(
                              useRootNavigator: false,
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => const AthenticationLoader());

                          if (currentText == "") {
                            Navigator.pop(context);
                            showDialog(
                                useRootNavigator: false,
                                barrierDismissible: false,
                                context: context,
                                builder: (_) => const ShowDialogBox(
                                  title: 'Enter OTP First',
                                ));
                            return;
                          }
                          if (enableResend) {
                            if (currentText == generated_otp) {
                              Navigator.pop(context);
                              showDialog(
                                  useRootNavigator: false,
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (_) => const ShowDialogBox(
                                    title: 'OTP Expired',
                                  ));
                              return;
                            }
                          }

                          MySharedPreferences.instance
                              .getCityStringValue('JSESSIONID')
                              .then((session) async {
                            OTPLogApi otplog =
                            OTPLogApi(session, mEmailId, generated_otp);
                            String res = await otplog.callOTPLogAPi();
                            MySharedPreferences.instance
                                .setStringValue("saved_otp", generated_otp);

                            if (res == "OTP Logged Succesfully.") {
                              MySharedPreferences.instance
                                  .getCityStringValue('user_id')
                                  .then((userID) async {
                                MySharedPreferences.instance
                                    .getCityStringValue('JSESSIONID')
                                    .then((session) async {
                                  OTPExpairyTimeApi otpexp = OTPExpairyTimeApi(
                                      session, mEmailId, generated_otp);
                                  String res =
                                  await otpexp.callOTPExpairyTimeAPi();
                                  MySharedPreferences.instance.setStringValue(
                                      "saved_otp", generated_otp);
                                  if (res == "OTP is Valid") {
                                    MySharedPreferences.instance
                                        .getCityStringValue('saved_otp')
                                        .then((saved_otp) async {
                                      if (saved_otp == currentText) {
                                        Navigator.pop(context);
                                        CustomSharedPref.setPref<bool>(
                                            SharedPreferencesString.isLoggedIn,
                                            true);
                                        CustomSharedPref.setPref<String>(
                                            SharedPreferencesString.userId,
                                            userID);
                                        CustomSharedPref.setPref<String>(
                                            SharedPreferencesString.emailId,
                                            mEmailId);
                                        Navigator.of(context)
                                            .push(
                                          MaterialPageRoute(
                                              builder: (context) => Home(
                                                  googleSignInAccount: null,
                                                  userId: userID,
                                                  emailId: mEmailId,
                                                  initialSelectedIndex: 0)),
                                        )
                                            .then((value) => setState(() {}));
                                      } else {
                                        Navigator.pop(context);
                                        // ignore: use_build_context_synchronously
                                        showDialog(
                                            useRootNavigator: false,
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (_) => const ShowDialogBox(
                                              title: 'Invalid OTP.',
                                            ));
                                      }
                                    });
                                  } else if (res == "OTP is Expired.") {
                                    // ignore: use_build_context_synchronously
                                    Navigator.pop(context);
                                    // ignore: use_build_context_synchronously
                                    showDialog(
                                        useRootNavigator: false,
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (_) => const ShowDialogBox(
                                          title: 'OTP is Expired.',
                                        ));
                                  } else {
                                    // ignore: use_build_context_synchronously
                                    Navigator.pop(context);
                                    // ignore: use_build_context_synchronously
                                    showDialog(
                                        useRootNavigator: false,
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (_) => const ShowDialogBox(
                                          title: 'Invalid OTP',
                                        ));
                                  }
                                });
                              });
                            } else if (res == "User Not Found") {
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                              // ignore: use_build_context_synchronously
                              showDialog(
                                  useRootNavigator: false,
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (_) => const ShowDialogBox(
                                    title: 'User Not Found.',
                                  ));
                            }
                          });
                        },
                        child: Text(
                          "Login with OTP",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 10.h,
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
                        color: kReSustainabilityRed,
                        width: 1.0, // Underline thickness
                      ))),
                      child: Text(
                        "Terms and Conditions",
                        style: TextStyle(
                            // decoration: TextDecoration.underline,
                            color: kReSustainabilityRed,
                            fontSize: 12.sp),
                      ),
                    )),
                Text(
                  "&",
                  style: TextStyle(color: Colors.grey, fontSize: 12.sp),
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
                        color: kReSustainabilityRed,
                        width: 1.0, // Underline thickness
                      ))),
                      child: Text(
                        "Privacy Policy",
                        style: TextStyle(
                            color: kReSustainabilityRed, fontSize: 12.sp),
                      ),
                    )),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Powered by ',
                  style: TextStyle(
                    color: const Color(0xffbcbcbc),
                    fontSize: 11.sp,
                    fontFamily: 'ARIAL',
                  ),
                ),
                SvgPicture.asset(
                  'assets/icons/re.svg',
                  height: 1.2.h,
                  width: 1.2.h,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String generateOTP() {
    Random random = Random();
    String otp = '';
    for (int i = 0; i < 6; i++) {
      otp = otp + random.nextInt(9).toString();
    }
    return otp;
    // return "123456";
  }
}