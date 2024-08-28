import 'package:flutter/material.dart';
import 'package:resus_test/Utility/utils/constants.dart';

class DialogRoundedButton extends StatelessWidget {
  final String text;
  final VoidCallback? press; // Good
  final Color color, textColor;

  const DialogRoundedButton({
    super.key,
    required this.text,
    required this.press,
    required this.color,
    this.textColor = kReSustainabilityRed,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      key: const ValueKey('roundedButton'),
      margin: const EdgeInsets.all(10.0),
      width: 300.0,
      height: 40.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: newElevatedButton(),
      ),
    );
  }

  Widget newElevatedButton() {
    return ElevatedButton(
      onPressed: press,
      style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          textStyle: TextStyle(
              color: textColor, fontSize: 14, fontWeight: FontWeight.w500)),
      child: Text(
        text,
        style: TextStyle(
            color: textColor,
            fontFamily: 'ARIAL',
            fontSize: 16,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
