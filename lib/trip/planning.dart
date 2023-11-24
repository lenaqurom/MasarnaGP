import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:masarna/navbar/BottomNavBar.dart';
import 'package:masarna/navbar/animatedbar.dart';
import 'package:masarna/navbar/rive_asset.dart';
import 'package:masarna/navbar/rive_utils.dart';
import 'package:masarna/trip/PlanSearch.dart';
import 'package:masarna/user/home.dart';
import 'package:masarna/user/makeprofile.dart';
import 'package:rive/rive.dart';

class Planning extends StatefulWidget {
  const Planning({super.key});

  @override
  State<Planning> createState() => _PlanningState();
}

class _PlanningState extends State<Planning> {
  RiveAsset selectedBottomNav = bottomNavs.elementAt(2);
  List<Plan> plans = [];
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  File? selectedImage;
  int? selectedPlanIndex;

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  void addPlan() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.BOTTOMSLIDE,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "Add a Plan",
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 39, 26, 99)),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 39, 26, 99)),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 39, 26, 99)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 39, 26, 99)),
                  ),
                ),
                maxLength: 20,
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 39, 26, 99)),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 39, 26, 99)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 39, 26, 99)),
                  ),
                ),
                maxLength: 50,
                maxLines: 3,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Select image for your plan"),
                Container(
                  height: 50.0, // Set the maximum height for the image
                  child: SingleChildScrollView(
                    scrollDirection: Axis
                        .horizontal, // Enable horizontal scrolling if needed
                    child: Row(
                      children: [
                        if (selectedImage != null)
                          Image.file(selectedImage!, height: 100.0),
                        IconButton(
                          onPressed: pickImage,
                          icon: Icon(FontAwesomeIcons.image),
                          color: Color.fromARGB(255, 39, 26, 99),
                        ),
                        // You can add more image selection widgets here
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      btnCancelText: "Cancel",
      btnCancelIcon: Icons.cancel,
      btnCancelColor: Color.fromARGB(255, 39, 26, 99),
      btnCancelOnPress: () {},
      btnOkText: "Add",
      btnOkIcon: Icons.add,
      btnOkColor: Color.fromARGB(255, 39, 26, 99),
      btnOkOnPress: () {
        if (selectedPlanIndex == null) {
          setState(() {
            plans.add(Plan(
              title: titleController.text,
              description: descriptionController.text,
              image: selectedImage,
            ));
          });
        } else {
          setState(() {
            plans[selectedPlanIndex!] = Plan(
              title: titleController.text,
              description: descriptionController.text,
              image: selectedImage,
            );
          });
        }
        titleController.clear();
        descriptionController.clear();
        selectedImage = null;
        selectedPlanIndex = null;
      },
    )..show();
  }

  void editPlan(int index) {
    selectedPlanIndex = index;
    titleController.text = plans[index].title;
    descriptionController.text = plans[index].description;
    selectedImage = plans[index].image;
    addPlan();
  }

  void deletePlan(int index) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.WARNING,
      animType: AnimType.SCALE,
      body: Center(
        child: Text(
          'Are you sure you want to delete this plan?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        setState(() {
          plans.removeAt(index);
        });
      },
    )..show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 39, 26, 99).withOpacity(0.5),
        elevation: 0,
        title: Text(
          'Your Plans',
          style: TextStyle(
            fontFamily: 'Dosis',
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              showSearch(
                context: context,
                delegate: PlanSearch(plans),
              );
            },
            child: SizedBox(
              height: 40,
              width: 40,
              child: RiveAnimation.asset(
                "icons/icons.riv",
                artboard: "SEARCH",
              ),
            ),
          ),
          SizedBox(
            width: 15,
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PlanDetailScreen(plans[index]),
                        ),
                      );
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 120.0,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12.0),
                                topRight: Radius.circular(12.0),
                              ),
                              image: plans[index].image != null
                                  ? DecorationImage(
                                      image: FileImage(plans[index].image!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        plans[index].title,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8.0),
                                      Text(
                                        plans[index].description,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    editPlan(index);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    deletePlan(index);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${plans.length} Plans',
                style: TextStyle(fontSize: 15)),
          ),
          
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addPlan,
        child: Icon(Icons.add,),
        backgroundColor: Color.fromARGB(255, 39, 26, 99),
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
                            builder: (context) => ProfileApp(),
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
