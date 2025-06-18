import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rrgbm/presentation/shared/extensions/context_extensions.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class JointSlider extends StatelessWidget {
  final String label;
  final double initialAngle;
  final double minAngle;
  final double maxAngle;
  final bool enabled;
  final void Function(double value) onChange;
  const JointSlider({Key? key, required this.label, required this.initialAngle, required this.minAngle, required this.maxAngle, required this.onChange, required this.enabled}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SleekCircularSlider(
        min: minAngle,
        initialValue: initialAngle,
        max: maxAngle,
        innerWidget: (value) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 30.h,
            ),
            Text(
              "${value.toInt().toString()}°",
              style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: context.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.rotate(
                  angle: value * pi / 180,
                  origin: Offset(30.sp / 2, 0),
                  child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 30.sp),
                      child: Icon(Icons.linear_scale, size: 35.sp, )
                  ),
                ),
                ConstrainedBox(constraints: BoxConstraints(maxWidth: 30.sp),
                    child: Icon(Icons.linear_scale, size: 35.sp, )),
              ],
            )
          ],
        ),
        appearance: CircularSliderAppearance(
            size: 160.sp,
            customWidths:
            CustomSliderWidths(trackWidth: 2, handlerSize: 4),
            customColors: CustomSliderColors(
              trackColor: context.colorScheme.onBackground,
              dotColor: context.colorScheme.onPrimary,
              progressBarColors: const [
                Color.fromARGB(255, 56, 65, 157),
                Color.fromARGB(255, 152, 228, 255),
              ],
            ),
            infoProperties: InfoProperties(
                bottomLabelStyle: TextStyle(
                    color: context.colorScheme.onBackground))),
        onChange: enabled ? onChange : null,
        );
  }
}
