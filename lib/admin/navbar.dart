import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:masarna/admin/adminChat.dart';
import 'package:masarna/admin/adminNotifs.dart';
import 'package:masarna/admin/analytics.dart';
import 'package:masarna/admin/externalManage.dart';
import 'package:masarna/admin/usersManage.dart';

class Example extends StatefulWidget {
  final int initialIndex;

  Example({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  int _selectedIndex = 0;
  PageController _pageController = PageController(initialPage: 0);

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.w600);

  // Rest of your code...

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Home',
      style: optionStyle,
    ),
    Text(
      'Likes',
      style: optionStyle,
    ),
    Text(
      'Search',
      style: optionStyle,
    ),
    Text(
      'Profile',
      style: optionStyle,
    ),
    Text(
      'Profile',
      style: optionStyle,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(), // Disable page swiping

        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(39, 26, 99, 1).withOpacity(0.15),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Color.fromRGBO(39, 26, 99, 1),
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              duration: Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[100]!,
              color: Colors.black,
              backgroundColor: Colors.transparent,
              tabs: [
                GButton(
                  icon: LineIcons.home,
                  text: 'Home',
                  textSize: 10,
                  iconSize: 20,
                ),
                GButton(
                  icon: LineIcons.facebookMessenger,
                  text: 'Chat',
                  textSize: 10,
                  iconSize: 20,
                ),
                GButton(
                  icon: FlutterIcons.notifications_none_mdi,
                  text: 'Notifs',
                  textSize: 10,
                  iconSize: 20,
                ),
                GButton(
                  icon: LineIcons.userFriends,
                  text: 'Users',
                  textSize: 10,
                  iconSize: 20,
                ),
                GButton(
                  icon: FlutterIcons.google_analytics_mco,
                  text: 'Analytics',
                  textSize: 10,
                  iconSize: 20,
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                _pageController.animateToPage(
                  index,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.ease,
                );

                if (_selectedIndex != index) {
                  setState(() {
                    _selectedIndex = index;
                  });

                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      switch (index) {
                        // case 0:
                        //   return ExternalManage(selectedIndex: index);
                        case 1:
                          return Chat(selectedIndex: index);
                        case 2:
                          return AdminNotifs(selectedIndex: index);
                        // case 3:
                        //   return UsersManage(selectedIndex: index);
                        // case 4:
                        //   return Analytics(selectedIndex: index);
                        default:
                          return AdminNotifs(selectedIndex: index);
                        // return ExternalManage(selectedIndex: index);
                      }
                    },
                  ));
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
