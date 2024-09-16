import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../scan_controller.dart';


class CameraViewer extends StatelessWidget {
  const CameraViewer({super.key});


  @override
  Widget build(BuildContext context) {
    return GetX<ScanController>(builder:(controller) {
      if (!controller.isInitialized) {
        return Container();
      }
      return Stack(
        children: [
          SizedBox(
            height: Get.height,
            width: Get.width,
            child: CameraPreview(controller.cameraController),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 120, // Высота черной полосы
              color: Color.fromARGB(255, 255, 255, 255),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 20), // Добавление отступа слева
                  SizedBox(width: 20), // Добавление отступа справа
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}