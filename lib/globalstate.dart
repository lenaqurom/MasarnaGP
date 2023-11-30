import 'package:flutter/material.dart';

class GlobalState extends ChangeNotifier {
  String _username = '';
  String _id = '';
  String _email = '';
  String _planid = '';

  String get username => _username;
  String get id => _id;
  String get email => _email;
  String get planid => _planid;
  void addToState({String? username, String? email, String? id, String? planid}) {
    _username = username ?? '';
    _email = email ?? '';
    _id = id ?? '';
    _planid = planid ?? '';
    notifyListeners();
  }
}
