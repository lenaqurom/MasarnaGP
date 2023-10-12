import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dropdown_search/dropdown_search.dart';

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

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, 
        title: Text(
          'Masarna',
          style: TextStyle(
            color: Color.fromARGB(
                255, 39, 26, 99), 
            fontWeight: FontWeight.bold,
            fontSize: 30,
            fontFamily: 'DancingScript',
          ),
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
            onPressed: () {

            },
          ),
        ],
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
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
