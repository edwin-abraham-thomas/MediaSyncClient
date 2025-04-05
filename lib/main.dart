import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'media_controller.dart';
import 'media_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MediaController(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Control POC',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MediaScreen(),
    );
  }
}
