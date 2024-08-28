import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:resus_test/Utility/internetCheck.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../Utility/utils/constants.dart';

class ReLearning extends StatefulWidget {
  @override
  State<ReLearning> createState() => _ReLearningState();
}

class _ReLearningState extends State<ReLearning> {
  TextEditingController searchController = TextEditingController();

  bool loadURL = false;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  var isloading = false;
  PullToRefreshController? refreshController;
  InAppWebViewController? webViewController;
  var initialUrl =
      "https://relearning.resustainability.com/resustainability/login/resustainability.jsp";

  @override
  void initState() {
    refreshController = PullToRefreshController(
        onRefresh: () {
          webViewController!.reload();
        },
        options: PullToRefreshOptions(
            color: Colors.white, backgroundColor: Colors.black));

    getConnectivity();
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
                      setState(() {
                        isAlertSet = true;
                        loadURL = false;
                      });
                    }
                  }
                  setState(() {
                    loadURL = true;
                  });
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
      setState(() {
        loadURL = true;
      });
    }
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kReSustainabilityRed,
        title: const Text(
          'Relearning',
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'ARIAL',
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        leading: InkWell(
            onTap: () async {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_ios)),
        centerTitle: true,
        elevation: 0,
      ),
      body: InAppWebView(
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
        onWebViewCreated: (controller) => webViewController = controller,
        initialUrlRequest: URLRequest(url: Uri.parse(initialUrl)),
      ),
    );
  }
}
