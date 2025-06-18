import 'package:flutter/material.dart';
import 'package:rrgbm/presentation/shared/extensions/context_extensions.dart';

class PropertyHolder extends StatelessWidget {
  final String propertyName;
  final String data;
  final bool isTitle;
  final double? fontSize;

  const PropertyHolder({
    Key? key,
    required this.propertyName,
    required this.data,
    this.isTitle = false,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
          text: "$propertyName: ",
          style: isTitle
              ? context.theme.textTheme.titleMedium?.copyWith(
            color: context.colorScheme.onBackground,
            fontSize: fontSize,
          )
              : context.theme.textTheme.titleMedium?.copyWith(
            fontSize: fontSize,
          ),
          children: [
            TextSpan(
              text: data,
              style: TextStyle(color: context.colorScheme.primary),
            )
          ]),
    );
  }
}
