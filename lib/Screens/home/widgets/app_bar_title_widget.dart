import 'package:flutter/material.dart';

class AppBarTitleWidget extends StatelessWidget {
  const AppBarTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      key: ValueKey('homeAppbar'),
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Re ',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'ARIAL'),
              ),
              TextSpan(
                text: 'Sustainability',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'ARIAL'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
