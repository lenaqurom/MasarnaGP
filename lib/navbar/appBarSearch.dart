
import 'package:flutter/material.dart';

@override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData.light().copyWith(
      appBarTheme: AppBarTheme(
        color: Color.fromARGB(255, 39, 26, 99).withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            Color.fromARGB(255, 255, 255, 255),
        hintStyle: TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
        ),
        
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(255, 39, 26, 99).withOpacity(0.5),
          ),
          borderRadius: BorderRadius.circular(24.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(255, 39, 26, 99).withOpacity(0.5),
          ),
          borderRadius: BorderRadius.circular(24.0),
        ),
        contentPadding: EdgeInsets.symmetric(
            horizontal: 16.0),
      ),
    );
  }
