import 'package:alleat/screens/setupverification.dart';
import 'package:alleat/widgets/navigationbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alleat/theme/theme.dart' as globals;

void main() {
  //Start App
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  Future getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final int? appTheme = prefs.getInt('appTheme');
    globals.appthemepreference = appTheme;
  }

  @override
  Widget build(BuildContext context) {
    getTheme();
    return const MaterialApp(
      //Create main app
      title: 'AllEat.',
      home:
          Navigation(), //SetupWrapper(), //Check if setup is complete for app (reference)
    );
  }
}
