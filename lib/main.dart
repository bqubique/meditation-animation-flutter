import 'package:flutter/material.dart';

import 'features/meditation_screen/meditation_screen.dart';

void main() {
  runApp(
    MaterialApp(
      home: const MeditationScreen(),
      themeMode: ThemeMode.dark,
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
