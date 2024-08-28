import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../Utility/utils/constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final void Function() onPressed;
  final double elevation;
  final double borderRadius;
  final EdgeInsets? padding;
  final double? textSize;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.elevation = 0,
    this.borderRadius = 10,
    this.padding,
    this.textSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      elevation: elevation,
      fillColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: padding ??
            EdgeInsets.only(top: 2.h, bottom: 2.h, left: 2.h, right: 2.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              text,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: kReSustainabilityRed,
                  fontSize:
                      textSize ?? Theme.of(context).textTheme.labelLarge!.fontSize,
                  fontFamily: 'ARIAL',
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
