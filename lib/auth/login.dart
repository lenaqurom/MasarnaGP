import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../api/loginandsignup.dart'; // Import the API service
//import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool currentPageIsLogin = true;
  bool _isPasswordVisible = false;
  final TextEditingController _usernameOrEmailController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final apiService = ApiService('http://192.168.1.17:3000/api');

  @override
  void dispose() {
    _usernameOrEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> logIn() async {
    final email = _usernameOrEmailController.text;
    //final username = _usernameController.text;
    final password = _passwordController.text;

    try {
      final response = await post(
        Uri.parse(
            'http://192.168.1.17:3000/api/login'), // Replace with your backend URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          if (email.isNotEmpty) 'email': email,
          if (email.isEmpty) 'username': _usernameOrEmailController.text,
          'password': password,
        }),
      );
      print("Response status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Successful registration
        // You can navigate to a different screen or show a success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login successful'),
        ));
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
                              logIn();
                              print(_passwordController);
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
