import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rrgbm/presentation/shared/extensions/context_extensions.dart';

class SpeedSlider extends StatefulWidget {
  final void Function(double value) onChange;
  final bool enabled;
  const SpeedSlider({Key? key, required this.onChange, required this.enabled}) : super(key: key);

  @override
  State<SpeedSlider> createState() => _SpeedSliderState();
}

class _SpeedSliderState extends State<SpeedSlider> {
  double value = 10;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          value: value,
          inactiveColor: context.colorScheme.onBackground,
          min: 5,
          max: 30,
          onChanged: (newValue) {
            if (!widget.enabled) {
              return;
            }

            widget.onChange(newValue);
            setState(() {
              value = newValue;
            });
          },
        ),
        Text(
          "Movement Speed",
          style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}
