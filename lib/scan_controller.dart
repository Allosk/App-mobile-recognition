import 'dart:typed_data';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';


class ScanController extends GetxController {
  final RxBool _isInitialized = RxBool(false);
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  CameraImage? _cameraImage; // Обновлено для работы с null
  final RxList<Uint8List> _imageList = RxList([]);
  final RxList<String> _recognizedObjects = RxList([]); // Добавлено для распознанных объектов
  bool _isInterpreterBusy = false; // Добавлено для проверки состояния интерпретатора
  final FlutterTts flutterTts = FlutterTts();
  final translator = GoogleTranslator();

  List<Uint8List> get imageList => _imageList;
  List<String> get recognizedObjects => _recognizedObjects; // Геттер для распознанных объектов
  bool get isInitialized => _isInitialized.value;
  CameraController get cameraController => _cameraController;


  @override
  void dispose() {
    _isInitialized.value = false;
    _cameraController.dispose();
    _cameraController.stopImageStream();
    flutterTts.stop();    
    Tflite.close();
    super.dispose();
  }



Future<void> _initTensorFlow() async {
  // Загружаем модель TensorFlow Lite с указанными параметрами
  String? res = await Tflite.loadModel(
    model: "assets/model.tflite", // Путь к файлу модели .tflite
    labels: "assets/labels.txt", // Путь к файлу меток классов
    numThreads: 1, // Количество потоков для выполнения (по умолчанию 1)
    isAsset: true, // Использовать ли ресурсы из папки assets (по умолчанию true)
    useGpuDelegate: false // Использовать ли GPU для выполнения (по умолчанию false)
  );
}

Future<void> _initCamera() async {
  // Получаем список доступных камер на устройстве
  _cameras = await availableCameras();
  
  // Инициализируем контроллер камеры с использованием первой доступной камеры и установкой разрешения на высокое
  _cameraController = CameraController(_cameras[0], ResolutionPreset.high);

  // Инициализируем контроллер камеры
  _cameraController.initialize().then((_) {
    // Устанавливаем флаг, что камера инициализирована
    _isInitialized.value = true;

    // Запускаем поток изображений с камеры
    _cameraController.startImageStream((image) {
      // Сохраняем текущее изображение в переменную _cameraImage
      _cameraImage = image;
    });
  }).catchError((Object e) {
    // Обрабатываем возможные ошибки инициализации камеры
    if (e is CameraException) {
      switch (e.code) {
        case 'CameraAccessDenied':
          // Обработка ошибки отказа в доступе к камере
          // Здесь можно добавить уведомление пользователю или другую логику
          break;
        default:
          // Обработка других ошибок камеры
          // Здесь можно добавить уведомление пользователю или другую логику
          break;
      }
    }
  });
}

  @override
  void onInit() {
    _initCamera();
    _initTensorFlow();
    super.onInit();
  }

Future<void> _objectRecognition(CameraImage cameraImage) async {
  if (_isInterpreterBusy) {
    return; // Если интерпретатор занят, выход из функции
  }

  _isInterpreterBusy = true; // Установить флаг, что интерпретатор занят

  try {
    // Запуск модели на кадре из камеры
    var recognitions = await Tflite.runModelOnFrame(
      bytesList: cameraImage.planes.map((plane) {
        return plane.bytes;
      }).toList(), // Преобразование плоскостей изображения в список байтов
      imageHeight: cameraImage.height, // Высота изображения
      imageWidth: cameraImage.width, // Ширина изображения
      imageMean: 127.5, // Среднее значение для нормализации (по умолчанию 127.5)
      imageStd: 127.5, // Стандартное отклонение для нормализации (по умолчанию 127.5)
      rotation: 90, // Поворот изображения (по умолчанию 90, только для Android)
      numResults: 1, // Количество результатов (по умолчанию 5)
      threshold: 0.1, // Пороговое значение уверенности (по умолчанию 0.1)
      asynch: true // Асинхронное выполнение (по умолчанию true)
    );

    if (recognitions != null) {
      _recognizedObjects.clear(); // Очистить предыдущие распознавания
      for (var recognition in recognitions) {
        if (recognition['confidence'] > 0.7) { // Если уверенность больше 0.7
          String label = recognition['label']; // Метка объекта
          Translation translation = await translator.translate(label, from: 'en', to: 'ru'); // Перевод метки на русский
          String translatedLabel = translation.text;
          _recognizedObjects.add(translatedLabel); // Добавление переведенной метки в список
          print(label); // Вывод метки в консоль
        }
      }
    }
  } finally {
    _isInterpreterBusy = false; // Сбросить флаг после завершения работы
  }
}


void capture() {
  // Проверка наличия изображения и его формата
  if (_cameraImage != null && _cameraImage!.planes.length == 3) {
    // Предполагается, что формат изображения YUV
    final img.Image image = _convertYUV420toImage(_cameraImage!); // Преобразование формата изображения
    Uint8List jpeg = Uint8List.fromList(img.encodeJpg(image)); // Кодирование изображения в формат JPEG
    _imageList.add(jpeg); // Добавление изображения в список
    _imageList.refresh(); // Обновление списка изображений
    _objectRecognition(_cameraImage!); // Вызов метода распознавания объектов
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
          _clamp(b, 0, 255)
        ));
      }
    }
    return img.copyRotate(imgBuffer, 90); // Повернуть изображение при необходимости
  }

  int _clamp(int value, int min, int max) {
    return value < min ? min : (value > max ? max : value);
  }
}