import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../api/apiservice.dart'; // Import the API service

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool currentPageIsSignup = true;
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final apiService = ApiService('http://192.168.1.13:3000/api');
  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
  }
  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

Future<void> signUp() async {
  final email = _emailController.text;
  final username = _usernameController.text;
  final password = _passwordController.text;

  if (_formKey.currentState!.validate()) {
    try {
      final response = await post(
        Uri.parse('http://192.168.1.13:3000/api/signup'), // Replace with your backend URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email,
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        // Successful registration
        // You can navigate to a different screen or show a success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Registration successful'),
        ));
      } else if (response.statusCode == 400) {
        // Registration failed due to validation errors
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Registration failed: Invalid data'),
        ));
      } else {
        // Registration failed for other reasons
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Registration failed. Please try again later.'),
        ));
      }
    } catch (error) {
      // Handle API request error
      // Show an error message or perform error handling
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred. Please try again later.'),
      ));
    }
  }
}
Future<void> registerUser(String username, String email, String password) async {
  try {
    // Check if the username contains the word 'admin'
    if (username.toLowerCase().contains('admin')) {
      print('Username cannot contain the word "admin".');
      // Handle accordingly, e.g., show an error message to the user.
      return;
    }

    // Check if the email is already in use
    final existingUser = await FirebaseAuth.instance
        .fetchSignInMethodsForEmail(email)
        .then((providers) => providers.isNotEmpty);

    if (existingUser) {
      print('Email is already in use.');
      // Handle accordingly, e.g., show an error message to the user.
      return;
    }

    // Create user in Firebase Authentication
    final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // After creating the user, update their display name with the username
    await userCredential.user?.updateProfile(displayName: username);

    // Create user document in Firestore
    await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
      'userId': userCredential.user?.uid,
      'username': username,
      'email': email,
    });
   // Navigator.of(context).pushNamed("/login");
  } catch (e) {
    print('Error during registration: $e');
    // Handle registration failure, e.g., show an error message to the user.
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
                                  Navigator.of(context).pushNamed("login");
                                  setState(() {
                                    currentPageIsSignup = true;
                                  });
                                },
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    color: currentPageIsSignup
                                        ? Color.fromARGB(255, 39, 26, 99) 
                                        : Color.fromARGB(255, 184, 13, 152), 
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
                                  setState(() {
                                    currentPageIsSignup = false;
                                  });
                                },
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: currentPageIsSignup
                                        ? Color.fromARGB(255, 184, 13, 152) 
                                        : Color.fromARGB(255, 39, 26, 99), 
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
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 50,
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                              filled: true,
                              fillColor: Color.fromARGB(128, 255, 255, 255),
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                color: Color.fromARGB(255, 39, 26, 99),
                                fontSize: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.email,
                                color: Color.fromARGB(255, 39, 26, 99),
                              ),
                              hintText: "username@example.com",
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
                            validator: (value) {
                              if (!EmailValidator.validate(value!)) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          height: 50,
                          child: TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                              filled: true,
                              fillColor: Color.fromARGB(128, 255, 255, 255),
                              labelText: 'Username',
                              labelStyle: TextStyle(
                                color: Color.fromARGB(255, 39, 26, 99),
                                fontSize: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.person,
                                color: Color.fromARGB(255, 39, 26, 99),
                              ),
                              hintText: "Username",
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
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Username is required';
                              }
                              // Customize this pattern to your username validation requirements.
                              final usernamePattern = r'^[\w-]+$';
                              if (!RegExp(usernamePattern).hasMatch(value!)) {
                                return 'Enter a valid username';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          height: 50,
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
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
                                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
                            validator: (value) {
                              final minLength = 6;
                              final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value!);
                              final hasDigit = RegExp(r'[0-9]').hasMatch(value);

                              if (value.isEmpty) {
                                return 'Password is required';
                              } else if (value.length < minLength) {
                                return 'Password must be at least $minLength characters long';
                              } else if (!hasLetter) {
                                return 'Password must contain at least one letter';
                              } else if (!hasDigit) {
                                return 'Password must contain at least one digit';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
      Container(
        height: 50,
        child: ElevatedButton(
          onPressed: () {
                              registerUser(
                                _usernameController.text.trim(),
                                _emailController.text.trim(),
                                _passwordController.text,
                              );
                              signUp(); 
                            },  // Call the signUp method when the button is pressed
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
                "Sign Up",
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
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

