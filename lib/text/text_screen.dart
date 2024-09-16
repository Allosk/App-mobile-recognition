import 'package:myapp/text/scan_text.dart';
import 'package:myapp/text/text1_button.dart';
import 'package:flutter/material.dart';
import 'package:myapp/text/text_viewer.dart';



class TextScreen extends StatelessWidget {
  const TextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return Stack(
      alignment: Alignment.center,
      children: const [
        TextViewer(),
        ScanText(),
        Textbutton()
      ],
    );
  }
}