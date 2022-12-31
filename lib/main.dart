import 'package:alleat/screens/setupverification.dart';
import 'package:flutter/services.dart';
import 'package:alleat/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alleat/theme/theme.dart' as globals;

void main() {
  //Start App
  runApp(
    const MyApp(),
  );
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
    SystemChrome.setPreferredOrientations([
      //Force portrait mode
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsFlutterBinding.ensureInitialized();
    getTheme();
    switch (globals.appthemepreference) {
      case 1:
        return MaterialApp(
          //Create main app
          title: 'AllEat.',
          themeMode: ThemeMode.light,
          theme: ThemeClass.lightTheme,
          home:
              const SetupWrapper(), //SetupWrapper(), //Check if setup is complete for app (reference)
        );
      case 2:
        return MaterialApp(
          //Create main app
          title: 'AllEat.',
          themeMode: ThemeMode.dark,
          theme: ThemeClass.darkTheme,
          home:
              const SetupWrapper(), //SetupWrapper(), //Check if setup is complete for app (reference)
        );
    }
    return MaterialApp(
      //Create main app
      title: 'AllEat.',
      themeMode: ThemeMode.system,
      theme: ThemeClass.lightTheme,
      darkTheme: ThemeClass.darkTheme,
      home:
          const SetupWrapper(), //SetupWrapper(), //Check if setup is complete for app (reference)
    );
  }
}
