import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  ThemeData get theme {
    return Theme.of(this);
  }

  ColorScheme get colorScheme {
    return theme.colorScheme;
  }

  TextTheme get textTheme {
    return theme.textTheme;
  }

  NavigatorState get navigator {
    return Navigator.of(this);
  }

  ScaffoldMessengerState get messenger {
    return ScaffoldMessenger.of(this);
  }

  void showSnackBar(String message, Color color) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
                color: Colors.white
            ),
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
        )
    );
  }

  void pushNamedAndRemove(String routeName, {Object? arguments}) {
    navigator.pushNamedAndRemoveUntil(routeName, (_) => false, arguments: arguments);
  }

  Future pushNamed(String routeName, {Object? arguments}) {
    return navigator.pushNamed(routeName, arguments: arguments);
  }
}