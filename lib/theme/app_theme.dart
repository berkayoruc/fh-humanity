import 'package:flutter/material.dart';

class AppTheme {
  //
  AppTheme._();

  static final lightTheme = ThemeData(
      appBarTheme: AppBarTheme(
        centerTitle: true,
      ),
      brightness: Brightness.light,
      scaffoldBackgroundColor: Color(0xfff1f1f1),
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo)
          .copyWith(secondary: Colors.indigo));

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.indigoAccent,
    colorScheme:
        ColorScheme.fromSwatch().copyWith(secondary: Colors.indigoAccent),
  );
}
