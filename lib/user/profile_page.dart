import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:masarna/navbar/animatedbar.dart';
import 'package:masarna/navbar/rive_asset.dart';
import 'package:masarna/navbar/rive_utils.dart';
import 'package:masarna/trip/planning.dart';
import 'package:masarna/user/edit_profile.dart';
import 'package:masarna/user/home.dart';
import 'package:masarna/widget/button_widget.dart';
import 'package:rive/rive.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? selectedImage;
  RiveAsset selectedBottomNav = bottomNavs.elementAt(3);

  Future _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
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
            SizedBox(width: 10),
            Text(
              'My Profile',
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
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
          child: Column(
            children: [
              Container(
                height: height * 0.37,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double innerHeight = constraints.maxHeight;
                    double innerWidth = constraints.maxWidth;
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: innerHeight * 0.72,
                            width: innerWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Color.fromARGB(213, 226, 224, 243),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 100,
                                ),
                                Text(
                                  'Lina Dana',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 43, 16, 162),
                                    fontFamily: 'Newsreader',
                                    fontSize: 30,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          'username',
                                          style: TextStyle(
                                            color: Color(0xFFcb6ce6),
                                            fontFamily: 'Dosis',
                                            fontSize: 18,
                                          ),
                                        ),
                                        Text(
                                          'lina@gmail.com',
                                          style: TextStyle(
                                            color: Color(0xFFcb6ce6),
                                            fontFamily: 'Dosis',
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
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
                                            width: innerWidth * 0.45,
                                            height: innerWidth * 0.45,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : ClipOval(
                                          child: Image.asset(
                                            "images/profile2.png",
                                            width: innerWidth * 0.45,
                                            height: innerWidth * 0.45,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 115,
                              right: 100,
                              child: ClipOval(
                                child: Container(
                                  color: Colors.white,
                                  padding: EdgeInsets.all(4),
                                  child: ClipOval(
                                    child: Container(
                                      color: Color.fromARGB(255, 43, 16, 162),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Color.fromARGB(255, 255, 255, 255),
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).push(MaterialPageRoute(
                                              builder: (context) => EditProfile()));
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
                height: height * 0.4,
                width: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Color.fromARGB(213, 226, 224, 243),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Add your Friends button logic here
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromARGB(213, 226, 224, 243), // Set your desired button color
                          onPrimary: Color.fromARGB(255, 39, 26, 99), // Set your desired text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 115, vertical: 16), // Adjust the padding
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max, // Adjust the mainAxisSize as needed
                          children: [
                            Icon(Icons.people_alt_outlined),
                            SizedBox(width: 8), // Add space between icon and text
                            Text('Friends'),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Add your Friends button logic here
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromARGB(213, 226, 224, 243), // Set your desired button color
                          onPrimary: Color.fromARGB(255, 39, 26, 99), // Set your desired text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 115, vertical: 16), // Adjust the padding
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // Adjust the mainAxisSize as needed
                          children: [
                            Icon(Icons.favorite_border),
                            SizedBox(width: 8), // Add space between icon and text
                            Text('Favorites'),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Add your Friends button logic here
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromARGB(213, 226, 224, 243), // Set your desired button color
                          onPrimary: Color.fromARGB(255, 39, 26, 99), // Set your desired text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 115, vertical: 16), // Adjust the padding
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max, // Adjust the mainAxisSize as needed
                          children: [
                            Icon(AntDesign.logout),
                            SizedBox(width: 8), // Add space between icon and text
                            Text('Logout'),

                          ],
                        ),
                      ),


                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
          child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 39, 26, 99).withOpacity(0.5),
            borderRadius: BorderRadius.all(Radius.circular(24))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ...List.generate(
              bottomNavs.length,
              (index) => GestureDetector(
                  onTap: () {
                    bottomNavs[index].input!.change(true);
                    if (bottomNavs[index] != selectedBottomNav) {
                      setState(() {
                        if (index == 0) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Home(),
                          ));
                        } else if (index == 1) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Home(),
                          ));
                        } else if (index == 2) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Planning(),
                          ));
                        } else if (index == 3) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ProfileScreen(),
                          ));
                        }
                        selectedBottomNav = bottomNavs[index];
                      });
                    }
                    Future.delayed(const Duration(seconds: 1), () {
                      bottomNavs[index].input!.change(false);
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBar(
                          isActive: bottomNavs[index] == selectedBottomNav),
                      SizedBox(
                          height: 36,
                          width: 36,
                          child: Opacity(
                            opacity: bottomNavs[index] == selectedBottomNav
                                ? 1
                                : 0.5,
                            child: RiveAnimation.asset(
                              bottomNavs.first.src,
                              artboard: bottomNavs[index].artboard,
                              onInit: (artboard) {
                                StateMachineController controller =
                                    RiveUtils.getRiveController(artboard,
                                        StateMachineName:
                                            bottomNavs[index].stateMachineName);
                                bottomNavs[index].input =
                                    controller.findSMI("active") as SMIBool;
                              },
                            ),
                          ))
                    ],
                  )),
            ),
          ],
        ),
      )),

    );
  }
}
