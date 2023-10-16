import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:masarna/user/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Planning(),
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 39, 26, 99),
        hintColor: Color.fromARGB(255, 39, 26, 99),
      ),
    );
  }
}

class Planning extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Planning> {
  List<Plan> plans = [];
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  File? selectedImage;
  int? selectedPlanIndex;
  int _currentIndex = 1;

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
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 39, 26, 99)),
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
                  borderSide: BorderSide(color: Color.fromARGB(255, 39, 26, 99)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 39, 26, 99)),
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
                  borderSide: BorderSide(color: Color.fromARGB(255, 39, 26, 99)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 39, 26, 99)),
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
                  scrollDirection: Axis.horizontal, // Enable horizontal scrolling if needed
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
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Your Plans',
          style: TextStyle(
            color: Color.fromARGB(255, 39, 26, 99),
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              FontAwesomeIcons.search,
              color: Color.fromARGB(255, 39, 26, 99),
            ),
            onPressed: () {
              showSearch(
                context: context,
                delegate: PlanSearch(plans),
              );
            },
          ),
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
            bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        fixedColor: Color.fromARGB(255, 39, 26, 99), 
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Color.fromARGB(255, 39, 26, 99),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.edit_document,
              color: Color.fromARGB(255, 39, 26, 99),
            ),
            label: 'Planning',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.notifications,
              color: Color.fromARGB(255, 39, 26, 99),
            ),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: Color.fromARGB(255, 39, 26, 99),
            ),
            label: 'Profile',
          ),
        ],
      ),

    );
  }
}

class PlanSearchResults extends StatelessWidget {
  final List<Plan> searchResults;

  PlanSearchResults(this.searchResults);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final plan = searchResults[index];
        return InkWell(
          onTap: () {
        Navigator.of(context).pushNamed("path");
          },
          child: ListTile(
            title: Text(plan.title),
            subtitle: Text(plan.description),
        ));
      },
    );
  }
}

class Plan {
  String title;
  String description;
  File? image;

  Plan({
    required this.title,
    required this.description,
    this.image,
  });
}

class PlanSearch extends SearchDelegate<String> {
  final List<Plan> plans;

  PlanSearch(this.plans);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, query);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = plans.where((plan) {
      return plan.title.contains(query) || plan.description.contains(query);
    }).toList();

    return PlanSearchResults(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = plans
        .where((plan) => plan.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestionList[index].title),
          onTap: () {
            query = suggestionList[index].title;
            showResults(context);
          },
        );
      },
    );
  }
}

class PlanDetailScreen extends StatelessWidget {
  final Plan plan;

  PlanDetailScreen(this.plan);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plan.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Title: ${plan.title}'),
          Text('description: ${plan.description}'),
        ],
      ),
    );
  }
}
