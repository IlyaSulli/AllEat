library globals;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

dynamic appthemepreference = 0;

class AppTheme {
  static ThemeData get theme {
    Color primaryLight = const Color(0xff2B0082);
    Color secondaryLight = const Color(0xff33C496);
    Color successLight = const Color(0xff07852A);
    Color errorLight = const Color(0xffAF0E17);
    Color textLight = const Color(0xff1A1A1A);
    Color bgLight = const Color(0xffFAFAFA);
    Color bottomAppBarLight = const Color(0xffffffff);

    Color primaryDark = const Color(0xffAD84FF);
    Color secondaryDark = const Color(0xff8EE2C7);
    Color successDark = const Color(0xff60F68A);
    Color errorDark = const Color(0xffF2555F);
    Color textDark = const Color(0xffEAEAEA);
    Color bgDark = const Color(0xff0C0C0C);
    Color bottomAppBarDark = const Color(0xff161616);

    //If app theme is set to light
    ThemeData lightTheme = ThemeData(
      primaryColor: primaryLight,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: secondaryLight,
        error: errorLight,
      ),
      bottomAppBarColor: bottomAppBarLight,
      scaffoldBackgroundColor: bgLight,
      fontFamily: 'Satoshi',
      buttonTheme: ButtonThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          padding:
              const EdgeInsets.only(top: 18, bottom: 18, left: 30, right: 30)),
    );

    ThemeData darkTheme = ThemeData(
      primaryColor: primaryDark,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: secondaryDark,
        error: errorDark,
      ),
      bottomAppBarColor: bottomAppBarDark,
      scaffoldBackgroundColor: bgDark,
      fontFamily: 'Satoshi',
      buttonTheme: ButtonThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          padding:
              const EdgeInsets.only(top: 18, bottom: 18, left: 30, right: 30)),
    );

    ThemeData systemTheme = ThemeData(
      primaryColor: primaryLight,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: secondaryLight,
        error: errorLight,
      ),
      bottomAppBarColor: bottomAppBarLight,
      appBarTheme: AppBarTheme(color: primaryLight),
      scaffoldBackgroundColor: bgLight,
      fontFamily: 'Satoshi',
      buttonTheme: ButtonThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          padding:
              const EdgeInsets.only(top: 18, bottom: 18, left: 30, right: 30)),
    );

    //Get app theme from preferences
    if (appthemepreference == 1) {
      return lightTheme;
    }
    if (appthemepreference == 2) {
      return darkTheme;
    } else {
      return systemTheme;
    }
  }
}
