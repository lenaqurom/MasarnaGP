import 'package:flutter/material.dart';
import 'package:masarna/admin/navbar.dart';

class Chat extends StatefulWidget {
  const Chat({super.key, required int selectedIndex});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('Chat'),
      bottomNavigationBar: Example(initialIndex: 1), 
    );
  }
}