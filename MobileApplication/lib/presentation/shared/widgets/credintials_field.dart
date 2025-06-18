import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CredentialsField extends StatefulWidget {
  final TextInputType keyboardType;
  final TextEditingController controller;
  final bool isPassword;
  final String labelText;
  final String hintText;
  final Icon prefixIcon;
  final String? Function(String?) validator;

  const CredentialsField(
      {Key? key,
        required this.keyboardType,
        required this.labelText,
        required this.hintText,
        required this.prefixIcon,
        required this.controller,
        this.isPassword = false,
        required this.validator})
      : super(key: key);

  factory CredentialsField.password({
    required labelText,
    required hintText,
    required prefixIcon,
    required controller,
    required validator,
  }) {
    return CredentialsField(
      keyboardType: TextInputType.visiblePassword,
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      validator: validator,
      controller: controller,
      isPassword: true,
    );
  }

  @override
  State<CredentialsField> createState() => _CredentialsFieldState();
}

class _CredentialsFieldState extends State<CredentialsField> {
  late bool isPasswordHidden;

  @override
  void initState() {
    isPasswordHidden = widget.isPassword;
    super.initState();
  }

  void togglePasswordVisibility() {
    setState(() {
      isPasswordHidden = !isPasswordHidden;
    });
  }

  IconButton? get suffixWidget {
    if (!widget.isPassword) return null;

    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: togglePasswordVisibility,
      icon: isPasswordHidden
          ? const Icon(Icons.visibility)
          : const Icon(Icons.visibility_off),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 15.h),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: isPasswordHidden,
        validator: widget.validator,
        decoration: InputDecoration(
            filled: false,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            labelText: widget.labelText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: suffixWidget,
            hintText: widget.hintText),
        maxLines: 1,
      ),
    );
  }
}
