
import 'package:firebase_core/firebase_core.dart';
import 'package:masarna/admin/adminNotifs.dart';
import 'package:masarna/admin/rating.dart';
import 'package:masarna/admin/usersManage.dart';
import 'package:masarna/trip/calender/calendar.dart';
import 'package:masarna/trip/explore.dart';
import 'package:masarna/trip/stays/staycomment.dart';
import 'package:masarna/user/notifications.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:masarna/globalstate.dart';
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
import 'package:masarna/user/profile_view.dart';
import 'package:masarna/user/edit_profile.dart';
import 'package:masarna/trip/homesection.dart';
import 'package:masarna/trip/drawer/addparticipants.dart';
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: Welcome(),
      theme: ThemeData(
          primaryColor: Colors.red,
          hintColor: Color.fromARGB(255, 255, 255, 255), 
          fontFamily: 'Dosis', 
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

      home: Welcome(),
      onGenerateRoute: (settings) {
        if (settings.name == '/singlechat') {
          final Map<String, dynamic>? arguments =
              settings.arguments as Map<String, dynamic>?;

          final userId = arguments?['userId'] as String?;
          if (userId != null) {
            return MaterialPageRoute(
              builder: (context) => SingleChat(userId: userId),
            );
          } else {
            
            return MaterialPageRoute(
              builder: (context) => Welcome(),
            );
          }
        }

        else if (settings.name == '/profileview') {
          final Map<String, dynamic>? arguments =
              settings.arguments as Map<String, dynamic>?;

          final userId = arguments?['userId'] as String?;
          final myuserId = arguments?['userId'] as String?;
          if (userId != null && myuserId != null ) {
            return MaterialPageRoute(
              builder: (context) => ProfileViewPage(userId: userId, myuserId: myuserId),
            );
          } else {
           
            return MaterialPageRoute(
              builder: (context) => Welcome(),
            );
          }
        }

        else if (settings.name == '/explore') {
          final Map<String, dynamic>? arguments =
              settings.arguments as Map<String, dynamic>?;

          final selectedDate = arguments?['selectedDate'] as DateTime?;
          if (selectedDate != null) {
            return MaterialPageRoute(
              builder: (context) => ExplorePage(selectedDate: selectedDate),
            );
          } else {
            
            return MaterialPageRoute(
              builder: (context) => Welcome(),
            );
          }
        }
        return MaterialPageRoute(
          builder: (context) =>
              Welcome(), 
        );
      },
      routes: {
        "/welcome": (context) => Welcome(),
        "/login": (context) => Login(),
        "/signup": (context) => Signup(),
        "/forgot": (context) => ForgotPassword(),
        "/home": (context) => Home(),
        "/planning": (context) => Planning(),
        "/chatlist": (context) => ChatList(),
        "/profilescreen": (context) => ProfileScreen(),
        "/editprofile": (context) => EditProfile(),
        "/staycomment": (context) => StayCommentPage(),
        "/addparticipants":(context) => AddParticipantsPage(), 
        "/calendar":(context) => MyCalendarPage(),  
        "/rating":(context) => RatingPage(), 
        "/usersmanage":(context) => UsersManage(),
        "/adminnotifs" :(context) => AdminNotifs(selectedIndex: 2,),
        "/notifications" :(context) => MyNotificationApp(),

     
         
      },
    );
  }
}
