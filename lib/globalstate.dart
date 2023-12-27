import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GlobalState extends ChangeNotifier {
  String _username = '';
  String _id = '';
  String _email = '';
  String _planid = '';
  String _gdpid = '';
  String _selectedFormattedDate = '';

  String get username => _username;
  String get id => _id;
  String get email => _email;
  String get planid => _planid;
  String get gdpid => _gdpid;
  String get selectedFormattedDate => _selectedFormattedDate;

  void addToState({
    String? username,
    String? email,
    String? id,
    String? planid,
    String? gdpid,
    String? selectedFormattedDate,
  }) {
    _username = username ?? '';
    _email = email ?? '';
    _id = id ?? '';
    _planid = planid ?? '';
    _gdpid = gdpid ?? '';
    _selectedFormattedDate = selectedFormattedDate ?? '';

    notifyListeners();
  }
}
