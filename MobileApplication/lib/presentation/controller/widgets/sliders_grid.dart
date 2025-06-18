import 'package:flutter/cupertino.dart';
import 'package:rrgbm/presentation/controller/widgets/joint_slider.dart';

class SlidersGrid extends StatelessWidget {
  final List<Map<String, dynamic>> jointsData;
  final bool enabled;
  final void Function(String code, double value) onJointChange;
  const SlidersGrid(
      {Key? key, required this.jointsData, required this.onJointChange, required this.enabled})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 25,
        runSpacing: 5,
        children: jointsData.map(_createSlider).toList(),
      ),
    );
  }

  Widget _createSlider(Map<String, dynamic> jointData) => JointSlider(
        enabled: enabled,
        label: jointData["name"],
        initialAngle: jointData["initialAngle"],
        minAngle: jointData["minAngle"],
        maxAngle: jointData["maxAngle"],
        onChange: (double value) => onJointChange(
          jointData["code"],
          value,
        ),
      );
}
