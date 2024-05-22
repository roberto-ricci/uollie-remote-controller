import 'package:flutter/material.dart';
import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';
import 'package:flutter_web_bluetooth/js_web_bluetooth.dart';

class ConnectView extends StatelessWidget {
  static const String deviceName = "Uollie";
  static const String remoteControllerService = "00001523-1212-efde-1523-785feabcd123";
  final void Function(BluetoothDevice device) onDeviceSelected;

  const ConnectView(this.onDeviceSelected, {super.key});

  Future<void> requestDevice() async {
    // Define the services you want to communicate with here!
    // Define the services you want to communicate with here!
final requestOptions = RequestOptionsBuilder([RequestFilterBuilder(name: deviceName, services: [BluetoothDefaultServiceUUIDS.battery.uuid, remoteControllerService])]);

    try {
      final device = await FlutterWebBluetooth.instance.requestDevice(requestOptions);
      onDeviceSelected(device);
    } on UserCancelledDialogError {
      print("user cancelled");
    } on DeviceNotFoundError {
      // There is no device in range for the options defined above
      print("device not found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: ElevatedButton(onPressed: () => requestDevice(), child: const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text("Connect", textScaler: TextScaler.linear(1.5),),
    )),);
  }
}