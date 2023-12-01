import 'package:firebase_core/firebase_core.dart';
import 'package:masarna/trip/stays/staycomment.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:masarna/globalstate.dart';
//import 'package:masarna/trip/tripplan.dart';
import 'package:masarna/welcome.dart';
import 'package:masarna/auth/login.dart';
import 'package:masarna/auth/signup.dart';
import 'package:masarna/auth/forgot.dart';
import 'package:masarna/user/home.dart';
import 'package:masarna/trip/planning.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:masarna/user/singlechat.dart';
import 'package:masarna/user/chatlist.dart';
import 'package:masarna/user/profile_page.dart';
import 'package:masarna/user/edit_profile.dart';
import 'package:masarna/trip/homesection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => GlobalState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: Welcome(),
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

      home: Login(),
      onGenerateRoute: (settings) {
        if (settings.name == '/singlechat') {
          // Extract the userId from the arguments
          final Map<String, dynamic>? arguments =
              settings.arguments as Map<String, dynamic>?;

          // Check if arguments contain userId
          final userId = arguments?['userId'] as String?;
          if (userId != null) {
            return MaterialPageRoute(
              builder: (context) => SingleChat(userId: userId),
            );
          } else {
            // Handle error or navigate to a default screen
            // For now, navigating to Welcome() as an example
            return MaterialPageRoute(
              builder: (context) => Welcome(),
            );
          }
        }

        else if (settings.name == '/section') {
          // Extract the planId from the arguments
          final Map<String, dynamic>? arguments =
              settings.arguments as Map<String, dynamic>?;

          // Check if arguments contain planId
          final planId = arguments?['planId'] as String?;
          if (planId != null) {
            return MaterialPageRoute(
              builder: (context) => SectionsPage(planId: planId),
            );
          } else {
            // Handle error or navigate to a default screen
            // For now, navigating to Welcome() as an example
            return MaterialPageRoute(
              builder: (context) => Welcome(),
            );
          }
        }

        return MaterialPageRoute(
          builder: (context) =>
              Welcome(), // Placeholder, replace with your actual routes
        );
      },
      routes: {
        "/welcome": (context) => Welcome(),
        "/login": (context) => Login(),
        "/signup": (context) => Signup(),
        "/forgot": (context) => ForgotPassword(),
        "/home": (context) => Home(),
        "/planning": (context) => Planning(),
        // "/tripplan": (context) => TripPlan(),
        "/chatlist": (context) => ChatList(),
        "/profilescreen": (context) => ProfileScreen(),
        "/editprofile": (context) => EditProfile(),
        "/staycomment": (context) => StayCommentPage(),
        // "/singlechat": (context) => SingleChat(),
        //"/homesections": (context) => HomeSectionsPage(),
      },
    );
  }
}
