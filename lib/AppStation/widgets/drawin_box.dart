import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:resus_test/Utility/internetCheck.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../Utility/utils/constants.dart';

class DrawinBox extends StatefulWidget {
  @override
  State<DrawinBox> createState() => _DrawinBoxState();
}

class _DrawinBoxState extends State<DrawinBox> {
  TextEditingController searchController = TextEditingController();

  bool loadURL = false;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void initState() {
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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kReSustainabilityRed,
          title: const Text(
            'Drawin Box',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'ARIAL',
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: loadURL == true
            ? WebView(
                initialUrl:
                    'https://play.google.com/store/apps/details?id=com.darwinbox.darwinbox',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (_controller) {
                },
              )
            : const SizedBox());
  }
}
