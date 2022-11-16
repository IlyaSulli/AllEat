library globals;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';

dynamic appthemepreference = 0;

class ThemeClass {
  static Color primaryLight = const Color(0xff5806FF);
  static Color secondaryLight = const Color(0xffAD84FF);
  static Color successLight = const Color(0xff07852A);
  static Color errorLight = const Color(0xffAF0E17);
  static Color textLight = const Color(0xff1A1A1A);
  static Color bgLight = const Color(0xffFAFAFA);
  static Color bottomAppBarLight = const Color(0xffffffff);

  static Color primaryDark = const Color(0xffC1A3FF);
  static Color secondaryDark = const Color(0xffAD84FF);
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

  static Color primary900 = const Color(0xff060011);
  static Color primary800 = const Color(0xff160041);
  static Color primary700 = const Color(0xff2B0082);
  static Color primary600 = const Color(0xff4100C4);
  static Color primary500 = const Color(0xff5806FF);
  static Color primary400 = const Color(0xff9866FF);
  static Color primary300 = const Color(0xffAD84FF);
  static Color primary200 = const Color(0xffC1A3FF);
  static Color primary100 = const Color(0xffD6C2FF);
  static Color primary050 = const Color(0xffEBE0FF);

  static ThemeData lightTheme = ThemeData(
      

      //COLOUR

      primaryColor: primaryLight,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: secondaryLight,
        error: errorLight,
        onBackground: textLight,
        onSurface: mono000,
      ),
      

      // MAIN APP

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: mono000,
          selectedItemColor: primaryLight,
          unselectedItemColor: mono400),
      appBarTheme: AppBarTheme(backgroundColor: primaryLight),
      backgroundColor: bgLight,
      scaffoldBackgroundColor: bgLight,
      snackBarTheme: SnackBarThemeData(
          contentTextStyle: TextStyle(
              color: mono900,
              fontFamily: 'Satoshi',
              fontWeight: FontWeight.w600,
              fontSize: 14),
          backgroundColor: mono100),
      
      

      // TEXT

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
              color: mono800,
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
              fontSize: 16),
          bodyText1: TextStyle(
              color: textLight,
              fontWeight: FontWeight.w600,
              fontFamily: 'NotoSans',
              fontSize: 14),
          bodyText2: TextStyle(
              color: textLight,
              fontWeight: FontWeight.w400,
              fontFamily: 'NotoSans',
              fontSize: 16)),

      //BUTTONS

      buttonTheme: ButtonThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          padding:
              const EdgeInsets.only(top: 18, bottom: 18, left: 30, right: 30)),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              foregroundColor: bgLight,
              backgroundColor: primaryLight,
              padding: const EdgeInsets.only(
                  top: 15, bottom: 15, left: 30, right: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5), // <-- Radius
              ),
              textStyle: TextStyle(
                  color: bgLight,
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w600,
                  fontSize: 16))),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
              foregroundColor: primaryLight,
              padding: const EdgeInsets.only(
                  top: 15, bottom: 15, left: 30, right: 30),
              side: BorderSide(color: primaryLight, width: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5), // <-- Radius
              ),
              textStyle: TextStyle(
                  color: primaryLight,
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w600,
                  fontSize: 16))),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: primaryLight,
              padding: const EdgeInsets.only(
                  top: 18, bottom: 18, left: 30, right: 30),
              textStyle: TextStyle(
                  color: primaryLight,
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w600,
                  fontSize: 16))),

      //FORM FIELD

      inputDecorationTheme: InputDecorationTheme(
          filled: false,
          hintStyle: TextStyle(
              color: mono300,
              fontFamily: 'Satoshi',
              fontWeight: FontWeight.w600,
              fontSize: 16),
          contentPadding: const EdgeInsets.all(10),
          border: UnderlineInputBorder(
              borderSide: BorderSide(width: 3, color: mono100)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(width: 3, color: primaryLight)),
          disabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(width: 3, color: mono050)),
          errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(width: 3, color: errorLight)),
          focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(width: 3, color: errorDark)),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(width: 3, color: mono100))));

  static ThemeData darkTheme = ThemeData(

      //COLOUR

      primaryColor: primaryDark,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: secondaryDark,
        error: errorDark,
        onBackground: textDark,
        onSurface: mono700,
      ),

      //MAIN APP

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: mono800, unselectedItemColor: mono600),
      appBarTheme: AppBarTheme(backgroundColor: mono800),
      backgroundColor: bgDark,
      scaffoldBackgroundColor: bgDark,

      // TEXT

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
              color: mono100,
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
              fontSize: 14),
          bodyText2: TextStyle(
              color: mono000,
              fontWeight: FontWeight.w400,
              fontFamily: 'NotoSans',
              fontSize: 16)),

      //BUTTONS

      buttonTheme: ButtonThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          padding:
              const EdgeInsets.only(top: 18, bottom: 18, left: 30, right: 30)),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              foregroundColor: bgDark,
              backgroundColor: primaryDark,
              padding: const EdgeInsets.only(
                  top: 15, bottom: 15, left: 30, right: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5), // <-- Radius
              ),
              textStyle: TextStyle(
                  color: mono900,
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w600,
                  fontSize: 16))),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
              foregroundColor: primaryDark,
              padding: const EdgeInsets.only(
                  top: 15, bottom: 15, left: 30, right: 30),
              side: BorderSide(color: primaryDark, width: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5), // <-- Radius
              ),
              // minimumSize: const Size.fromHeight(50),

              textStyle: TextStyle(
                  color: primaryDark,
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w600,
                  fontSize: 16))),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: primaryDark,
              padding: const EdgeInsets.only(
                  top: 18, bottom: 18, left: 30, right: 30),
              textStyle: TextStyle(
                  color: primaryDark,
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w600,
                  fontSize: 16))),

      // FORM FIELD

      inputDecorationTheme: InputDecorationTheme(
          filled: false,
          hintStyle: TextStyle(
              color: mono400,
              fontFamily: 'Satoshi',
              fontWeight: FontWeight.w600,
              fontSize: 16),
          contentPadding: const EdgeInsets.all(10),
          border: UnderlineInputBorder(
              borderSide: BorderSide(width: 3, color: mono700)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(width: 3, color: primaryDark)),
          disabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(width: 3, color: mono800)),
          errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(width: 3, color: errorDark)),
          focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(width: 3, color: errorLight)),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(width: 3, color: mono600))));
}
