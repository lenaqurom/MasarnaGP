import 'dart:io';

import 'package:flutter/material.dart';

class User {
  String name;
  String username;
  String email;
  File? image;

  User({
    required this.name,
    required this.username,
    required this.email,
    this.image,
  });
}

class ProfileViewPage extends StatefulWidget {
  @override
  _ProfileViewPageState createState() => _ProfileViewPageState();
}

class _ProfileViewPageState extends State<ProfileViewPage> {
  User currentUser = User(
    name: 'Lina Dana',
    username: 'username',
    email: 'lina@gmail.com',
    image: null,
  );

  FriendshipStatus friendshipStatus = FriendshipStatus.notFriends;

  void handleFriendship() {
    setState(() {
      if (friendshipStatus == FriendshipStatus.notFriends) {
        // Send friend request logic
        friendshipStatus = FriendshipStatus.requested;
      } else if (friendshipStatus == FriendshipStatus.requested) {
        // Cancel friend request logic
        friendshipStatus = FriendshipStatus.notFriends;
      } else if (friendshipStatus == FriendshipStatus.friends) {
        // Remove friend logic
        friendshipStatus = FriendshipStatus.notFriends;
      } else if (friendshipStatus == FriendshipStatus.respond) {
        // Accept friend request logic
        friendshipStatus = FriendshipStatus.friends;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(213, 226, 224, 243),
        elevation: 0,
        leading: Icon(Icons.arrow_back_ios, color: Color.fromARGB(255, 39, 26, 99)),
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
                  colors: [Color.fromARGB(213, 226, 224, 243), Color.fromARGB(213, 226, 224, 243)],
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
                    child: currentUser.image != null
                        ? ClipOval(
                            child: Image.file(
                              currentUser.image!,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          )
                        : ClipOval(
                            child: Image.asset(
                              "images/profile.png", // Placeholder image
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
                          // Handle Message logic
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
        primary: color,
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
          scale: value, // Use scale for a more dynamic effect
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
