import 'dart:async';
import 'dart:convert';

import 'package:cron/cron.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:resus_test/Utility/internetCheck.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../Utility/MySharedPreferences.dart';
import '../../Utility/api_Url.dart';
import '../../Utility/permission_request.dart';
import '../../Utility/shared_preferences_string.dart';
import '../../Utility/utils/constants.dart';
import '../../custom_sharedPreference.dart';
import '../login/login_page.dart';

class HomePage extends StatefulWidget {
  final GoogleSignInAccount? googleSignInAccount;
  final String userId;
  final String emailId;

  const HomePage(
      {super.key,
      required this.googleSignInAccount,
      required this.userId,
      required this.emailId});

  @override
  _HomePageState createState() =>
      _HomePageState(googleSignInAccount, userId, emailId);
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  late final String phoneNumber;

  PermissionRequest permissionRequest = PermissionRequest();

  GoogleSignInAccount? m_googleSignInAccount;
  String m_user_id;
  String m_emailId;

  _HomePageState(this.m_googleSignInAccount, this.m_user_id, this.m_emailId);

  bool isDeviceConnected = false;
  bool isAlertSet = false;

  InAppWebViewController? webViewController;
  PullToRefreshController? refreshController;
  var initialUrl = "";
  double progress = 0;
  var urlController = TextEditingController();
  var isloading = false;

  bool loadURL = false;

  @override
  initState() {
    // getConnectivity();
    if (m_user_id == "") {
      setState(() {
        initialUrl = "https://appmint.resustainability.com/index/home";
      });
    } else {
      setState(() {
        initialUrl =
            "https://appmint.resustainability.com/index/login?email_id=$m_emailId";
      });
    }
    refreshController = PullToRefreshController(
        onRefresh: () {
          webViewController!.reload();
        },
        options: PullToRefreshOptions(
            color: Colors.white, backgroundColor: Colors.black));
    var cron = Cron();
    //Cron will run Every sunday 7.30 am
    cron.schedule(Schedule.parse('30  7  *  *  0'), () async {
      MySharedPreferences.instance
          .getCityStringValue('JSESSIONID')
          .then((session) async {
        logoutAPICall(session);
      });
    });
    super.initState();
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
                        setState(() {
                          loadURL = true;
                        });
                        if (m_user_id == "") {
                          setState(() {
                            initialUrl =
                                "https://appmint.resustainability.com/index/home";
                          });
                        } else {
                          setState(() {
                            initialUrl =
                                "https://appmint.resustainability.com/index/login?email_id=$m_emailId";
                          });
                        }
                        refreshController = PullToRefreshController(
                            onRefresh: () {
                              webViewController!.reload();
                            },
                            options: PullToRefreshOptions(
                                color: Colors.white,
                                backgroundColor: Colors.black));
                        var cron = Cron();
                        //Cron will run Every sunday 7.30 am
                        cron.schedule(Schedule.parse('30  7  *  *  0'),
                            () async {
                          MySharedPreferences.instance
                              .getCityStringValue('JSESSIONID')
                              .then((session) async {
                            logoutAPICall(session);
                          });
                        });
                      }
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      );

  getConnectivity() async {
   isDeviceConnected = await Future.value(
                          InternetCheck().checkInternetConnection())
                      .timeout(const Duration(seconds: 2));
        if (!isDeviceConnected && isAlertSet == false) {
          showDialogBox();
          setState(() {
            isAlertSet = true;
            loadURL = false;
          });
        } else {
          setState(() {
            loadURL = true;
          });
          if (m_user_id == "") {
            setState(() {
              initialUrl = "https://appmint.resustainability.com/index/home";
            });
          } else {
            setState(() {
              initialUrl =
                  "https://appmint.resustainability.com/index/login?email_id=$m_emailId";
            });
          }
          refreshController = PullToRefreshController(
              onRefresh: () {
                webViewController!.reload();
              },
              options: PullToRefreshOptions(
                  color: Colors.white, backgroundColor: Colors.black));

          var cron = Cron();
          //Cron will run Every sunday 7.30 am
          cron.schedule(Schedule.parse('30  7  *  *  0'), () async {
            MySharedPreferences.instance
                .getCityStringValue('JSESSIONID')
                .then((session) async {
              logoutAPICall(session);
            });
          });
        }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Material(
      child: PopScope(
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
            extendBodyBehindAppBar: true,
            key: const ValueKey('homePageContainer'),
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: false,
            body: Column(
              children: [
                Expanded(
                    child: Stack(
                  alignment: Alignment.center,
                  children: [
                    InAppWebView(
                      onLoadStart: (controller, url) {
                        setState(() {
                          isloading = true;
                        });
                      },
                      onLoadStop: (controller, url) {
                        refreshController!.endRefreshing();
                        setState(() {
                          isloading = false;
                        });
                      },
                      pullToRefreshController: refreshController,
                      onWebViewCreated: (controller) =>
                          webViewController = controller,
                      initialUrlRequest: URLRequest(url: Uri.parse(initialUrl)),
                    ),
                    Visibility(
                        visible: isloading,
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.red),
                        ))
                  ],
                ))
              ],
            ),
          )),
    );
  }

  Future<String> getStringValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.getString(key) ?? "";
  }

  @override
  bool get wantKeepAlive => true;

  Future<bool?> _showBackDialog() {
    return showDialog<bool>(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text("Confirm Exit",
                style: TextStyle(
                  fontFamily: 'ARIAL',
                )),
            content: const Text("Are you sure you want to exit?",
                style: TextStyle(
                  fontFamily: 'ARIAL',
                )),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  "YES",
                  style: TextStyle(
                    color: kReSustainabilityRed,
                    fontFamily: 'ARIAL',
                  ),
                ),
                onPressed: () {
                  SystemNavigator.pop();
                },
              ),
              TextButton(
                child: const Text("NO",
                    style: TextStyle(
                      color: kReSustainabilityRed,
                      fontFamily: 'ARIAL',
                    )),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
      },
    );
  }

  logoutAPICall(String sessionId) async {
    var headers = {'Content-Type': 'application/json', 'Cookie': sessionId};
    var request = http.Request('GET', Uri.parse(LOGOUT));
    request.body = json.encode({});
    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("control comes here 2");
      }
      MySharedPreferences.instance.setStringValue("IRIS_ROLE_NAME", "");

      CustomSharedPref.setPref<bool>(SharedPreferencesString.isLoggedIn, false);
      CustomSharedPref.setPref<String>(SharedPreferencesString.userId, "");
      CustomSharedPref.setPref<String>(SharedPreferencesString.emailId, "");
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const LoginPage()));
    } else {
      if (kDebugMode) {
        print(response.reasonPhrase);
      }
    }
  }
}
