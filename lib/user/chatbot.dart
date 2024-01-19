import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  runApp(
    MaterialApp(
      home: ChatScreen(),
    ),
  );
}


class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _messages = [];

  Future<void> _handleSubmitted(String message) async {
    _textController.clear();

    // Add user's message to the chat
    _addMessage('User: $message');

    // Send user's message to Express.js backend
    final response = await http.post(
      Uri.parse('http://localhost:3000/api/fnsweather'),
      body: {'message': message},
    );

    // Parse and add chatbot's response to the chat
    final Map<String, dynamic> data = json.decode(response.body);
    final String chatbotResponse = data['response'];
    _addMessage('Bot: $chatbotResponse');
  }

  void _addMessage(String message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Planner Bot'),
      ),
      body: Column(
        children: [
          // Display chat history
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          // Input field for user messages
          TextField(
            controller: _textController,
            onSubmitted: _handleSubmitted,
            decoration: InputDecoration(
              hintText: 'Ask for suggestions...',
            ),
          ),
        ],
      ),
    );
  }
}
