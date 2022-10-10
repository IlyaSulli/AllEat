import 'package:alleat/screens/wrapper.dart';
import 'package:flutter/material.dart';

void main() {
  //Start App
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      //Create main app
      title: 'AllEat.',
      home: SetupWrapper(), //Check if setup is complete for app (reference)
    );
  }
}
