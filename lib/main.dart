import 'package:flutter/material.dart';
import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';
import './views/connect_view.dart';
import './views/controller_view.dart';
import 'package:logging/logging.dart';

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
  BluetoothDevice? device;
  bool isLoading = false;
  static final logger = Logger('Home');

  void onDeviceSelected(BluetoothDevice device) async {
    setState(() {
      isLoading = true;
    });
    try {
      await device.connect();
      device.connected.listen((connected) {
        if(!connected) {
          setState(() {
            this.device = null;
          });
        }
      });
    setState(() {
      this.device = device;
    });
    } catch(e) {
      logger.severe(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool get isConnected => device != null; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset("assets/images/Icon-512.png"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Uollie"),
        actions: isConnected ? [IconButton(onPressed: () {
          device!.disconnect();
          setState(() {
            device = null;
          });
        }, icon: const Icon(Icons.link_off))]: [],
      ),
      body: isConnected ? ControllerView(device!) : (isLoading ? const Center(child: CircularProgressIndicator(strokeWidth: 6.0,)) : ConnectView(onDeviceSelected))
    );
  }
}
