import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

dynamic kWidth;
dynamic kHeight;
List<CameraDescription>? cameras;

String noImage = "assets/images/no_image.png";

recognitionResult(recognition) {
  double confidence = (recognition['confidence'] * 100);
  var label = recognition['label'].split("_").join(" ");
  return "$label (${confidence.roundToDouble()}%)";
}
// With_Mask ----> [With,Mask] --> With Mask (100%)
// {confidence: 1.0, index: 0, label: With_Mask}

checkPermissions(context) async {
  var cameraStatus = await Permission.camera.status;
  if (cameraStatus.isDenied) {
    await Permission.camera.request();
  }
}
