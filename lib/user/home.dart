import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:masarna/navbar/BottomNavBar.dart';
import 'package:masarna/navbar/animatedbar.dart';
import 'package:masarna/navbar/rive_asset.dart';
import 'package:masarna/navbar/rive_utils.dart';
import 'package:masarna/trip/planning.dart';
import 'package:masarna/user/makeprofile.dart';
import 'package:masarna/user/profile_view.dart';
import 'package:rive/rive.dart';
import 'package:masarna/globalstate.dart';
import 'package:provider/provider.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<User>> fetchUsers() async {
  try {
    final response =
        await http.get(Uri.parse('http://192.168.1.11:3000/api/users'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((json) =>
              User(id: json['_id'].toString(), username: json['username']))
          .toList();
    } else {
      throw Exception('Failed to load users');
    }
  } catch (e) {
    throw Exception('Error fetching users: $e');
  }
}

class User {
  final String id;
  final String username;

  User({required this.id, required this.username});
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  RiveAsset selectedBottomNav = bottomNavs.elementAt(0);
  List<User> users = [];

  Future<List<User>> _fetchUsers() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.1.11:3000/api/users'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((json) =>
                User(id: json['_id'].toString(), username: json['username']))
            .toList();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUsers().then((fetchedUsers) {
      setState(() {
        users = fetchedUsers;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 39, 26, 99).withOpacity(0.5),
        title: Row(
          children: [
            SizedBox(width: 10),
            Text("Masarna",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "DancingScript",
                  fontSize: 33,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: () {
              showSearch(
                context: context,
                delegate: DataSearch(users),
              );
            },
            child: SizedBox(
              height: 40,
              width: 40,
              child: RiveAnimation.asset(
                "icons/icons.riv",
                artboard: "SEARCH",
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              FontAwesomeIcons.facebookMessenger,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pushNamed('/chatlist');
            },
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
              color: Color.fromARGB(255, 39, 26, 99).withOpacity(0.5),
              borderRadius: BorderRadius.all(Radius.circular(24))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ...List.generate(
                bottomNavs.length,
                (index) => GestureDetector(
                    onTap: () {
                      bottomNavs[index].input!.change(true);
                      if (bottomNavs[index] != selectedBottomNav) {
                        setState(() {
                          if (index == 0) {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Home(),
                            ));
                          } else if (index == 1) {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Home(),
                            ));
                          } else if (index == 2) {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Planning(),
                            ));
                          } else if (index == 3) {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ProfileApp(),
                            ));
                          }
                          selectedBottomNav = bottomNavs[index];
                        });
                      }
                      Future.delayed(const Duration(seconds: 1), () {
                        bottomNavs[index].input!.change(false);
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBar(
                            isActive: bottomNavs[index] == selectedBottomNav),
                        SizedBox(
                            height: 36,
                            width: 36,
                            child: Opacity(
                              opacity: bottomNavs[index] == selectedBottomNav
                                  ? 1
                                  : 0.5,
                              child: RiveAnimation.asset(
                                bottomNavs.first.src,
                                artboard: bottomNavs[index].artboard,
                                onInit: (artboard) {
                                  StateMachineController controller =
                                      RiveUtils.getRiveController(artboard,
                                          StateMachineName: bottomNavs[index]
                                              .stateMachineName);
                                  bottomNavs[index].input =
                                      controller.findSMI("active") as SMIBool;
                                },
                              ),
                            ))
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DataSearch extends SearchDelegate<String> {
  final List<User> users;

  DataSearch(this.users);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.close),
        color: Color.fromARGB(255, 39, 26, 99),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: Icon(
        Icons.arrow_back_ios,
        color: Color.fromARGB(255, 39, 26, 99),
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final searchResults = users
        .where(
            (user) => user.username.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, i) {
        return InkWell(
          onTap: () {
            String myuserId =
                Provider.of<GlobalState>(context, listen: false).id;
            print(myuserId);
            print("/////");
            print(searchResults[i].id);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileViewPage(
                  myuserId: myuserId,
                  userId: searchResults[i].id,
                ),
              ),
            );
          },
          child: ListTile(
            title: Text(searchResults[i].username),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = users
        .where(
            (user) => user.username.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, i) {
        return ListTile(
          title: Text(suggestionList[i].username),
          onTap: () {
            query = suggestionList[i].username;
          },
        );
      },
    );
  }

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
        fillColor: Color.fromARGB(255, 255, 255, 255),
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
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
      ),
    );
  }
}
