import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.indigo,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white, // Explicitly set text color
      ),
      // You can also add other AppBarTheme properties
      elevation: 4,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    // You might also want to set other theme properties
    primaryColor: Colors.indigo,
    colorScheme: ColorScheme.light(
      primary: Colors.indigo,
      secondary: Colors.indigoAccent,
    ),
  );
}