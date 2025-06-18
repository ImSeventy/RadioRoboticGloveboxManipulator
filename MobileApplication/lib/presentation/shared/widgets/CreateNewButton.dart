import 'package:flutter/material.dart';

class CreateNewButton extends StatelessWidget {
  final Widget toShowScreen;
  final String heroTag;
  final void Function(dynamic)? onResultCallBack;
  final Icon? icon;
  final Color? color;

  const CreateNewButton({Key? key, required this.toShowScreen, required this.heroTag, this.icon, this.color, this.onResultCallBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      backgroundColor: color,
      onPressed:() async {
        final result = await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => toShowScreen,
        );

        if (onResultCallBack != null && result != null) {
          onResultCallBack!(result);
        }
      },
      child: icon ?? const Icon(Icons.add),
    );
  }
}
