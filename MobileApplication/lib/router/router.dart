import 'package:flutter/material.dart';
import 'package:rrgbm/presentation/controller/pages/automation_process_page.dart';
import 'package:rrgbm/presentation/controller/pages/controller.dart';
import 'package:rrgbm/presentation/controller/pages/controller_home_page.dart';
import 'package:rrgbm/router/routes.dart';

import '../presentation/Connection/pages/home_page.dart';
import '../presentation/Connection/pages/select_boned_device_page.dart';
import '../themes/dark_theme.dart';

class AppRouter {
  static ThemeMode themeMode = ThemeMode.light;

  static Route? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    Widget? screen = getScreenFromRouteName(settings.name, args);
    if (screen == null) return null;

    return MaterialPageRoute(builder: (context) {
      return CurrentThemeWrapper(
        child: screen,
      );
    });
  }

  static Widget? getScreenFromRouteName(String? name, dynamic args) {
    switch (name) {
      case Routes.root:
        return const MainPage();
      case Routes.home:
        return const MainPage();
      case Routes.selectBondedDevice:
        return SelectBondedDevicePage(
          checkAvailability:
              (args as SelectBondedDevicePageArgs).checkAvailability,
        );
      case Routes.controller:
        return ControllerHomePage(
            server: (args as ControllerHomePageArgs).server);
      case Routes.processAutomation:
        ProcessAutomationPageArgs processArgs =
            (args as ProcessAutomationPageArgs);
        return ProcessAutomationPage(
          automationProcess: processArgs.automationProcess,
          sendMessageFunction: processArgs.sendMessageFunction,
          isConnecting: processArgs.isConnecting,
          isConnected: processArgs.isConnected,
        );
    }
  }
}

class CurrentThemeWrapper extends StatelessWidget {
  final Widget child;

  const CurrentThemeWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DarkThemeWrapper(child: child);
  }
}
