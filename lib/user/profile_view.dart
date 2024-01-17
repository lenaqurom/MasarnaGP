import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:masarna/user/singlechat.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';

class User {
  String name;
  String username;
  String email;
  String image;

  User({
    required this.name,
    required this.username,
    required this.email,
    required this.image,
  });
}

class ProfileViewPage extends StatefulWidget {
  final String userId;
  final String myuserId;
  ProfileViewPage({required this.userId, required this.myuserId});

  @override
  _ProfileViewPageState createState() => _ProfileViewPageState();
}

class _ProfileViewPageState extends State<ProfileViewPage> {
  User currentUser = User(
    name: '',
    username: '',
    email: '',
    image: '',
  );

  FriendshipStatus friendshipStatus = FriendshipStatus.notFriends;

  @override
  void initState() {
    super.initState();
    fetchUserProfile(widget.userId, widget.myuserId);
  }

  Future<void> fetchUserProfile(String userId, String myuserId) async {
    try {
      // String userId = '656387044327cefcbc27bb7c';
      // String myuserid = '655e701ae784f2d47cd02151';
      final response = await http.get(Uri.parse(
          'http://192.168.1.11:3000/api/profileview/$userId/$myuserId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          currentUser = User(
            name: data['name'] ?? '',
            username: data['username'],
            email: data['email'],
            image: data['profilepicture'] ?? '',
          );
          friendshipStatus = getFriendshipStatus(
              data['isFriend'], data['requestedthem'], data['requestedme']);
        });
      } else {
        print('Error fetching user profile: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching user profile: $error');
    }
  }

  FriendshipStatus getFriendshipStatus(
      bool? isFriend, bool? requestedthem, bool? requestedme) {
    if (isFriend == true) {
      return FriendshipStatus.friends;
    } else if (requestedthem == true) {
      return FriendshipStatus.requested;
    } else if (requestedme == true) {
      return FriendshipStatus.respond;
    } else {
      return FriendshipStatus.notFriends;
    }
  }

  String getFriendshipLabel() {
    switch (friendshipStatus) {
      case FriendshipStatus.notFriends:
        return 'Add Friend';
      case FriendshipStatus.requested:
        return 'Requested';
      case FriendshipStatus.friends:
        return 'Friends';
      case FriendshipStatus.respond:
        return 'Respond';
    }
  }

  Color getFriendshipColor() {
    switch (friendshipStatus) {
      case FriendshipStatus.notFriends:
        return Color.fromARGB(255, 39, 26, 99);
      case FriendshipStatus.requested:
        return Color.fromARGB(255, 43, 16, 162);
      case FriendshipStatus.friends:
        return Color.fromARGB(255, 39, 26, 99);
      case FriendshipStatus.respond:
        return Color.fromARGB(255, 43, 16, 162);
    }
  }

  IconData getFriendshipIcon() {
    switch (friendshipStatus) {
      case FriendshipStatus.notFriends:
        return Icons.person_add;
      case FriendshipStatus.requested:
        return Icons.group_add;
      case FriendshipStatus.friends:
        return Icons.check;
      case FriendshipStatus.respond:
        return Icons.add;
    }
  }

  void handleFriendship() async {
    if (friendshipStatus == FriendshipStatus.notFriends) {
      try {
        final response = await http.post(
          Uri.parse('http://192.168.1.11:3000/api/request'),
          headers: {
            'Content-Type':
                'application/json', 
          },
          body: jsonEncode({
            'userId': widget.myuserId,
            'recipientId': widget.userId,
          }),
        );
        if (response.statusCode == 200) {
          print('Friend request sent');
          setState(() {
            friendshipStatus = FriendshipStatus.requested;
          });
        } else if (response.statusCode == 400) {
          
          print('Friend request already sent');
        } else {
        
          print('Error sending friend request: ${response.statusCode}');
        }
      } catch (error) {
        print('Error sending friend request: $error');
      }
    } else if (friendshipStatus == FriendshipStatus.requested) {
      try {
        final response = await http.post(
          Uri.parse('http://192.168.1.11:3000/api/unrequest'),
          headers: {
            'Content-Type':
                'application/json', 
          },
          body: jsonEncode({
            'userId': widget.myuserId,
            'recipientId': widget.userId,
          }),
        );
        if (response.statusCode == 200) {
          print('unrequested successfully');
          setState(() {
            friendshipStatus = FriendshipStatus.notFriends;
          });
        } else {
          // Handle other error cases
          print('Error sending friend request: ${response.statusCode}');
        }
      } catch (error) {
        print('Error sending friend request: $error');
      }
    } else if (friendshipStatus == FriendshipStatus.friends) {
      try {
        print(widget.myuserId + '----' + widget.userId);
        final response = await http.post(
          Uri.parse('http://192.168.1.11:3000/api/unfriend'),
          headers: {
            'Content-Type':
                'application/json', 
          },
          body: jsonEncode({
            'userId': widget.myuserId,
            'friendId': widget.userId,
          }),
        );
        if (response.statusCode == 200) {
          print('unfriended successfully');
          setState(() {
            friendshipStatus = FriendshipStatus.notFriends;
          });
        } else {
         
          print('Error sending friend request: ${response.statusCode}');
        }
      } catch (error) {
        print('Error sending friend request: $error');
      }
    } else if (friendshipStatus == FriendshipStatus.respond) {
      try {
        print(widget.myuserId + '----' + widget.userId);
        
        final response = await http.post(
          Uri.parse('http://192.168.1.11:3000/api/friend'),
          headers: {
            'Content-Type':
                'application/json', 
          },
          body: jsonEncode({
            'userId': widget.myuserId,
            'senderId': widget.userId,
          }),
        );
        if (response.statusCode == 200) {
          print('accepted successfully');
          setState(() {
            friendshipStatus = FriendshipStatus.friends;
          });
        } else {
         
          print('Error accepting friend request: ${response}');
        }
      } catch (error) {
        print('Error sending friend request: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(213, 226, 224, 243),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: Color.fromARGB(255, 39, 26, 99)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.report),
                      SizedBox(width: 8),
                      Text("Report User"),
                    ],
                  ),
                  value: "report_user",
                ),
              ];
            },
            onSelected: (value) {
              if (value == "report_user") {
                showReportDialog(context);
              }
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: height * 0.4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(213, 226, 224, 243),
                    Color.fromARGB(213, 226, 224, 243)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: currentUser.image.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              'http://192.168.1.11:3000/' +
                                  currentUser.image.replaceAll('\\', '/'),
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          )
                        : ClipOval(
                            child: Image.asset(
                              "images/logo4.png",
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedText(currentUser.name, 35, FontWeight.bold),
                  SizedBox(height: 5),
                  AnimatedText(currentUser.username, 18, FontWeight.bold),
                  AnimatedText(currentUser.email, 18, FontWeight.bold),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SocialMediaButton(
                        onPressed: () {
                          handleFriendship();
                        },
                        label: getFriendshipLabel(),
                        color: getFriendshipColor(),
                        icon: getFriendshipIcon(),
                      ),
                      SocialMediaButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/chatlist');
                        },
                        label: 'Message',
                        color: const Color.fromARGB(255, 151, 150, 150),
                        icon: Icons.message,
                      ),
                    ],
                  ),
                  if (friendshipStatus == FriendshipStatus.friends)
                    ListTile(
                      title: Text('Unfriend'),
                      leading: Icon(Icons.remove_circle),
                      onTap: () {
                        setState(() {
                          friendshipStatus = FriendshipStatus.notFriends;
                        });
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showReportDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.WARNING,
      animType: AnimType.BOTTOMSLIDE,
      title: 'Are you sure you want to report this user?',
      desc: 'This action cannot be undone.',
      btnOkText: 'Report',
      btnCancelOnPress: () {},
      btnCancelColor: Colors.grey,
      btnOkColor: Color.fromARGB(255, 39, 26, 99),
      btnOkOnPress: () async {
        try {
          String id = widget.userId;
          final response = await http.post(
            Uri.parse('http://192.168.1.11:3000/api/reportuser/$id'),
            headers: {
            'Content-Length':
                '0', 
          },
          );
          if (response.statusCode == 200) {
            print('reported successfully');
            showSuccessDialog(context);
          }
        } catch (error) {
          print('Error reporting: $error');
        }
      },
    )..show();
  }

  void showSuccessDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.SUCCES,
      animType: AnimType.BOTTOMSLIDE,
      title: 'Successfully Reported',
      desc: 'Thank you for reporting this user.',
      btnOkOnPress: () {},
      btnOkColor: Color.fromARGB(255, 39, 26, 99),
    )..show();
  }
}

enum FriendshipStatus {
  notFriends,
  requested,
  friends,
  respond,
}

class SocialMediaButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final Color color;
  final IconData icon;

  SocialMediaButton({
    required this.onPressed,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 13, horizontal: 42),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 5,
        shadowColor: Colors.black,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Dosis',
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;

  AnimatedText(this.text, this.fontSize, this.fontWeight);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.scale(
          scale: value,
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: Colors.grey[800],
              fontFamily: 'PlayfairDisplay',
            ),
          ),
        );
      },
    );
  }
}
