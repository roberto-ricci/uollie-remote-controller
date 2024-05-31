import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';
import './views/connect_view.dart';
import './views/controller_view.dart';
import 'package:logging/logging.dart';
import './robot.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uollie - Remote Controller',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Robot? robot;
  bool isLoading = false;
  static final logger = Logger('Home');
  int batteryLevel = 100;

  static Icon getBatteryIcon(int level) {
    List<IconData> iconDataList = [
      Icons.battery_0_bar,
      Icons.battery_1_bar,
      Icons.battery_2_bar,
      Icons.battery_3_bar,
      Icons.battery_4_bar,
      Icons.battery_5_bar,
      Icons.battery_6_bar,
      Icons.battery_full
    ];
    int index = ((level / (100.0 / (iconDataList.length - 1))) + 0.5).floor();
    return Icon(iconDataList[index]);
  }

  void onBatteryLevelUpdate(int level) {
    setState(() {
      batteryLevel = level;
    });
  }

  void onDeviceSelected(BluetoothDevice device) async {
    setState(() {
      isLoading = true;
    });
    try {
      robot = await Robot.connect(device);
      device.connected.listen((connected) {
        if (!connected) {
          setState(() {
            robot = null;
          });
        }
      });
      setState(() {
        // Force a refresh
      });
    } catch (e) {
      logger.severe(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool get isConnected => robot != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset("assets/images/Icon-512.png"),
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Uollie"),
          actions: isConnected
              ? [
                  Text("$batteryLevel%"),
                  getBatteryIcon(batteryLevel),
                  IconButton(
                      onPressed: () {
                        robot!.device.disconnect();
                        setState(() {
                          robot = null;
                        });
                      },
                      icon: const Icon(Icons.link_off))
                ]
              : [],
        ),
        body: isConnected
            ? ControllerView(robot!, onBatteryLevelUpdate: onBatteryLevelUpdate)
            : (isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                    strokeWidth: 6.0,
                  ))
                : ConnectView(onDeviceSelected)));
  }
}
