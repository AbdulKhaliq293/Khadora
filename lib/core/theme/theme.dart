import 'package:flutter/material.dart';
import 'package:plant_care_app/core/theme/colors.dart';

final ThemeData lightTheme = ThemeData(
  primaryColor: primaryColor,
  hintColor: accentColor,
  scaffoldBackgroundColor: white,
  fontFamily: 'Poppins',
  appBarTheme: const AppBarTheme(
    backgroundColor: primaryColor,
    iconTheme: IconThemeData(color: white),
    titleTextStyle: TextStyle(
      color: white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: darkGrey, fontSize: 16),
    bodyMedium: TextStyle(color: darkGrey, fontSize: 14),
    headlineLarge: TextStyle(
      color: darkGrey,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: primaryColor,
    textTheme: ButtonTextTheme.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    fillColor: white, // Added for light theme
    labelStyle: const TextStyle(color: darkGrey), // Added for light theme
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: primaryColor), // Added for light theme
    ),
  ),
  cardColor: white, // Added for light theme
  shadowColor: darkGrey.withOpacity(0.3), // Added for light theme
);

final ThemeData darkTheme = ThemeData(
  primaryColor: primaryColor,
  hintColor: accentColor,
  scaffoldBackgroundColor: darkGrey,
  fontFamily: 'Poppins',
  appBarTheme: const AppBarTheme(
    backgroundColor: darkGrey,
    iconTheme: IconThemeData(color: white),
    titleTextStyle: TextStyle(
      color: white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: white, fontSize: 16),
    bodyMedium: TextStyle(color: white, fontSize: 14),
    headlineLarge: TextStyle(
      color: white,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: secondaryColor,
    textTheme: ButtonTextTheme.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: secondaryColor,
      foregroundColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    labelStyle: const TextStyle(color: white),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: secondaryColor),
    ),
    fillColor: darkGrey, // Added for dark theme
  ),
  cardColor: darkGrey, // Added for dark theme
  shadowColor: Colors.black.withOpacity(0.3), // Added for dark theme
);
