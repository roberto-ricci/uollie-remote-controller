import 'dart:typed_data';

import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';

class Robot {
  static const String remoteControlServiceUUID =
      "00001523-1212-efde-1523-785feabcd123";
  static const String remoteControlCharacteristicUUID =
      "00001524-1212-efde-1523-785feabcd123";
  static const String deviceName = "Uollie";

  final BluetoothDevice device;
  final BluetoothCharacteristic remoteControlCharacteristic;
  final BluetoothCharacteristic batteryLevelCharacteristic;

  Robot._internal(this.device, this.remoteControlCharacteristic,
      this.batteryLevelCharacteristic);

  static Future<Robot> connect(BluetoothDevice device) async {
    await device.connect();
    var services = await device.discoverServices();
    var remoteControlCharacteristic = await services
        .firstWhere((element) => element.uuid == remoteControlServiceUUID)
        .getCharacteristic(remoteControlCharacteristicUUID);
    var batteryLevelCharacteristic = await services
        .firstWhere((element) =>
            element.uuid == BluetoothDefaultServiceUUIDS.battery.uuid)
        .getCharacteristic(
            BluetoothDefaultCharacteristicUUIDS.batteryLevel.uuid);
    return Robot._internal(
        device, remoteControlCharacteristic, batteryLevelCharacteristic);
  }

  void sendXY(int x, int y) {
    remoteControlCharacteristic
        .writeValueWithoutResponse(Uint8List.fromList([x, y]));
  }

  Future<int> readBatteryLevel() async {
    var data = await batteryLevelCharacteristic.readValue();
    return data.getUint8(0);
  }
}
