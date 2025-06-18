import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rrgbm/presentation/shared/extensions/context_extensions.dart';
import 'package:rrgbm/presentation/shared/widgets/custom_button.dart';

class SaveProcessDialog extends StatefulWidget {
  final void Function(String? name) callback;
  const SaveProcessDialog({Key? key, required this.callback}) : super(key: key);

  @override
  State<SaveProcessDialog> createState() => _SaveProcessDialogState();
}

class _SaveProcessDialogState extends State<SaveProcessDialog> {
  late TextEditingController nameController;

  @override
  void initState() {
    nameController = TextEditingController();
    super.initState();
  }

  @override
  void deactivate() {
    nameController.dispose();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      backgroundColor: context.theme.scaffoldBackgroundColor,
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              label: Text("name"),
              hintText: "Enter the process name",
              border: OutlineInputBorder()
            ),
            controller: nameController,
          ),
        ),
        const Divider(
          color: Colors.black,
          thickness: 2,
        ),
        SimpleDialogOption(
          child: Text(
            "Save",
            style: context.theme.textTheme.titleMedium,
          ),
          onPressed: () {
            if (nameController.value.text.isEmpty) return;
            widget.callback(nameController.value.text);
            context.navigator.pop();
          },
        ),
        const Divider(
          color: Colors.black,
          thickness: 2,
        ),
        SimpleDialogOption(
          child: Text(
            "Cancel",
            style: context.theme.textTheme.titleMedium?.copyWith(
                color: Colors.red
            ),
          ),
          onPressed: () {
            widget.callback(null);
            context.navigator.pop();
          },
        ),
      ],
    );
  }
}
