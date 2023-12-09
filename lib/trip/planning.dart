import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:masarna/navbar/BottomNavBar.dart';
import 'package:masarna/navbar/animatedbar.dart';
import 'package:masarna/navbar/rive_asset.dart';
import 'package:masarna/navbar/rive_utils.dart';
import 'package:masarna/trip/PlanSearch.dart';
import 'package:masarna/trip/homesection.dart';
import 'package:masarna/user/home.dart';
import 'package:masarna/user/makeprofile.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import '../api/apiservice.dart';
import 'package:masarna/globalstate.dart';

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
  String planid = '';

  final apiService = ApiService('http://192.168.1.7:3000/api');

  @override
  void initState() {
    String id = Provider.of<GlobalState>(context, listen: false).id;
    super.initState();
    viewPlans(id);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> postPlan() async {
    final name = titleController.text;
    final description = descriptionController.text;
    String id = Provider.of<GlobalState>(context, listen: false).id;

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.7:3000/api/oneplan'),
      );

      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['userid'] = id;

      if (selectedImage != null) {
        var file = await http.MultipartFile.fromPath(
          'image',
          selectedImage!.path,
        );
        request.files.add(file);
      }

      // Print the request body for debugging
      print('Request Body: ${request.fields}');

      var response = await request.send();

      if (response.statusCode == 201) {
        // Handle successful update

        // Reload the page by pushing a new instance of the Planning widget
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Planning()),
        );
      }

      // Print the response for debugging
      print('Response: ${response.statusCode}');
      print('Response Body: ${await response.stream.bytesToString()}');
      
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred. Please try again later.'),
      ));
    }
  }

  Future<void> viewPlans(String userid) async {
    try {



      final response = await http.get(
        Uri.parse('http://192.168.1.7:3000/api/userplans/$userid'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('plans')) {
          List<dynamic> userPlansData = responseData['plans'];
         
          List<Plan> fetchedPlans = userPlansData
              .map((planData) => Plan(
                    id: planData['_id'],
                    title: planData['name'],
                    description: planData['description'],
                    image:'http://192.168.1.7:3000/' + planData['image'].replaceAll('\\', '/'),
              ))    
              .toList();

          setState(() {
            plans = fetchedPlans;
          });
        } else {
          print('Error: Response data format is not as expected.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to fetch plans. Please try again.'),
              backgroundColor: Colors.red, // You can customize the color
            ),
          );
        }
      } else {
        print('Error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch plans. Please try again.'),
            backgroundColor: Colors.red, // You can customize the color
          ),
        );
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error. Please check your connection.'),
          backgroundColor: Colors.red, // You can customize the color
        ),
      );
    }
  }

  Future<void> deletePlanapi(String planid) async {
    try {
      var response = await http.delete(
        Uri.parse('http://192.168.1.9:3000/api/oneplan/$planid'),
      );

      if (response.statusCode == 200) {
        // Handle successful deletion
        print('Plan deleted successfully');

        // Remove the deleted plan from the local list
        setState(() {
          plans.removeWhere((plan) => plan.id == planid);
        });
      } else if (response.statusCode == 404) {
        // Handle plan not found
        print('Plan not found');
      } else {
        // Handle other error responses
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle network errors
      print('Error: $error');
    }
  }

  Future<void> putPlan(String planid) async {
    final name = titleController.text;
    final description = descriptionController.text;

    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('http://192.168.1.9:3000/api/oneplan/$planid'),
      );

      request.fields['name'] = name;
      request.fields['description'] = description;

      if (selectedImage != null) {
        var file = await http.MultipartFile.fromPath(
          'image',
          selectedImage!.path,
        );
        request.files.add(file);
      }

      // Print the request before sending for debugging
      print('Request Body: ${request.fields}');

      var response = await request.send();

      // Print the response for debugging
      print('Response: ${response.statusCode}');
      print('Response Body: ${await response.stream.bytesToString()}');

      if (response.statusCode == 200) {
        // Handle successful update
        print('Plan updated successfully');
         Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Planning()),
        );

        // Update the local list with the new plan details
        setState(() {
          var updatedPlan = plans.firstWhere((plan) => plan.id == planid);
          updatedPlan.title = name;
          updatedPlan.description = description;
          updatedPlan.image = selectedImage!.path;
        });
      } else if (response.statusCode == 404) {
        // Handle plan not found
        print('Plan not found');
      } else {
        // Handle other error responses
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle network errors
      print('Error: $error');
    }
  }

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
      btnCancelOnPress: () {
        titleController.clear();
        descriptionController.clear();
        selectedImage = null;
        selectedPlanIndex = null;
      },
      btnOkText: "Add",
      btnOkIcon: Icons.add,
      btnOkColor: Color.fromARGB(255, 39, 26, 99),
      btnOkOnPress: () {
        if (selectedPlanIndex == null) {
          // setState(() {
          //  plans.add(Plan(
          //   title: titleController.text,
          //   description: descriptionController.text,
          //   image: selectedImage,
          // ));
          // });
          postPlan();
        } else {
          //setState(() {
          //  plans[selectedPlanIndex!] = Plan(
          //   title: titleController.text,
          //   description: descriptionController.text,
          //  image: selectedImage,
          // );
          // });
          putPlan(planid);
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
  planid = plans[index].id;
  titleController.text = plans[index].title;
  descriptionController.text = plans[index].description;

  // Check if the image is a File or a network URL
  if (plans[index].image is File) {
    // If it's a File, directly assign it to selectedImage
    selectedImage = plans[index].image as File?;
  } else if (plans[index].image is String) {
    // If it's a network URL, you might want to load the image using Image.network
    // However, since the image is stored on the server, there's no need to load it here
  }

  addPlan();  // Open the addPlan dialog
}



  void deletePlan(int index) {
    planid = plans[index].id;
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
          deletePlanapi(planid);
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
                         builder: (context) => SectionsPage(planId:plans[index].id),
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
            image: NetworkImage(plans[index].image!),
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
            child:
                Text('${plans.length} Plans', style: TextStyle(fontSize: 15)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addPlan,
        child: Icon(
          Icons.add,
        ),
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
