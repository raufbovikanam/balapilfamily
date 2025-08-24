import 'dart:convert';
import 'package:flutter/material.dart';

class FullImageScreen extends StatelessWidget {
  final String photoBase64;

  const FullImageScreen({super.key, required this.photoBase64});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.yellowAccent), // icon color yellow
        titleTextStyle: const TextStyle(color: Colors.yellowAccent, fontSize: 20), // optional title text
      ),
      body: Center(
        child: Image.memory(
          base64Decode(photoBase64),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
