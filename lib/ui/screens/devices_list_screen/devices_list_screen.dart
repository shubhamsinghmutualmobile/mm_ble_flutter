import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:mm_ble/models/device_state.dart';
import 'package:mm_ble/ui/screens/device_details_screen/device_details_screen.dart';
import 'package:mm_ble/utils/text_utils.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<ScanResult> listOfDevices = [];
  DeviceState currentDeviceState = DeviceState("", false);
  late StreamSubscription<BluetoothDeviceState> subscription;

  scan() {
    flutterBlue.startScan();
    flutterBlue.scanResults.listen((devices) {
      listOfDevices = devices;
      setState(() {});
    });
  }

  @override
  void initState() {
    scan();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("List of devices nearby:"),
                    SizedBox(
                        width: 24,
                        height: 24,
                        child: StreamBuilder(
                            stream: flutterBlue.isScanning,
                            builder: (BuildContext context,
                                AsyncSnapshot<bool> _isScanning) {
                              if (_isScanning.requireData) {
                                return const CircularProgressIndicator(
                                    strokeWidth: 2);
                              } else {
                                return const SizedBox();
                              }
                            }))
                  ],
                ),
              ),
              Column(
                children: listOfDevices.map((device) {
                  return Card(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              getDeviceNameOrId(device, context),
                              const SizedBox(height: 8),
                              Text(device.device.id.id),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: InkWell(
                            customBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            onTap: () {
                              flutterBlue.stopScan();
                              device.device.connect();
                              setState(() {
                                currentDeviceState =
                                    DeviceState(device.device.id.id, true);
                              });
                              subscription =
                                  device.device.state.listen((connectionState) {
                                if (connectionState ==
                                    BluetoothDeviceState.connected) {
                                  subscription.cancel();
                                  setState(() {
                                    currentDeviceState =
                                        DeviceState(device.device.id.id, false);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                DeviceDetailsScreen(
                                                    device, scan)));
                                    return;
                                  });
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _deviceLoadingWidget(device),
                            ),
                          ),
                        )
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deviceLoadingWidget(ScanResult device) {
    if (device.device.id.id == currentDeviceState.uuid &&
        currentDeviceState.isConnecting) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(height: 8),
          Text("Connecting...")
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Icon(Icons.arrow_forward),
          SizedBox(height: 8),
          Text("Connect")
        ],
      );
    }
  }
}
