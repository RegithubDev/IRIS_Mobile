import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:resus_test/Utility/utils/constants.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TimeLine extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final bool isPast;
  final String eventName;
  final double width;
  const TimeLine({super.key, required this.isFirst, required this.isLast, required this.isPast, required this.eventName, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: width,
      child: TimelineTile(
        axis: TimelineAxis.horizontal,
        isFirst: isFirst,
        isLast: isLast,
        beforeLineStyle: LineStyle(color: isPast ? Colors.green: kGreyTimeline),
        indicatorStyle: IndicatorStyle(
          width: 10,
          color: isPast ? Colors.green: kGreyTimeline,
          iconStyle: IconStyle(iconData: Icons.done, color: isPast ? Colors.white: kGreyTimeline),
        ),
        endChild: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(eventName, style: const TextStyle( fontFamily:
          'Roboto',
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w400,),),
        ),
      ),
    );
  }
}
