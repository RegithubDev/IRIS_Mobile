import 'package:flutter/material.dart';
import 'package:resus_test/Utility/utils/constants.dart';

class ShowDialogBox extends StatelessWidget {
  final String title;

  const ShowDialogBox({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        key: const ValueKey('showDialog'),
        title: const Text(
          "Alert!!",
          style: TextStyle(color: kReSustainabilityRed, fontFamily: "ARIAL"),
        ),
        content: Text(
          title,
          style: const TextStyle(fontFamily: "ARIAL"),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              "OK",
              style:
                  TextStyle(color: kReSustainabilityRed, fontFamily: "ARIAL"),
            ),
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
