import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:masarna/trip/planning.dart';

void main() {
  runApp(Home());
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InstagramBottomNav(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class InstagramBottomNav extends StatefulWidget {
  @override
  _InstagramBottomNavState createState() => _InstagramBottomNavState();
}

class _InstagramBottomNavState extends State<InstagramBottomNav> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    HomeTab(),
    SearchTab(),
    ProfileTab(),
    TravelTab(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
appBar: AppBar(
  backgroundColor: Colors.white,
  title: Row(
    children: [
      Image.asset(
        'images/logo.png',
        width: 30, // Adjust the width as needed
        height: 30, // Adjust the height as needed
      ),
      SizedBox(width: 10), // Add some spacing between the image and title
    ],
  ),
  elevation: 0,
  actions: [
    IconButton(
      icon: Icon(
        FontAwesomeIcons.search,
        color: Color.fromARGB(255, 39, 26, 99),
      ),
      onPressed: () {
        showSearch(context: context, delegate: DataSearch());
      },
    ),
    IconButton(
      icon: Icon(
        FontAwesomeIcons.facebookMessenger,
        color: Color.fromARGB(255, 39, 26, 99),
      ),
      onPressed: () {},
    ),
  ],
),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        fixedColor:
            Color.fromARGB(255, 39, 26, 99), 
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
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Planning()));
          }else if(index==0){
            Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
          } 
          else {
            setState(() {
              _currentIndex = index;
            });
          }
        },

      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Home Page'),
    );
  }
}

class SearchTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Search Page'),
    );
  }
}

class ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Profile Page'),
    );
  }
}

class TravelTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Travel Page'), 
    );
  }
}

class DataSearch extends SearchDelegate<String> {
  List<String> names = ["wael", "basel", "mohammad", "yaser", "shadi", "mohannad"];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = ''; 
        },
        icon: Icon(Icons.close),
        color: Color.fromARGB(255, 39, 26, 99),
      ),
    ];
  }

@override
Widget buildLeading(BuildContext context) {
  return IconButton(
    onPressed: () {
      close(context, ''); 
    },
    icon: Icon(
      Icons.arrow_back_ios,
      color: Color.fromARGB(255, 39, 26, 99),
    ),
  );
}

  @override
  Widget buildResults(BuildContext context) {
    final searchResults = names
        .where((name) => name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, i) {
        return ListTile(
          title: Text(searchResults[i]),
          onTap: () {

          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = names
        .where((name) => name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, i) {
        return ListTile(
          title: Text(suggestionList[i]),
          onTap: () {
            query = suggestionList[i]; 
          },
        );
      },
    );
  }
}
