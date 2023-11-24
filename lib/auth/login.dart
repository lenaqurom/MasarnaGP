import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:masarna/globalstate.dart';
import 'package:masarna/user/chatlist.dart';
import 'package:masarna/user/home.dart';
import 'package:masarna/user/profile_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../api/apiservice.dart'; // Import the API service
//import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool currentPageIsLogin = true;
  bool _isPasswordVisible = false;
  bool yalafirebase = false;
  final TextEditingController _usernameOrEmailController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final apiService = ApiService('http://192.168.1.15:3000/api');

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
  }

  @override
  void dispose() {
    _usernameOrEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> logIn(BuildContext context) async {
    final input = _usernameOrEmailController.text;
    final password = _passwordController.text;
    String email = "";
    String username = "";
    final globalState = Provider.of<GlobalState>(context, listen: false);

    try {
      bool isEmail = input.contains('@');
      if (isEmail) {
        email = _usernameOrEmailController.text;
      } else {
        username = _usernameOrEmailController.text;
      }

      // print("Request body: email=$email, username=$username, password=$password");

      final response = await post(
        Uri.parse('http://192.168.1.15:3000/api/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          if (email.isNotEmpty) 'email': email,
          if (username.isNotEmpty) 'username': username,
          'password': password,
        }),
      );
      print(
          "=======================================================================");
      print("Response status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        if (email.isNotEmpty) {
          globalState.addToState(email: email);
        }
        if (email.isEmpty) {
          globalState.addToState(username: username);
        }
        print(
            "Request body: email=$email, username=$username, password=$password");
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ProfileScreen()));

        // Successful registration
        // You can navigate to a different screen or show a success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login successful'),
        ));
        yalafirebase = true;
      } else if (response.statusCode == 401) {
        // Registration failed due to validation errors
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login failed: Incorrect data'),
        ));
      } else {
        // Registration failed for other reasons
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login failed. Please try again later.'),
        ));
      }
    } catch (error) {
      // Handle API request error
      // Show an error message or perform error handling
      print("Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred. Please try again later.'),
      ));
      print("PROBLEMMMMMMMMMMMMMMMMM");
    }
  }

  Future<void> loginUser() async {
    String usernameOrEmail = _usernameOrEmailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      // Check if the provided input is an email or username
      bool isEmail = usernameOrEmail.contains('@');
      AuthCredential credential;

      if (isEmail) {
        // Login with email
        credential = EmailAuthProvider.credential(
            email: usernameOrEmail, password: password);
      } else {
        // Login with username
        String email = await getUsernameEmail(usernameOrEmail);
        credential =
            EmailAuthProvider.credential(email: email, password: password);
      }

      // Sign in with the credential
      await FirebaseAuth.instance.signInWithCredential(credential);
      print("logged in");
      // Navigate to the next screen after successful login
      // Replace the 'HomeScreen' with the screen you want to navigate to after login
      // Navigator.pushReplacement(
      //   context, MaterialPageRoute(builder: (context) => ProfileScreen()));
    } catch (e) {
      // Handle login errors (e.g., wrong password, user not found)
      print("Error during login: $e");
      // Display an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "Login failed. Please check your username/email and password."),
      ));
    }
  }

  Future<String> getUsernameEmail(String username) async {
    try {
      // Assuming you have a Firestore collection named 'users'
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      // Query for the document with the given username
      QuerySnapshot querySnapshot =
          await users.where('username', isEqualTo: username).get();

      // If a user with the provided username exists, return their email
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.get('email').toString();
      } else {
        throw Exception("User not found with the provided username");
      }
    } catch (e) {
      print("Error during getUsernameEmail: $e");
      throw Exception("Error fetching user data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromARGB(255, 39, 26, 99),
          ),
          onPressed: () {
            Navigator.of(context).pushNamed("welcome");
          },
        ),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        toolbarHeight: 56,
        titleSpacing: 0,
        toolbarOpacity: 1,
        actions: [],
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Background Image
            Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Image.asset("images/logo7.png"),
                          Text(
                            "MASARNA",
                            style: TextStyle(
                              color: Color.fromARGB(255, 43, 16, 162),
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    currentPageIsLogin = true;
                                  });
                                },
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    color: currentPageIsLogin
                                        ? Color.fromARGB(255, 184, 13, 152)
                                        : Color.fromARGB(255, 39, 26, 99),
                                    fontSize: 25,
                                  ),
                                ),
                              ),
                              Text(
                                "  |  ",
                                style: TextStyle(fontSize: 25),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamed("signup");
                                  setState(() {
                                    currentPageIsLogin = false;
                                  });
                                },
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: currentPageIsLogin
                                        ? Color.fromARGB(255, 39, 26, 99)
                                        : Color.fromARGB(255, 184, 13, 152),
                                    fontSize: 25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 344,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(213, 226, 224, 243),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Form(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 25,
                        ),
                        Container(
                          height: 50,
                          child: TextFormField(
                            controller: _usernameOrEmailController,
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 16.0),
                              filled: true,
                              fillColor: Color.fromARGB(128, 255, 255, 255),
                              labelText: 'Username or Email',
                              labelStyle: TextStyle(
                                color: Color.fromARGB(255, 39, 26, 99),
                                fontSize: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.person,
                                color: Color.fromARGB(255, 39, 26, 99),
                              ),
                              hintText: "Username or Email",
                              hintStyle: TextStyle(
                                color: Color.fromARGB(255, 119, 119, 122),
                                fontSize: 16,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(128, 255, 255, 255),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 39, 26, 99),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
                        Container(
                          height: 50,
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 16.0),
                              filled: true,
                              fillColor: Color.fromARGB(128, 255, 255, 255),
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                color: Color.fromARGB(255, 39, 26, 99),
                                fontSize: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Color.fromARGB(255, 39, 26, 99),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Color.fromARGB(255, 39, 26, 99),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              hintText: "Password",
                              hintStyle: TextStyle(
                                color: Color.fromARGB(255, 119, 119, 122),
                                fontSize: 16,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(128, 255, 255, 255),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 39, 26, 99),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamed("forgot");
                                },
                                child: Text(
                                  "Forgot the password?",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 184, 13, 152),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              logIn(context);
                              print(_passwordController);
                              loginUser();
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.zero,
                              primary: Colors.transparent,
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF004aad),
                                    Color(0xFFcb6ce6),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
