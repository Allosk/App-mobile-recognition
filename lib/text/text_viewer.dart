import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/text_recognition.dart';


class TextViewer extends StatelessWidget {
  const TextViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<TextRecognition>(builder:(controller) {
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