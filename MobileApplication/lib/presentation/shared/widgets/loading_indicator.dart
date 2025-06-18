import 'package:flutter/material.dart';
import 'package:rrgbm/presentation/shared/extensions/context_extensions.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FittedBox(child: CircularProgressIndicator(
      color: context.colorScheme.onPrimary,
    ));
  }
}
