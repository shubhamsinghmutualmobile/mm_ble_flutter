import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:mm_ble/utils/text_utils.dart';

class DeviceDetailsScreen extends StatefulWidget {
  final ScanResult device;
  final Function startListeningAgain;

  const DeviceDetailsScreen(this.device, this.startListeningAgain, {Key? key})
      : super(key: key);

  @override
  State<DeviceDetailsScreen> createState() => _DeviceDetailsScreenState();
}

class _DeviceDetailsScreenState extends State<DeviceDetailsScreen> {
  List<BluetoothService> deviceServices = [];

  scan() {
    widget.device.device.discoverServices();
    widget.device.device.isDiscoveringServices.listen((isListening) {
      print("Is listening to services? $isListening");
    });
    widget.device.device.services.listen((services) {
      deviceServices.clear();
      deviceServices = services;
      print("Services are: $deviceServices & $services");
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
        title:
            getDeviceNameOrId(widget.device, context, appendText: "'s details"),
      ),
      body: WillPopScope(
        onWillPop: () {
          return onBackPressed(widget.startListeningAgain);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getDeviceNameOrId(widget.device, context, prependText: "Name: "),
              const SizedBox(
                height: 8,
              ),
              Text("UUID: ${widget.device.device.id.id}"),
              const SizedBox(
                height: 8,
              ),
              Text("Device type: ${widget.device.device.type}"),
              const SizedBox(
                height: 8,
              ),
              Text("RSSI: ${widget.device.rssi}"),
              const SizedBox(
                height: 8,
              ),
              const Text("Services:"),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: deviceServices
                    .map((service) => Text(service.uuid.toString()))
                    .toList(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> onBackPressed(Function startListeningAgain) async {
    print("On back pressed called!");
    widget.device.device.disconnect();
    widget.device.device.state.listen((connectionState) {
      if(connectionState == BluetoothDeviceState.disconnected) {
        startListeningAgain();
      }
    });
    return true;
  }
}
