import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final Color iconColor;
  final double elevation;
  final void Function() onPressed;

  const RoundIconButton({super.key,
    required this.icon,
    this.size = 52,
    this.color = Colors.white,
    this.iconColor = Colors.white,
    this.elevation = 0,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      key: const ValueKey('roundIconButton'),
      onPressed: onPressed,
      shape: const CircleBorder(),
      elevation: elevation,
      fillColor: color,
      constraints: BoxConstraints.tightFor(
        width: size,
        height: size,
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 4.h,
      ),
    );
  }
}
