import 'dart:typed_data';

import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';

class Robot {
  static const String remoteControlServiceUUID =
      "00001523-1212-efde-1523-785feabcd123";
  static const String remoteControlCharacteristicUUID =
      "00001524-1212-efde-1523-785feabcd123";
  static const String deviceName = "Uollie";
  static const String trimCharacteristicUUID =
      "00001525-1212-efde-1523-785feabcd123";

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

  Future<BluetoothCharacteristic> _trimCharacteristic() async {
    final services = await device.discoverServices();
    return services
        .firstWhere((service) => service.uuid == remoteControlServiceUUID)
        .getCharacteristic(trimCharacteristicUUID);
  }

  Future<List<int>> readTrim() async {
    final characteristic = await _trimCharacteristic();
    final data = await characteristic.readValue();
    if (data.lengthInBytes != 2 ||
        data.getUint8(0) > 100 || data.getUint8(1) > 100) {
      throw const FormatException('Invalid motor trim values');
    }
    return [data.getUint8(0), data.getUint8(1)];
  }

  Future<void> writeTrim(int left, int right) async {
    RangeError.checkValueInInterval(left, 0, 100, 'left');
    RangeError.checkValueInInterval(right, 0, 100, 'right');
    final characteristic = await _trimCharacteristic();
    await characteristic.writeValueWithResponse(Uint8List.fromList([left, right]));
  }
}
