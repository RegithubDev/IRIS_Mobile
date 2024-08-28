import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SocialIcon extends StatelessWidget {
  final List<Color> colors;
  final IconData iconData;
  final void Function() onPressed;

  const SocialIcon({super.key,
    required this.colors,
    required this.iconData,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14),
      child: Container(
        key: const ValueKey('socialLogin'),
        width: 5.h,
        height: 5.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: colors, tileMode: TileMode.clamp),
        ),
        child: RawMaterialButton(
          shape: const CircleBorder(),
          onPressed: onPressed,
          child: Image.asset('assets/images/googleAuth.png'),
        ),
      ),
    );
  }
}
