import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BluetoothDeviceListEntry extends StatelessWidget {
  final BluetoothDevice device;
  int? rssi;
  GestureTapCallback? onTap;
  GestureLongPressCallback? onLongPress;
  bool enabled;


  BluetoothDeviceListEntry({Key? key, required this.device,
    this.rssi,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      onLongPress: enabled ? onLongPress : null,
      child: Card(
        margin: const EdgeInsets.only(top: 10, left: 5, right: 5),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          child: ListTile(

            leading: const Icon(Icons.devices),
            title: Text(device.name ?? ""),
            subtitle: Text(device.address.toString()),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                rssi != null
                    ? Container(
                  margin: const EdgeInsets.all(8.0),
                  child: DefaultTextStyle(
                    style: _computeTextStyle(rssi!),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(rssi.toString()),
                        const Text('dBm'),
                      ],
                    ),
                  ),
                )
                    : const SizedBox(),
                device.isConnected
                    ? const Icon(Icons.import_export)
                    : const SizedBox(),
                device.isBonded
                    ? const Icon(Icons.link)
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static TextStyle _computeTextStyle(int rssi) {
    /**/ if (rssi >= -35)
      return TextStyle(color: Colors.greenAccent[700]);
    else if (rssi >= -45)
      return TextStyle(
          color: Color.lerp(
              Colors.greenAccent[700], Colors.lightGreen, -(rssi + 35) / 10));
    else if (rssi >= -55)
      return TextStyle(
          color: Color.lerp(
              Colors.lightGreen, Colors.lime[600], -(rssi + 45) / 10));
    else if (rssi >= -65)
      return TextStyle(
          color: Color.lerp(Colors.lime[600], Colors.amber, -(rssi + 55) / 10));
    else if (rssi >= -75)
      return TextStyle(
          color: Color.lerp(
              Colors.amber, Colors.deepOrangeAccent, -(rssi + 65) / 10));
    else if (rssi >= -85)
      return TextStyle(
          color: Color.lerp(
              Colors.deepOrangeAccent, Colors.redAccent, -(rssi + 75) / 10));
    else
      /*code symmetry*/
      return TextStyle(color: Colors.redAccent);
  }
}


