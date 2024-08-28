import 'package:flutter/cupertino.dart';

import 'OptionRadioPage.dart';

class OptionRadio extends StatefulWidget {
  final String text;
  final int index;
  final int selectedButton;
  final Function press;

  const OptionRadio({
    super.key,
    required this.text,
    required this.index,
    required this.selectedButton,
    required this.press,
  });

  @override
  OptionRadioPage createState() => OptionRadioPage();
}
