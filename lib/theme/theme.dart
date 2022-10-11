library globals;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

dynamic appthemepreference = 0;

class ThemeClass {
  static Color primaryLight = const Color(0xff2B0082);
  static Color secondaryLight = const Color(0xff33C496);
  static Color successLight = const Color(0xff07852A);
  static Color errorLight = const Color(0xffAF0E17);
  static Color textLight = const Color(0xff1A1A1A);
  static Color bgLight = const Color(0xffFAFAFA);
  static Color bottomAppBarLight = const Color(0xffffffff);

  static Color primaryDark = const Color(0xffAD84FF);
  static Color secondaryDark = const Color(0xff8EE2C7);
  static Color successDark = const Color(0xff60F68A);
  static Color errorDark = const Color(0xffF2555F);
  static Color textDark = const Color(0xffEAEAEA);
  static Color bgDark = const Color(0xff0C0C0C);
  static Color bottomAppBarDark = const Color(0xff161616);

  static Color mono900 = const Color(0xff0C0C0C);
  static Color mono800 = const Color(0xff161616);
  static Color mono700 = const Color(0xff292929);
  static Color mono600 = const Color(0xff434343);
  static Color mono500 = const Color(0xff676767);
  static Color mono400 = const Color(0xff818181);
  static Color mono300 = const Color(0xff979797);
  static Color mono200 = const Color(0xffB6B6B6);
  static Color mono100 = const Color(0xffD2D2D2);
  static Color mono050 = const Color(0xffEAEAEA);
  static Color mono000 = const Color(0xffffffff);

  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryLight,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: secondaryLight,
      error: errorLight,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: mono000,
        selectedItemColor: primaryLight,
        unselectedItemColor: mono400),
    appBarTheme: AppBarTheme(backgroundColor: primaryLight),
    backgroundColor: bgLight,
    scaffoldBackgroundColor: bgLight,
    fontFamily: 'Satoshi',
    textTheme: TextTheme(
        headline1: TextStyle(
            color: textLight,
            fontFamily: 'Satoshi',
            fontWeight: FontWeight.w800,
            fontSize: 32),
        headline2: TextStyle(
            color: mono900,
            fontFamily: 'Satoshi',
            fontWeight: FontWeight.w700,
            fontSize: 28),
        headline3: TextStyle(
            color: mono800,
            fontFamily: 'Satoshi',
            fontWeight: FontWeight.w600,
            fontSize: 24),
        headline4: TextStyle(
            color: mono700,
            fontFamily: 'Satoshi',
            fontWeight: FontWeight.w500,
            fontSize: 21),
        headline5: TextStyle(
            color: mono500,
            fontFamily: 'Satoshi',
            fontWeight: FontWeight.w600,
            fontSize: 20),
        headline6: TextStyle(
            color: mono400,
            fontFamily: 'Satoshi',
            fontWeight: FontWeight.w600,
            fontSize: 16)),
    buttonTheme: ButtonThemeData(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        padding:
            const EdgeInsets.only(top: 18, bottom: 18, left: 30, right: 30)),
  );

  static ThemeData darkTheme = ThemeData(
      primaryColor: primaryDark,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: secondaryDark,
        error: errorDark,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: mono800, unselectedItemColor: mono600),
      appBarTheme: AppBarTheme(backgroundColor: mono800),
      backgroundColor: bgDark,
      scaffoldBackgroundColor: bgDark,
      textTheme: TextTheme(
          headline1: TextStyle(
              color: textDark,
              fontFamily: 'Satoshi',
              fontWeight: FontWeight.w800,
              fontSize: 32),
          headline2: TextStyle(
              color: mono050,
              fontFamily: 'Satoshi',
              fontWeight: FontWeight.w700,
              fontSize: 28),
          headline3: TextStyle(
              color: mono100,
              fontFamily: 'Satoshi',
              fontWeight: FontWeight.w600,
              fontSize: 24),
          headline4: TextStyle(
              color: mono200,
              fontFamily: 'Satoshi',
              fontWeight: FontWeight.w500,
              fontSize: 21),
          headline5: TextStyle(
              color: mono300,
              fontFamily: 'Satoshi',
              fontWeight: FontWeight.w500,
              fontSize: 20),
          headline6: TextStyle(
              color: mono400,
              fontFamily: 'Satoshi',
              fontWeight: FontWeight.w600,
              fontSize: 16),
          bodyText1: TextStyle(
              color: textDark,
              fontWeight: FontWeight.w600,
              fontFamily: 'NotoSans',
              fontSize: 14)),
      buttonTheme: ButtonThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          padding:
              const EdgeInsets.only(top: 18, bottom: 18, left: 30, right: 30)),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              primary: primaryDark,
              minimumSize: const Size.fromHeight(50),
              textStyle: TextStyle(
                  color: mono900,
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w600,
                  fontSize: 16))));
  //If app theme is set to light
}
