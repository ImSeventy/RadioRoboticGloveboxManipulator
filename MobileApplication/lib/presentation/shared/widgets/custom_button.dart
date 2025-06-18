import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rrgbm/presentation/shared/extensions/context_extensions.dart';

import 'loading_indicator.dart';


class CustomButton extends StatelessWidget {
  final VoidCallback callback;
  final String text;
  final bool isLoading;
  final Color? backgroundColor;

  const CustomButton({
    Key? key,
    required this.callback,
    required this.text,
    required this.isLoading,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
          backgroundColor: backgroundColor ?? context.colorScheme.primary,
          minimumSize: Size(180.w, 20.h)),
      onPressed: isLoading ? null : callback,
      child: isLoading ? const LoadingIndicator() : Text(
        text,
        style: context.theme.textTheme.titleMedium
            ?.copyWith(color: context.colorScheme.onPrimary),
      ),
    );
  }
}
