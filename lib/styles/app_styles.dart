import 'package:flutter/material.dart';

class AppStyles {
  static const Color primaryColor = Color.fromARGB(122, 28, 96, 173);
  static const Color deleteColor = Colors.red;
  static const Color addColor = Color.fromARGB(122, 28, 96, 173);

  static final List<Color> cardColors = [
    const Color.fromARGB(255, 149, 194, 241),
    const Color.fromARGB(254, 95, 136, 224),
  ];

  static const TextStyle contactTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle contactContent = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );
  static const TextStyle emptyText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.black54,
  );
}
