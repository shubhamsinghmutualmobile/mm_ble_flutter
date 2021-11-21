import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<ScanResult> listOfDevices = [];

  scan() {
    listOfDevices.clear();
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
                  children: const [
                    Text("List of devices nearby:"),
                    SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ))
                  ],
                ),
              ),
              Column(
                children: listOfDevices
                    .map((device) => Card(
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
                          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [
                                Icon(
                                    Icons.arrow_forward_outlined),
                                SizedBox(height: 8),
                                Text("Connect")
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Text getDeviceNameOrId(ScanResult device, BuildContext context) {
    String currentText;
    if (device.device.name.isNotEmpty) {
      currentText = device.device.name;
    } else {
      currentText = device.device.id.id;
    }
    return Text(
      currentText,
      style: Theme.of(context).textTheme.headline6,
    );
  }
}