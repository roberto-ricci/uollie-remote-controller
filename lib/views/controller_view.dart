import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';


class ControllerView extends StatefulWidget {
  final BluetoothDevice device;
  const ControllerView(this.device, {super.key});

  @override
  State<ControllerView> createState() => _ControllerViewState();
}

class _ControllerViewState extends State<ControllerView> {
  late Timer timer;
  late BluetoothCharacteristic remoteControllerChar;
  int x = 0, y = 0;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    // Find the characteristic and store if for future usage
    var services = await widget.device.discoverServices();
    remoteControllerChar = await services.firstWhere((element) => element.uuid == "myservice").getCharacteristic("");
        timer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      print("x=$x, y=$y");
      await remoteControllerChar.writeValueWithoutResponse(Uint8List.fromList([x,y]));
    });
  }

  @override
  void dispose() {
      timer.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: const Alignment(-0.8, 0),
              child: Joystick(
                mode: JoystickMode.vertical,
                listener: (details) {
                  setState(() {
                    x = (-details.y * 100).round();
                  });
                },
              ),
            ),
            Align(
              alignment: const Alignment(0.8, 0.0),
              child: Joystick(
                mode: JoystickMode.horizontal,
                listener: (details) {
                  setState(() {
                    y = (-details.x * 100).round();
                  });
                },
              ),
            ),
          ],
        ),);
  }
}