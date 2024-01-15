import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:masarna/admin/navbar.dart';

class User {
  String id;
  String fullName;
  String username;
  String email;
  String imageUrl; // Add image URL
  int numberOfReports;

  User({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.imageUrl, // Add image URL
    required this.numberOfReports,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      fullName: json['name'] ?? '',
      username: json['username'],
      email: json['email'],
      imageUrl: json['profilepicture'] ?? '',
      numberOfReports: json['reports'],
    );
  }
}

class UsersManage extends StatefulWidget {
  const UsersManage({Key? key}) : super(key: key);

  @override
  State<UsersManage> createState() => _UsersManageState();
}

class _UsersManageState extends State<UsersManage> {
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    // Fetch users when the widget is first created
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.1.11:3000/api/users'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
// Filter out the user with the username 'admin'
        List<User> fetchedUsers = data
            .where((userJson) => userJson['username'] != 'admin')
            .map((userJson) => User.fromJson(userJson))
            .toList();
        setState(() {
          users = fetchedUsers;
        });
      } else {
        // Handle errors
        print('Failed to fetch users. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle errors
      print('Error fetching users: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort users based on numberOfReports in descending order
    users.sort((a, b) => b.numberOfReports.compareTo(a.numberOfReports));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage users',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 39, 26, 99),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          User user = users[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.all(16),
                   leading: Container(
  width: 60,
  height: double.infinity,
  child: CircleAvatar(
    backgroundImage: user.imageUrl.isNotEmpty
        ? NetworkImage('http://192.168.1.11:3000/' + user.imageUrl.replaceAll('\\', '/'))
        : Image.asset('images/logo4.png', fit: BoxFit.fill).image,
  ),
),

                    title: Text(
                      user.fullName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text(
                          '${user.username}',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        Text(
                          '${user.email}',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0.0,
                    right: 0.0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 39, 26, 99),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(22),
                          bottomLeft: Radius.circular(22),
                        ),
                      ),
                      child: Text(
                        'Reports: ${user.numberOfReports}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0.0,
                    right: 0.0,
                    child: IconButton(
                      icon: Icon(Icons.delete,
                          color: Color.fromARGB(255, 39, 26, 99)),
                      onPressed: () {
                        // Show a confirmation dialog
                        showDeleteConfirmationDialog(index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void showDeleteConfirmationDialog(int index) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.WARNING,
      headerAnimationLoop: false,
      animType: AnimType.BOTTOMSLIDE,
      title: 'Delete User',
      desc: 'Are you sure you want to delete this user?',
      btnCancelOnPress: () {},
      btnOkColor: Color.fromARGB(255, 39, 26, 99),
      btnCancelColor: Colors.grey,
      btnOkOnPress: () async {
        try {
          String id = users[index].id.toString();
          print(users[index].id);
          final response = await http.delete(
            Uri.parse(
                'http://192.168.1.11:3000/api/user/$id'),
          );

          if (response.statusCode == 200) {
            print('User successfully deleted');
            setState(() {
              users.removeAt(index);
              AwesomeDialog(
                context: context,
                dialogType: DialogType.SUCCES,
                headerAnimationLoop: false,
                animType: AnimType.BOTTOMSLIDE,
                title: 'Deleted!',
                desc: 'The user has been successfully deleted.',
                btnOkOnPress: () {},
                btnOkColor: Color.fromARGB(255, 39, 26, 99),
              )..show();
            });
          } else {
            // Handle errors
            print('Failed to delete user. Status code: ${response.statusCode}');
          }
        } catch (error) {
          // Handle errors
          print('Error deleting user: $error');
        }
      },
    )..show();
  }
}
