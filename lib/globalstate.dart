import 'package:flutter/material.dart';

class GlobalState extends ChangeNotifier {
  String _username = '';
  int _id = 0;
  String _email = '';

  String get username => _username;
  int get id => _id;
  String get email => _email;
  void addToState({String? username, String? email}) {
    _username = username ?? '';
    _email = email ?? '';
    notifyListeners();
  }
}
