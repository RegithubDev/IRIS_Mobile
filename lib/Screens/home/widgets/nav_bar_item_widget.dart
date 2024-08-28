import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../Utility/utils/constants.dart';
import '../../../data/pref_manager.dart';

class NavBarItemWidget extends StatelessWidget {
  final void Function() onTap;
  final String image;
  final bool isSelected;
  final String label;

  const NavBarItemWidget(
      {Key? key,
      required this.onTap,
      required this.image,
      required this.isSelected,
      required this.label})
      : super(key: key);

  Color get _color => isSelected
      ? kReSustainabilityRed
      : Prefs.isDark()
          ? Colors.grey[800]!
          : Colors.grey;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 70,
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              image.isEmpty
                  ? Container()
                  : Padding(
                      padding:
                          const EdgeInsets.only(top: 5.0, left: 10, right: 10),
                      child: SvgPicture.asset(
                        'assets/icons/$image.svg',
                        semanticsLabel: 'Acme Logo',
                        height: 45,
                        width: 45,
                        color: _color,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
