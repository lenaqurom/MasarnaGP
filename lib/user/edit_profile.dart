import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:masarna/navbar/animatedbar.dart';
import 'package:masarna/navbar/rive_asset.dart';
import 'package:masarna/navbar/rive_utils.dart';
import 'package:masarna/user/profile_page.dart';
import 'package:masarna/widget/button_widget.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  File? selectedImage;
  RiveAsset selectedBottomNav = bottomNavs.elementAt(3);

  Future _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  void showBackConfirmationDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.WARNING,
      animType: AnimType.SCALE,
      title: 'Warning!',
      desc: 'You have unsaved changes. Are you sure you want to go back?',
      btnCancelText: 'Cancel',
      btnCancelColor: Colors.red,
      btnCancelOnPress: () {},
      btnOkText: 'Go Back',
      btnOkOnPress: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ProfileScreen()));
      },
    )..show();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back arrow button
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
          IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromARGB(255, 39, 26, 99),
          ),
          onPressed: () {
            showBackConfirmationDialog(context);
          },
        ),
            Text(
              'Edit your Profile',
              style: TextStyle(
                fontFamily: 'Dosis',
                color: Color.fromARGB(255, 43, 16, 162),
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
          child: Column(
            children: [
              Container(
                height: height * 0.38,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double innerHeight = constraints.maxHeight;
                    double innerWidth = constraints.maxWidth;
                    return Stack(
                      children: [
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: innerHeight * 0.80,
                            width: innerWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Color.fromARGB(213, 226, 224, 243),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 80,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: 200), // Add padding to the left
                                  child: Text(
                                    'Full Name',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 43, 16, 162),
                                      fontFamily: 'Dosis',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  width: 300,
                                  height: 45,
                                  child: TextField(
                                    style: TextStyle(
                                        fontSize: 18, fontFamily: 'Dosis'),
                                    decoration: InputDecoration(
                                      labelText: 'Your Full Name',
                                      hintStyle: TextStyle(
                                        fontFamily: 'Dosis',
                                        color: Color.fromARGB(255, 43, 16, 162),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color.fromARGB(255, 43, 16, 162),
                                            width: 2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Stack(
                          children: [
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: selectedImage != null
                                      ? ClipOval(
                                          child: Image.file(
                                            selectedImage!,
                                            width: innerWidth * 0.37,
                                            height: innerWidth * 0.37,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : ClipOval(
                                          child: Image.asset(
                                            "images/profile2.png",
                                            width: innerWidth * 0.37,
                                            height: innerWidth * 0.37,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            Positioned(
                                bottom: 140,
                                right: 110,
                                child: ClipOval(
                                  child: Container(
                                      color: Colors.white,
                                      padding: EdgeInsets.all(4),
                                      child: ClipOval(
                                          child: Container(
                                        color: Color.fromARGB(255, 43, 16, 162),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.add_a_photo,
                                            color: Color.fromARGB(255, 255, 255, 255),
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            _pickImageFromGallery();
                                          },
                                        ),
                                      ))),
                                )),
                          ],
                        )
                      ],
                    );
                  },
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed("profilescreen");
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
                        "Save",
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 22,
                            letterSpacing: 1.5,
                            fontFamily: 'Dosis',
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
