import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants.dart';

enum AppTheme {
  LightTheme,
  DarkTheme,
}

final appThemeData = {
  AppTheme.LightTheme: ThemeData(
    brightness: Brightness.light,
    platform: TargetPlatform.iOS,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      color: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      actionsIconTheme: IconThemeData(
        color: Colors.white,
      ),
      titleTextStyle: TextStyle(
        color: kColorDarkBlue,
        fontFamily: 'NunitoSans',
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey[300],
      thickness: 0.5,
      space: 0.5,
      indent: 10,
      endIndent: 10,
    ),
    textTheme: const TextTheme(
      // button: kTextStyleButton,
      // subtitle1: kTextStyleSubtitle1.copyWith(color: kColorPrimaryDark),
      // subtitle2: kTextStyleSubtitle2.copyWith(color: kColorPrimaryDark),
      // bodyText2: kTextStyleBody2.copyWith(color: kColorPrimaryDark),
      // headline6: kTextStyleHeadline6.copyWith(color: kColorPrimaryDark),
    ),
    iconTheme: const IconThemeData(
      color: kReSustainabilityRed,
    ),
    fontFamily: 'NunitoSans',
    cardTheme: CardTheme(
      elevation: 0,
      color: const Color(0xffEBF2F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        //side: BorderSide(width: 1, color: Colors.grey[200]),
      ),
    ), checkboxTheme: CheckboxThemeData(
 fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return kReSustainabilityRed; }
 return null;
 }),
 ), radioTheme: RadioThemeData(
 fillColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return kReSustainabilityRed; }
 return null;
 }),
 ), switchTheme: SwitchThemeData(
 thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return kReSustainabilityRed; }
 return null;
 }),
 trackColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
 if (states.contains(WidgetState.disabled)) { return null; }
 if (states.contains(WidgetState.selected)) { return kReSustainabilityRed; }
 return null;
 }),
 ),
  ),
  AppTheme.DarkTheme: ThemeData(
    brightness: Brightness.dark,
    platform: TargetPlatform.iOS,
    scaffoldBackgroundColor: Colors.black,
    // toggleableActiveColor: kReSustainabilityRed,
    colorScheme: const ColorScheme.dark(secondary: kReSustainabilityRed),
    appBarTheme: const AppBarTheme(
      color: Color(0xff121212),
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: kColorDark,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      iconTheme: IconThemeData(
        //color: Colors.white.withOpacity(0.87),
        color: kReSustainabilityRed,
      ),
      actionsIconTheme: IconThemeData(
        //color: Colors.white.withOpacity(0.87),
        color: kReSustainabilityRed,
      ),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontFamily: 'NunitoSans',
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Colors.white54,
      thickness: 0.5,
      space: 0.5,
      indent: 10,
      endIndent: 10,
    ),
    textTheme: const TextTheme(
      // button: kTextStyleButton,
      // subtitle1:
      //     kTextStyleSubtitle1.copyWith(color: Colors.white.withOpacity(0.87)),
      // subtitle2:
      //     kTextStyleSubtitle2.copyWith(color: Colors.white.withOpacity(0.87)),
      // bodyText2:
      //     kTextStyleBody2.copyWith(color: Colors.white.withOpacity(0.87)),
      // headline6:
      //     kTextStyleHeadline6.copyWith(color: Colors.white.withOpacity(0.87)),
    ),
    iconTheme: IconThemeData(
      color: Colors.white.withOpacity(0.87),
    ),
    fontFamily: 'NunitoSans',
    cardTheme: CardTheme(
      elevation: 0,
      color: kColorDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(width: 0, color: Colors.transparent),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.87),
        ),
      ),
    ),
  ),
};
