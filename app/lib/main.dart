import 'package:flutter/material.dart';

void main() {
  runApp(const SmartIDApp());
}

class SmartIDApp extends StatelessWidget {
  const SmartIDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Godam Lah - Smart ID',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Smart ID Project Start!'),
        ),
      ),
    );
  }
}