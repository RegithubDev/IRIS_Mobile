import 'package:flutter/material.dart';
import 'package:resus_test/Utility/utils/constants.dart';

import 'OptionRadio.dart';

class OptionRadioPage extends State<OptionRadio> {
  int id = 1;
  late bool _isButtonDisabled;

  OptionRadioPage();

  @override
  void initState() {
    super.initState();
    _isButtonDisabled = false;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        key: const ValueKey('radioButton'),
        onTap: () {
          widget.press(widget.index);
        },
        child: Row(
          children: <Widget>[
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                    unselectedWidgetColor: Colors.grey,
                    disabledColor: Colors.blue),
                child: Column(children: [
                  RadioListTile(
                    title: Text(
                      widget.text,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      softWrap: true,
                    ),
                    groupValue: widget.selectedButton,
                    value: widget.index,
                    activeColor: kReSustainabilityRed,
                    onChanged: (val) async {
                      debugPrint('Radio button is clicked onChanged $val');
                      widget.press(widget.index);
                    },
                    toggleable: true,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
