import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/camera/camera_screen.dart';
import 'package:myapp/global_bindings.dart';
import 'package:myapp/text/text_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      title: "CameraApp",
      initialBinding: GlobalBindings(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _speakInstructions();
  }

Future<void> _speakInstructions() async {
  // Установка языка для озвучивания инструкций на русский
  await _flutterTts.setLanguage("ru-RU");
  // Установка скорости речи
  await _flutterTts.setSpeechRate(0.5);
  // Озвучивание инструкций пользователю
  await _flutterTts.speak(
    "Для включения распознавания объекта скажите 'распознавание объекта'. "
    "Для включения распознавания текста скажите 'распознавание текста'. "
    "Для повтора инструкции скажите 'повтор'."
  );
  // Установка обработчика завершения озвучивания
  _flutterTts.setCompletionHandler(() {
    _startListening();
  });
}

void _startListening() async {
  bool available = await _speech.initialize(
    onStatus: (val) => print('onStatus: $val'),
    onError: (val) => print('onError: $val'),
  );

  if (available) {
    setState(() => _isListening = true);
    _speech.listen(
      onResult: (val) => setState(() {
        _recognizedText = val.recognizedWords;
        if (val.finalResult) {
          _handleVoiceCommand(_recognizedText);
        }
      }),
      localeId: 'ru_RU',
    );
  }
}

void _handleVoiceCommand(String command) {
  // Обработка команды, распознанной из речи
  if (command.toLowerCase().contains('распознавание объектов')) {
    // Переход к экрану камеры
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    );
  } else if (command.toLowerCase().contains('распознавание текста')) {
    // Переход к экрану текста
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TextScreen()),
    );
  } else if (command.toLowerCase().contains('повтор')) {
    // Повторение инструкций
    _speakInstructions();
  } else {
    // Если команда не распознана, просим повторить
    _flutterTts.speak("Команда не распознана. Повторите, пожалуйста.");
    // Установка обработчика завершения озвучивания для продолжения прослушивания
    _flutterTts.setCompletionHandler(_startListening);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RecogN',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            fontSize: 36,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      backgroundColor: Color.fromARGB(255, 49, 49, 49),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 340,
              height: 340,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CameraScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Color.fromARGB(255, 255, 255, 255),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Распознавание объектов',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 42,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: 340,
              height: 340,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TextScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Color.fromARGB(255, 255, 255, 255),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Распознавание текста',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 43,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
