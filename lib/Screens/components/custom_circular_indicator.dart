import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:resus_test/Utility/utils/constants.dart';

class CustomCircularIndicator extends StatelessWidget {
  final double radius;
  final double percent;
  final double lineWidth;
  final double? line1Width;
  final double? count;

  const CustomCircularIndicator(
      {Key? key,
      required this.radius,
      required this.percent,
      this.lineWidth = 5,
      this.line1Width,
      required this.count})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('customCircularIndicator'),
      children: <Widget>[
        CircularPercentIndicator(
          radius: radius / 2,
          animation: true,
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: kReSustainabilityRed,
          arcBackgroundColor: Colors.grey[300],
          arcType: ArcType.FULL,
          lineWidth: lineWidth,
          percent: percent,
          center: Center(
            child: checkCountIsNan(context, count),
          ),
        ),
      ],
    );
  }

  checkCountIsNan(BuildContext context, mCount) {
    if (mCount.isNaN) {
      return Text("0",
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(fontWeight: FontWeight.w700, fontSize: 14));
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count!.round().toString(),
              // '${NumberFormat.decimalPattern().format(count).split('.')[0]}%',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.w700, fontSize: 14)),
          const Text("%",
          style: TextStyle(fontWeight: FontWeight.bold),)
        ],
      );
    }
  }
}
