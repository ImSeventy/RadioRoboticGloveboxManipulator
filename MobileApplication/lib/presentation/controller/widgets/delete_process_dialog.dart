import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rrgbm/presentation/shared/extensions/context_extensions.dart';

class DeleteProcessDialog extends StatelessWidget {
  final VoidCallback callback;
  const DeleteProcessDialog({Key? key, required this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      backgroundColor: context.theme.scaffoldBackgroundColor,
      children: [
        SimpleDialogOption(
          child: Text(
            "Delete",
            style: context.theme.textTheme.titleMedium?.copyWith(
                color: Colors.red
            ),
          ),
          onPressed: () {
            context.navigator.pop();
            callback();
          },
        ),
        const Divider(
          color: Colors.black,
          thickness: 2,
        ),
        SimpleDialogOption(
          child: Text(
              "Cancel",
              style: context.theme.textTheme.titleMedium
          ),
          onPressed: () {
            context.navigator.pop();
          },
        ),
      ],
    );
  }
}



