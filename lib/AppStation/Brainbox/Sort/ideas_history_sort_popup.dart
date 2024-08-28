import 'package:flutter/material.dart';
import 'package:resus_test/Utility/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Utility/OptionRadio.dart';

class IdeasHistorySortPopup extends StatefulWidget {
  const IdeasHistorySortPopup({Key? key}) : super(key: key);

  @override
  State<IdeasHistorySortPopup> createState() =>
      _IdeasHistorySortPopupState();
}

class _IdeasHistorySortPopupState extends State<IdeasHistorySortPopup> {
  String sortKey = "";
  late int selectedButton = 5;

  Future<bool> saveSwitchState(int value, String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value);
    return prefs.setInt(key, value);
  }

  getSwitchValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedButton = prefs.getInt("selected_item")!;
    });
  }

  @override
  void initState() {
    super.initState();
    // getSwitchValues();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: const ValueKey('incidentHistoryDialog'),
      backgroundColor: Colors.grey[200],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Sort',
                    style:
                    TextStyle(fontSize: 25, fontWeight: FontWeight.w500)),
              ),
              Container(
                margin: const EdgeInsets.only(top: 24, right: 24, bottom: 10),
                width: 25,
                height: 25,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: kReSustainabilityRed),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Center(
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 15.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(
            thickness: 1,
            color: Colors.grey,
          ),
          OptionRadio(
              text: 'Created Date',
              index: 0,
              selectedButton: selectedButton,
              press: (val) {
                selectedButton = val;
                setState(() {
                  sortKey = 'Created Date';
                  saveSwitchState(val, 'selected_item');
                });
              }),
          OptionRadio(
              text: 'Reviewer Type',
              index: 1,
              selectedButton: selectedButton,
              press: (val) {
                selectedButton = val;
                setState(() {
                  sortKey = 'Reviewer Type';
                  saveSwitchState(val, 'selected_item');
                });
              }),
          OptionRadio(
              text: 'Reviewer Name',
              index: 2,
              selectedButton: selectedButton,
              press: (val) {
                selectedButton = val;
                setState(() {
                  sortKey = 'Reviewer Name';
                  saveSwitchState(val, 'selected_item');
                });
              }),
          Center(
            child: TextButton(
                onPressed: () {
                  Navigator.pop(context, sortKey);
                },
                child: const Text(
                  "OK",
                  style: TextStyle(
                      color: kReSustainabilityRed,
                      fontFamily: "ARIAL",
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                )),
          )
        ],
      ),
    );
  }
}
