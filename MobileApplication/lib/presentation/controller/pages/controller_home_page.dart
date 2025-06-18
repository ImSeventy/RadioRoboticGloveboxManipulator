import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:rrgbm/presentation/controller/pages/automation.dart';
import 'package:rrgbm/presentation/controller/pages/controller.dart';
import '../widgets/navigation_bar.dart';

class ControllerHomePageArgs {
  final BluetoothDevice server;

  ControllerHomePageArgs(this.server);
}

class ControllerHomePage extends StatefulWidget {
  final BluetoothDevice server;
  const ControllerHomePage({Key? key, required this.server}) : super(key: key);

  @override
  State<ControllerHomePage> createState() => _ControllerHomePageState();
}

class _ControllerHomePageState extends State<ControllerHomePage> {
  int _currentPageIndex = 0;
  String lastMessage = "";
  BluetoothConnection? connection;

  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);
  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    bluetoothConnect();
  }

  void bluetoothConnect() {
    BluetoothConnection.toAddress(widget.server.address).then((conn) {
      connection = conn;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen((_) {}).onDone(() {
        Future.delayed(const Duration(seconds: 5)).then((_) {
          if (mounted) {
            bluetoothConnect();
          }
        });
        if (mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      Future.delayed(const Duration(seconds: 5)).then((_) {
        if (mounted) {
          bluetoothConnect();
        }
      });
    }
    );
  }

  @override
  void dispose() {
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    super.dispose();
  }

  void _changePageIndex(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  void _sendMessage(String text) async {
    text = text.trim();
    if (text.isNotEmpty) {
      if (text == lastMessage) return;
      lastMessage = text;
      log(text);
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode("$text\n")));
        await connection!.output.allSent;
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ShopNavigationBar(
        onIndexChange: _changePageIndex,
      ),
      body: IndexedStack(
        index: _currentPageIndex,
        children: [
          ControllerPage(
            sendMessageFunction: _sendMessage,
            isConnected: isConnected,
            isConnecting: isConnecting,
          ),
          AutomationPage(
            sendMessageFunction: _sendMessage,
            isConnecting: isConnecting,
            isConnected: isConnected,
          )
        ],
      ),
    );
  }
}
