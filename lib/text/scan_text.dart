import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/text_recognition.dart';

class ScanText extends GetView<TextRecognition> {
  const ScanText({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          Positioned(
            top: 550,
            left: 20,
            child: Container(
              width: 350,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height - 700,
              ),
              padding: const EdgeInsets.all(5),
              color: const Color.fromARGB(137, 216, 216, 216),
              child: Obx(() {
                return SingleChildScrollView(
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 20,
                      height: 1.5,
                    ),
                    child: Text(
                      controller.recognizedText, // Отображение распознанного текста
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      );
  }
}
