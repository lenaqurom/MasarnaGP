import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:masarna/user/singlechat.dart';

//api request for search, api request for chatcards (chat, time, name, pfp)
//prepare chat card to take in data from be, prepare the search part ui

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
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
          //  Row(
          //   children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              margin:EdgeInsets.only(left:100.0, bottom:7.0),
              padding: EdgeInsets.only(left:14, right: 14, top:14, bottom:14),
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
          // Expanded(
          //  child: Container(
          //   height: 100,
          //     child: ListView.builder(
          //       physics: BouncingScrollPhysics(),
          //       scrollDirection: Axis.horizontal,
          //      shrinkWrap: true,

          //       itemCount: 8,
          //       itemBuilder: (context, index) {
          //         return Avatar(
          //           margin: EdgeInsets.only(right: 15),
          //           image: 'images/logo4.png',
          //         );
          //       },

          //     ),
          //  ),
          //),
        ],
      ),
      // ],
    );
    //);
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
        child: ListView(
          padding: EdgeInsets.only(top: 35),
          physics: BouncingScrollPhysics(),
          children: [
            _chatCard(
              avatar: 'images/logo4.png',
              name: 'Dana',
              chat: 'hello',
              time: '08.10',
            ),
            _chatCard(
              avatar: 'images/logo4.png',
              name: 'Lina',
              chat: 'hi',
              time: '03.19',
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatCard({String avatar = '', name = '', chat = '', time = '00.00'}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SingleChat(),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 20),
        elevation: 0,
        child: Row(
          children: [
            Avatar(
              margin: EdgeInsets.only(right: 20),
              size: 60,
              image: avatar,
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
                      Text(
                        '$time',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    '$chat',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
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
  final image;
  final EdgeInsets margin;
  Avatar({this.image, this.size = 50, this.margin = const EdgeInsets.all(0)});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Container(
        width: size,
        height: size,
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
          image: new DecorationImage(
            image: AssetImage(image),
          ),
        ),
      ),
    );
  }
}
