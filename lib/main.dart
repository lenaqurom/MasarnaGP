import 'package:flutter/material.dart';
import 'package:masarna/welcome.dart';
import 'package:masarna/auth/login.dart';
import 'package:masarna/auth/signup.dart';
import 'package:masarna/auth/forgot.dart';
import 'package:masarna/user/home.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jiffy/jiffy.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Welcome(),
      theme: ThemeData(
          primaryColor: Colors.red,
          hintColor: Color.fromARGB(255, 255, 255, 255), // Background color
          fontFamily: 'Dosis', // Specify your custom font
          buttonTheme: ButtonThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            buttonColor: Colors.red,
            textTheme: ButtonTextTheme.primary,
          ),
          textTheme: TextTheme(
              titleLarge: TextStyle(
            fontSize: 20,
            //color: Colors.white
          ))),
      routes: {
        "welcome": (context) => Welcome(),
        "login": (context) => Login(),
        "signup": (context) => Signup(),
        "forgot": (context) => ForgotPassword(),
        "home": (context) => Home(),
      },
    );
  }
}
