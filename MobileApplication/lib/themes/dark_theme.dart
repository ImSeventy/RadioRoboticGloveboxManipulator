import 'package:flutter/material.dart';

class DarkThemeWrapper extends StatelessWidget {
  final Widget child;
  const DarkThemeWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      child: child,
    );
  }
}
