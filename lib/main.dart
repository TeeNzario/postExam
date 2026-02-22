import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'แจ้งเหตุทุจริตเลือกตั้ง',
      theme: ThemeData(
        primaryColor: const Color(0xFFF86261),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF86261)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
