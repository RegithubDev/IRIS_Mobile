import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:resus_test/Utility/utils/constants.dart';
import 'package:sizer/sizer.dart';

class ConfirmationDialogBox extends StatelessWidget {
  final String title;
  final VoidCallback? press; // Good
  final Color color, textColor;
  final String text;

  const ConfirmationDialogBox({
    Key? key,
    required this.title,
    required this.press,
    required this.color,
    this.textColor = kReSustainabilityRed,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      key: const ValueKey('confirmationDialog'),
      builder: (context, setState) {
        return PopScope(
            canPop: false,
            child: Material(
              child: Container(
                color: kReSustainabilityRed,
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 30.0.h),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/successfully signed in icon.svg',
                              semanticsLabel: 'Acme Logo',
                              height: 60,
                              width: 60,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                                padding: const EdgeInsets.only(
                                    left: 5, right: 5, top: 5),
                                child: Text(title,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontFamily: 'ARIAL'))),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      key: const ValueKey('roundedButton'),
                      margin: const EdgeInsets.all(10.0),
                      width: 300.0,
                      height: 40.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: ElevatedButton(
                          onPressed: press,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: color,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              textStyle: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                          child: Text(
                            text,
                            style: TextStyle(
                                color: textColor,
                                fontFamily: 'ARIAL',
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ));
      },
    );
  }
}
