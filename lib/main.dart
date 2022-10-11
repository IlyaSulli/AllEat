import 'package:alleat/screens/profilesetup/profilesetup_login.dart';

import 'package:alleat/services/localprofiles_service.dart';
import 'package:alleat/theme/theme.dart';
import 'package:alleat/widgets/navigationbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alleat/theme/theme.dart' as globals;

void main() {
  //Start App
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  MyApp({super.key});
  Future getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final int? appTheme = prefs.getInt('appTheme');
    globals.appthemepreference = appTheme;
  }

  Future isSetupComplete() async {
    return await SQLiteLocalProfiles.getFirstProfile();
    //Call Database for the first entry
    if (profileInfo.isNotEmpty) {
      //If the first entry is empty
      //Then setup is not complete (pass to build)
      return const Navigation();
    } else {
      //If the first entry exists
      //Setup is complete (pass to build)

      return AddProfileLogin();
      //return const FreshProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    getTheme();
    var startLocation = isSetupComplete();
      if (startLocation.isNotEmpty) {
      //If the first entry is empty
      //Then setup is not complete (pass to build)
      return const Navigation();
    } else {
      //If the first entry exists
      //Setup is complete (pass to build)

      return AddProfileLogin();
      //return const FreshProfile();
    }
    switch (globals.appthemepreference) {
      case 1:
        return MaterialApp(
          //Create main app
          title: 'AllEat.',
          themeMode: ThemeMode.light,
          theme: ThemeClass.lightTheme,
          home:
              const Navigation(), //SetupWrapper(), //Check if setup is complete for app (reference)
        );
      case 2:
        return MaterialApp(
          //Create main app
          title: 'AllEat.',
          themeMode: ThemeMode.dark,
          theme: ThemeClass.darkTheme,
          home:
              , //SetupWrapper(), //Check if setup is complete for app (reference)
        );
    }
    return MaterialApp(
      //Create main app
      title: 'AllEat.',
      themeMode: ThemeMode.system,
      theme: ThemeClass.lightTheme,
      darkTheme: ThemeClass.darkTheme,
      home:
          setupWrapper, //SetupWrapper(), //Check if setup is complete for app (reference)
    );
  }
}
