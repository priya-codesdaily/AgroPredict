import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const AgroPredictApp());
}

class AgroPredictApp extends StatelessWidget {
  const AgroPredictApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AgroPredict',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A1628),
      ),
      home: const HomeScreen(),
    );
  }
}