import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/scan_controller.dart';


class ScanPage extends GetView<ScanController> {
  const ScanPage({super.key});
  

  @override
Widget build(BuildContext context) {
  return Stack(
    children: [
      // Позиционирование контейнера
      Positioned(
        top: 650, // Расположение контейнера от верхнего края
        left: 50, // Расположение контейнера от левого края
        child: Container(
          width: 300, // Ширина контейнера
          constraints: BoxConstraints(
            // Ограничение по высоте, чтобы не выйти за границы экрана
            maxHeight: MediaQuery.of(context).size.height - 700,
          ),
          padding: const EdgeInsets.all(5), // Внутренние отступы контейнера
          color: const Color.fromARGB(137, 216, 216, 216), // Цвет фона контейнера
          child: Obx(() {
            // Использование Obx для отслеживания изменений в контроллере
            return SingleChildScrollView(
              // Скролл виджет для прокрутки текста, если он превышает высоту контейнера
              child: DefaultTextStyle(
                // Установка стилей текста по умолчанию
                style: const TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0), // Цвет текста - черный
                  fontSize: 20, // Размер шрифта текста
                  height: 1.5, // Высота строки текста
                ),
                child: Column(
                  // Колонка для размещения текстовых виджетов
                  crossAxisAlignment: CrossAxisAlignment.center, // Центрирование элементов по горизонтали
                  children: controller.recognizedObjects.map((obj) {
                    // Итерация по распознанным объектам
                    controller.flutterTts.speak(obj); // Озвучивание каждого объекта
                    return Text(
                      obj, // Отображение текста распознанного объекта
                    );
                  }).toList(),
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
