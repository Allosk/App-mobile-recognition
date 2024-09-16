import 'package:get/instance_manager.dart';
import 'package:myapp/scan_controller.dart';
import 'package:myapp/text_recognition.dart';

class GlobalBindings extends Bindings{

  @override
  void dependencies(){
    Get.lazyPut<ScanController>(() => ScanController());
    Get.lazyPut<TextRecognition>(() => TextRecognition());
  }
}