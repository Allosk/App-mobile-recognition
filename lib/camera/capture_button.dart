import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/scan_controller.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class CaptureButton extends StatefulWidget {
  const CaptureButton({super.key});

  @override
  _CaptureButtonState createState() => _CaptureButtonState();
}

class _CaptureButtonState extends State<CaptureButton> {
  late stt.SpeechToText _speech;
  late FlutterTts flutterTts;
  bool _isListening = false;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    flutterTts = FlutterTts();
    _speakInstructions();
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

Future<void> _speakInstructions() async {
  // Установка языка для озвучивания инструкций на русский
  await flutterTts.setLanguage("ru-RU");
  // Установка скорости речи
  await flutterTts.setSpeechRate(0.5);
  // Озвучивание инструкций пользователю
  await flutterTts.speak(
    "Для начала распознавания объекта скажите, объект. "
    "Для повтора инструкции скажите 'повтор'."
  );
  // Установка обработчика завершения озвучивания
  flutterTts.setCompletionHandler(() {
    _startListening();
  });
}

void _startListening() async {
  // Проверка доступности распознавания речи
  bool available = await _speech.initialize(
    onStatus: (val) => print('onStatus: $val'),
    onError: (val) => print('onError: $val'),
  );

  if (available) {
    // Установка флага прослушивания
    setState(() => _isListening = true);
    // Начало прослушивания с указанием обработчика результата
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
  if (command.toLowerCase().contains('объект')) {
    Get.find<ScanController>().capture();
  } else if (command.toLowerCase().contains('повтор')) {
    // Повторение инструкций
    _speakInstructions();
  } else {
    // Если команда не распознана, просим повторить
    flutterTts.speak("Команда не распознана. Повторите, пожалуйста.");
    // Установка обработчика завершения озвучивания для продолжения прослушивания
    flutterTts.setCompletionHandler(_startListening);
  }
}


  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 1,
      child: GestureDetector(
        onTap: () => Get.find<ScanController>().capture(),
        child: Container(
          height: 120,
          width: 391,
          padding: const EdgeInsets.all(0),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.rectangle,
            ),
            child: const Center(
              child: Icon(
                Icons.camera,
                size: 60,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
