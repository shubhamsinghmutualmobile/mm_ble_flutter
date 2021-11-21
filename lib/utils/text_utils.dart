import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

Text getDeviceNameOrId(ScanResult device, BuildContext context,
    {String appendText = "", String prependText = ""}) {
  String currentText;
  if (device.device.name.isNotEmpty) {
    currentText = device.device.name;
  } else {
    currentText = device.device.id.id;
  }
  return Text(
    prependText + currentText + appendText,
    style: Theme.of(context).textTheme.headline6,
  );
}
