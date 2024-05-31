import 'package:flutter/material.dart';
import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';
import 'package:flutter_web_bluetooth/js_web_bluetooth.dart';
import 'package:logging/logging.dart';
import '../robot.dart';

class ConnectView extends StatelessWidget {
  static final logger = Logger('ConnectView');
  final void Function(BluetoothDevice device) onDeviceSelected;

  const ConnectView(this.onDeviceSelected, {super.key});

  Future<void> requestDevice() async {
    final requestOptions = RequestOptionsBuilder([
      RequestFilterBuilder(name: Robot.deviceName, services: [
        BluetoothDefaultServiceUUIDS.battery.uuid,
        Robot.remoteControlServiceUUID
      ])
    ]);

    try {
      final device =
          await FlutterWebBluetooth.instance.requestDevice(requestOptions);
      onDeviceSelected(device);
    } on UserCancelledDialogError {
      logger.info("user cancelled");
    } on DeviceNotFoundError {
      logger.info("device not found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
          onPressed: () => requestDevice(),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Connect",
              textScaler: TextScaler.linear(1.5),
            ),
          )),
    );
  }
}
