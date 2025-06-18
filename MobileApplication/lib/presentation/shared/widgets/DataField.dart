import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DataField extends StatelessWidget {
  final TextInputType keyboardType;
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final Icon prefixIcon;
  final bool enabled;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;

  const DataField({
    Key? key,
    required this.keyboardType,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    required this.validator,
    required this.enabled,
    this.textInputAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 15.h,
        horizontal: 20.w,
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        textInputAction: textInputAction,
        enabled: enabled,
        decoration: InputDecoration(
          filled: false,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          labelText: labelText,
          prefixIcon: prefixIcon,
          hintText: hintText,
        ),
        maxLines: 1,
      ),
    );
  }
}
