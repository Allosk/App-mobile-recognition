import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/text_recognition.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class Textbutton extends StatefulWidget {
  const Textbutton({super.key});

  @override
  _TextbuttonState createState() => _TextbuttonState();
}

class _TextbuttonState extends State<Textbutton> {
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
    await flutterTts.setLanguage("ru-RU");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(
      "Для начала распознавания текста скажите, тЕкст. "
      "Для повтора инструкции скажите, повтор."
    );
    flutterTts.setCompletionHandler(() {
      _startListening();
    });
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) {
        print('onError: $val');
        _speakError();
      },
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
    } else {
      print('Speech recognition is not available');
    }
  }

  void _handleVoiceCommand(String command) {
    if (command.toLowerCase().contains('текст')) {
      Get.find<TextRecognition>().capture();
    } else if (command.toLowerCase().contains('повтор')) {
      _speakInstructions();
    } else {
      flutterTts.speak("Команда не распознана. Повторите, пожалуйста.");
      flutterTts.setCompletionHandler(_startListening);
    }
  }

  Future<void> _speakError() async {
    await flutterTts.speak("Произошла ошибка. Пожалуйста, повторите команду.");
    flutterTts.setCompletionHandler(_startListening);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 1,
      child: GestureDetector(
        onTap: () => Get.find<TextRecognition>().capture(),
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
