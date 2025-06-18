import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:rrgbm/presentation/Connection/pages/select_boned_device_page.dart';
import 'package:rrgbm/presentation/shared/extensions/context_extensions.dart';

import '../../../router/routes.dart';
import '../../controller/pages/controller_home_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPage createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  Timer? _discoverableTimeoutTimer;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 0xDD));
      return true;
    });

    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        _discoverableTimeoutTimer = null;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: context.colorScheme.primary,
          centerTitle: true,
          title: const Text('RRGBM Controller'),
          titleTextStyle: context.textTheme.headlineMedium?.copyWith(
              color: context.colorScheme.onPrimary,
              fontWeight: FontWeight.bold),
        ),
        body: ListView(
          children: <Widget>[
            SwitchListTile(
              title: const Text('Enable Bluetooth'),
              value: _bluetoothState.isEnabled,
              onChanged: (bool value) {
                changeRequest() async {
                  if (value) {
                    await FlutterBluetoothSerial.instance.requestEnable();
                  } else {
                    await FlutterBluetoothSerial.instance.requestDisable();
                  }
                }

                changeRequest().then((_) {
                  setState(() {});
                });
              },
            ),
            ListTile(
              title: const Text('Bluetooth status'),
              subtitle: Text(_getBluetoothState()),
              trailing: ElevatedButton(
                child: const Text('Settings'),
                onPressed: () {
                  FlutterBluetoothSerial.instance.openSettings();
                },
              ),
            ),
            ListTile(
              title: ElevatedButton(
                child: const Text('Connect to GloveBox'),
                onPressed: () async {
                  final BluetoothDevice? selectedDevice =
                      await context.pushNamed(Routes.selectBondedDevice,
                          arguments: SelectBondedDevicePageArgs(true));

                  if (selectedDevice == null || !context.mounted) {
                    return;
                  }

                  _startChat(context, selectedDevice);
                },
              ),
            ),
          ],
        ));
  }

  void _startChat(BuildContext context, BluetoothDevice server) {
    context.pushNamed(
      Routes.controller,
      arguments: ControllerHomePageArgs(
        server,
      ),
    );
  }

  String _getBluetoothState() {
    switch (_bluetoothState) {
      case BluetoothState.UNKNOWN:
        return "UnKnown";
      case BluetoothState.STATE_ON:
        return "ON";
      case BluetoothState.STATE_OFF:
        return "OFF";
      default:
        return _bluetoothState.stringValue;
    }
  }
}
