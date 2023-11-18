import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:masarna/user/singlechat.dart';

//api request for search, api request for chatcards (chat, time, name, pfp)
//prepare chat card to take in data from be, prepare the search part ui

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  late User currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 127, 20, 154),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _body(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: EdgeInsets.only(top: 30, left: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Chat with friends',
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          GestureDetector(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
              print(
                  'logged out'); // Replace '/login' with your login page route
            },
            child: Container(
              margin: EdgeInsets.only(left: 100.0, bottom: 7.0),
              padding:
                  EdgeInsets.only(left: 14, right: 14, top: 14, bottom: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.black12,
              ),
              child: Icon(
                Icons.search,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: 15,
          ),
        ],
      ),
    );
  }

  Widget _body() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(45), topRight: Radius.circular(45)),
          color: Colors.white,
        ),
        child: FutureBuilder(
          future: _getChatUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            List<QueryDocumentSnapshot> users =
                snapshot.data as List<QueryDocumentSnapshot>;
            return ListView(
              padding: EdgeInsets.only(top: 35),
              physics: BouncingScrollPhysics(),
              children: users.map((user) {
                return _chatCard(
                  name: user['username'] ?? '',
                  userId: user.id,
                  // Add other fields based on your Firestore structure
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Future<List<QueryDocumentSnapshot>> _getChatUsers() async {
    try {
      // Assuming you have a Firestore collection named 'users'
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      // You can filter the users based on your logic
      // For now, let's assume you want all users except the current user
      List<QueryDocumentSnapshot> users = querySnapshot.docs
          .where((user) => user.id != currentUser.uid)
          .toList();

      return users;
    } catch (e) {
      print("Error fetching chat users: $e");
      throw Exception("Error fetching chat users");
    }
  }

  Widget _chatCard(
      {String name = '',
      
      required String userId}) {
    return GestureDetector(
      onTap: () {
        // Handle the tap event
        // You can navigate to the chat screen or do other actions
        Navigator.of(context)
            .pushNamed('/singlechat', arguments: {'userId': userId});
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 20),
        elevation: 0,
        child: Row(
          children: [
            Avatar(
              imagePath: 'images/logo4.png',
              margin: EdgeInsets.only(right: 20),
              size: 60,
              // Add user image URL or other relevant information
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$name',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  final double size;
  final String? imagePath;
  final EdgeInsets margin;

  Avatar({this.imagePath, this.size = 50, this.margin = const EdgeInsets.all(0)});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Container(
        width: size,
        height: size,
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
          image: imagePath != null
              ? new DecorationImage(
                  image: AssetImage(imagePath!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
      ),
    );
  }
}