import 'package:myapp/camera/camera_viewer.dart';
import 'package:myapp/camera/capture_button.dart';
import 'package:flutter/material.dart';
import 'package:myapp/camera/scan_page.dart';
import 'package:myapp/camera/top_image_viewer.dart';


class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});


  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return Stack(
      alignment: Alignment.center,
      children: const [
        CameraViewer(),
        ScanPage(),
        CaptureButton(),
        TopImageViewer()

      ],
    );
  }
}