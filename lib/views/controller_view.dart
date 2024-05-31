import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';
import '../robot.dart';

class MyJoystickStick extends StatelessWidget {
  final double size;
  final Color color;

  const MyJoystickStick(this.size, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class ControllerView extends StatefulWidget {
  static const Duration motorControlUpdateInterval =
      Duration(milliseconds: 100);
  static const Duration batteryLevelUpdateInterval = Duration(seconds: 5);
  final Robot robot;
  final void Function(int)? onBatteryLevelUpdate;
  const ControllerView(this.robot, {this.onBatteryLevelUpdate, super.key});

  @override
  State<ControllerView> createState() => _ControllerViewState();
}

class _ControllerViewState extends State<ControllerView> {
  static Widget joystickStick = MyJoystickStick(50.0, Colors.teal.shade300);
  late Timer motorControlUpdateTimer, batteryLevelUpdateTimer;
  late BluetoothCharacteristic remoteControllerChar;
  int x = 0, y = 0;

  Future<void> readBatteryLevel() async {
    var batteryLevel = await widget.robot.readBatteryLevel();
    if (widget.onBatteryLevelUpdate != null) {
      widget.onBatteryLevelUpdate!(batteryLevel);
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    // Read battery
    readBatteryLevel();
    // Start timers
    motorControlUpdateTimer = Timer.periodic(
        ControllerView.motorControlUpdateInterval, (timer) async {
      widget.robot.sendXY(x, y);
    });
    batteryLevelUpdateTimer = Timer.periodic(
        ControllerView.batteryLevelUpdateInterval, (timer) async {
      readBatteryLevel();
    });
  }

  @override
  void dispose() {
    motorControlUpdateTimer.cancel();
    batteryLevelUpdateTimer.cancel();
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
              stick: joystickStick,
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
              stick: joystickStick,
            ),
          ),
        ],
      ),
    );
  }
}
