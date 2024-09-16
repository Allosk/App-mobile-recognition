import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:path_provider/path_provider.dart';

class TextRecognition extends GetxController {
  final RxBool __isInitialized = RxBool(false);
  late CameraController __cameraController;
  late List<CameraDescription> __cameras;
  CameraImage? __cameraImage;
  final RxList<Uint8List> __imageList = RxList([]);
  final FlutterTts _flutterTts = FlutterTts();
  final RxString _recognizedText = ''.obs; // Добавленная строка

  List<Uint8List> get imageList => __imageList;
  bool get isInitialized => __isInitialized.value;
  CameraController get cameraController => __cameraController;
  String get recognizedText => _recognizedText.value; // Добавленный геттер

  @override
  void dispose() {
    __isInitialized.value = false;
    __cameraController.stopImageStream();
    __cameraController.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    try {
      __cameras = await availableCameras();
      __cameraController = CameraController(__cameras[0], ResolutionPreset.high);
      await __cameraController.initialize();
      __isInitialized.value = true;
      __cameraController.startImageStream((image) {
        __cameraImage = image;
      });
    } catch (e) {
      print("Camera initialization error: $e");
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initCamera();
  }

Future<void> _recognizeText(CameraImage cameraImage) async {
  try {
    // Преобразование изображения в формат JPEG
    final img.Image image = _convertYUV420toImage(cameraImage);
    Uint8List jpeg = Uint8List.fromList(img.encodeJpg(image));

    // Получение временного каталога и сохранение изображения
    final directory = await getTemporaryDirectory();
    final imagePath = '${directory.path}/temp_image.jpg';
    final imageFile = File(imagePath);
    await imageFile.writeAsBytes(jpeg);

    // Распознавание текста на изображении
    String recognizedText = await FlutterTesseractOcr.extractText(
      imagePath,
      language: 'rus', // Установка языка распознавания
    );

    // Удаление пустых строк из распознанного текста
    List<String> lines = recognizedText.split('\n');
    lines.removeWhere((line) => line.trim().isEmpty);
    String cleanedText = lines.join('\n');

    // Обновление распознанного текста и озвучивание его
    _recognizedText.value = cleanedText;
    print(cleanedText);
    _flutterTts.speak(cleanedText);
  } catch (e) {
    // Обработка ошибок при распознавании текста
    print("Error recognizing text: $e");
  }
}


  void capture() {
    if (__cameraImage != null && __cameraImage!.planes.length == 3) {
      final img.Image image = _convertYUV420toImage(__cameraImage!);
      Uint8List jpeg = Uint8List.fromList(img.encodeJpg(image));
      __imageList.add(jpeg);
      __imageList.refresh();
      _recognizeText(__cameraImage!);
    }
  }

  img.Image _convertYUV420toImage(CameraImage cameraImage) {
    final int width = cameraImage.width;
    final int height = cameraImage.height;
    final int uvRowStride = cameraImage.planes[1].bytesPerRow;
    final int uvPixelStride = cameraImage.planes[1].bytesPerPixel!;
    final img.Image imgBuffer = img.Image(width, height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex = uvPixelStride * (x >> 1) + uvRowStride * (y >> 1);
        final int index = y * width + x;

        final int yValue = cameraImage.planes[0].bytes[index];
        final int uValue = cameraImage.planes[1].bytes[uvIndex];
        final int vValue = cameraImage.planes[2].bytes[uvIndex];

        final int r = (yValue + (1.370705 * (vValue - 128))).toInt();
        final int g = (yValue - (0.337633 * (uValue - 128)) - (0.698001 * (vValue - 128))).toInt();
        final int b = (yValue + (1.732446 * (uValue - 128))).toInt();

        imgBuffer.setPixel(x, y, img.getColor(
          _clamp(r, 0, 255),
          _clamp(g, 0, 255),
          _clamp(b, 0, 255),
        ));
      }
    }
    return img.copyRotate(imgBuffer, 90);
  }

  int _clamp(int value, int min, int max) {
    return value < min ? min : (value > max ? max : value);
  }
}
