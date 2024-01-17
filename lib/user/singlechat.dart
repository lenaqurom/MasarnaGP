import 'package:masarna/user/chatlist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SingleChat extends StatefulWidget {
  final String userId;
  SingleChat({required this.userId});
  @override
  _SingleChatState createState() => _SingleChatState();
}

class _SingleChatState extends State<SingleChat> {
  late User currentUser;
  late String chatUserId;
  late String chatUsername;
  late TextEditingController messageController = TextEditingController();
  late List<Widget> messages = [];
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser!;
    chatUserId = widget.userId;
    _fetchUsername();
    _fetchMessages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    try {
      FirebaseFirestore.instance
          .collection('messages')
          .doc(getChatId())
          .collection('chats')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
        List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
            querySnapshot.docs;

        setState(() {
          messages = docs
              .map<Widget>((doc) => _oneChat(
                    chat: doc['senderId'] == currentUser.uid ? 0 : 1,
                    message: doc['message'],
                    time: doc['timestamp'],
                  ))
              .toList();
        });
      });
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  Future<void> _fetchUsername() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(chatUserId)
          .get();
      setState(() {
        chatUsername = userSnapshot['username'];
      });
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 29, 55, 185),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _top(),
                _bottom(),
                SizedBox(
                  height: 120,
                )
              ],
            ),
            _chatinput(),
          ],
        ),
      ),
    );
  }

  _top() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 25,
                  color: Colors.white,
                ),
              ),
              if (chatUsername != null) 
              Text(
                '$chatUsername',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            if (chatUsername == null) 
              CircularProgressIndicator(), 
          ],
        ),
      ],
    ),
  );
}

  Widget _bottom() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 25, right: 25, top: 25),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(45),
            topRight: Radius.circular(45),
          ),
          color: Colors.white,
        ),
        child: ListView(
          physics: BouncingScrollPhysics(),
          reverse: true, // Set reverse to true
          controller: _scrollController,
          children: messages,
        ),
      ),
    );
  }

 _oneChat({int? chat, String? message, dynamic time}) {
  Timestamp timestamp = time ?? Timestamp.now();
  DateTime dateTime = timestamp.toDate();
  String formattedTime = DateFormat.Hm().format(dateTime);

  return Row(
    mainAxisAlignment: chat == 0 ? MainAxisAlignment.end : MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Flexible(
        child: Container(
          margin: EdgeInsets.only(left: 10, right: 10, top: 20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: chat == 0 ? Colors.indigo.shade100 : Colors.indigo.shade50,
            borderRadius: chat == 0
                ? BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  )
                : BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
          ),
          child: Text('$message'),
        ),
      ),
      SizedBox(width: 5), 
      chat == 0 || chat == 1
          ? Text(
              '$formattedTime',
              style: TextStyle(color: Colors.grey.shade400),
            )
          : SizedBox(),
    ],
  );
}



  String getChatId() {
    List<String> userIds = [currentUser.uid, chatUserId];
    userIds.sort();
    return userIds.join('_');
  }

  Widget _chatinput() {
    return Positioned(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 120,
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle:
                        TextStyle(color: Color.fromARGB(255, 45, 45, 46)),
                    filled: true,
                    fillColor: Colors.blueGrey[50],
                    labelStyle: TextStyle(fontSize: 12),
                    contentPadding: EdgeInsets.all(20),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white12),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white12),
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              InkWell(
                onTap: () {
                  _sendMessage();
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Color.fromARGB(255, 43, 71, 214),
                  ),
                  padding: EdgeInsets.all(14),
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    String message = messageController.text.trim();
    if (message.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(getChatId())
          .collection('chats')
          .add({
        'message': message,
        'senderId': currentUser.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
      messageController.clear();
    }
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
