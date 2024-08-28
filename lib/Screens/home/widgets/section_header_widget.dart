import 'package:flutter/material.dart';

import '../../../Utility/utils/constants.dart';

class SectionHeaderWidget extends StatelessWidget {
  final String title;
  final void Function()? onPressed;

  const SectionHeaderWidget({
    Key? key,
    required this.title,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: Row(
        key: const ValueKey('sectionheaderContainer1'),
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme.titleLarge!
                  .copyWith(fontWeight: FontWeight.w700, fontFamily: 'ARIAL'),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          onPressed != null
              ? TextButton(
                  onPressed: onPressed,
                  child: Text(
                    'see_all',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        fontSize: 12,
                        fontFamily: 'ARIAL',
                        color: kReSustainabilityRed),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
