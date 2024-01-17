import 'dart:async';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:masarna/globalstate.dart';
import 'package:provider/provider.dart';

class FriendsListPage extends StatefulWidget {
  @override
  _FriendsListPageState createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  //final String userAccountFirstName = "Lina";

  List<Friend> friends = [];

  @override
  void initState() {
    super.initState();
    filterFriends('');
    fetchFriendsData();
    fetchFriendreqsData();
    searchControllerStream.stream.listen((query) {
      filterFriends(query);
    });
        _onButtonPressed(true);
  }

  Future<void> fetchFriendsData() async {
    String id = Provider.of<GlobalState>(context, listen: false).id;
    final url = 'http://192.168.1.11:3000/api/friendslist/$id';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          friends =
              data.map((friendData) => Friend.fromJson(friendData)).toList();
        filteredFriendsList = List.from(friends); 

        });
      } else {
        print('Failed to load friends list');
      }
    } catch (error) {
      print('Error fetching friends list: $error');
    }
  }

   Future<void> fetchFriendreqsData() async {
    String id = Provider.of<GlobalState>(context, listen: false).id;
    final url = 'http://192.168.1.11:3000/api/requests/$id';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          friendRequests =
              data.map((friendData) => Friend.fromJson(friendData)).toList();
        });
      } else {
        print('Failed to load friend requests list');
      }
    } catch (error) {
      print('Error fetching friends list: $error');
    }
  }

  List<Friend> friendRequests = [
  ];

  List<Friend> filteredFriendsList = [];
  List<Friend> filteredRequestsList = [];
  List<Friend> acceptedFriendRequests = [];
  Set<Friend> unfriendedUsers = Set<Friend>();

  List<Friend> filterList(List<Friend> originalList, String query) {
    return originalList
        .where(
            (friend) => friend.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  bool showAllFriends = true;
  TextEditingController searchController = TextEditingController();
  StreamController<String> searchControllerStream =
      StreamController<String>.broadcast();

  @override
  void dispose() {
    searchControllerStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Friends',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 39, 26, 99),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromARGB(255, 39, 26, 99),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 20,
              ),
              _buildButton('All', onPressed: () => _onButtonPressed(true)),
              SizedBox(width: 8),
              _buildButton('Requests',
                  onPressed: () => _onButtonPressed(false)),
            ],
          ),
          SizedBox(height: 8.0),
          _buildSearchField(),
          SizedBox(height: 8.0),
          Expanded(
            child: showAllFriends
                ? _buildFriendsList(filteredFriendsList)
                : _buildRequestsList(filteredRequestsList),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, {required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Color.fromARGB(213, 226, 224, 243),
        onPrimary: Color.fromARGB(255, 39, 26, 99),
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(color: Color.fromARGB(255, 39, 26, 99), width: 1.0),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 16.0,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
        ),
        onChanged: (value) {
          searchControllerStream.add(value);
        },
      ),
    );
  }

  Widget _buildFriendsList(List<Friend> friendList) {
    return ListView.builder(
      itemCount: friendList.length,
      itemBuilder: (context, index) {
        if (unfriendedUsers.contains(friendList[index])) {
          return Container();
        }

        return FriendListItem(
          friend: friendList[index],
          onUnfriend: () {
            showUnfriendConfirmationDialog(context, index, friendList);
          },
        );
      },
    );
  }

  Widget _buildRequestsList(List<Friend> requestList) {
    return ListView.builder(
      itemCount: requestList.length,
      itemBuilder: (context, index) {
        return RequestListItem(
          request: requestList[index],
          onDelete: () async {
             final id = Provider.of<GlobalState>(context, listen: false).id;
    try {
        print(id + '----' + requestList[index].id);
        final response = await http.post(
          Uri.parse('http://192.168.1.11:3000/api/deleterequest/senderId'),
          headers: {
            'Content-Type':
                'application/json', 
          },
          body: jsonEncode({
            'userId': id,
            'senderId': requestList[index].id,
          }),
        );
        if (response.statusCode == 200) {
          print('deleted successfully');
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Deleted successfully'),
        ));
           setState(() {
              friendRequests.remove(requestList[index]);
              filteredRequestsList.remove(requestList[index]);
            });
          
        } else {
          print('Error deleting friend request: ${response}');
        }
      } catch (error) {
        print('Error deleting friend request: $error');
      }
           
          },
          onAccept: (Friend friend) {
            _acceptRequest(friend);
          },
        );
      },
    );
  }

  void showUnfriendConfirmationDialog(
      BuildContext context, int index, List<Friend> friendList) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.WARNING,
      animType: AnimType.BOTTOMSLIDE,
      title: 'Unfriend Confirmation',
      desc: 'Are you sure you want to unfriend ${friendList[index].name}?',
      descTextStyle: TextStyle(
        color: Colors.black87,
        fontSize: 16.0,
        fontWeight: FontWeight.normal,
        fontFamily: 'Montserrat',
      ),
      btnCancelColor: Colors.grey,
      btnOkColor: Color.fromARGB(255, 39, 26, 99),
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
            final id = Provider.of<GlobalState>(context, listen: false).id;

        try {
        print(id + '----' + friendList[index].id);
        final response = await http.post(
          Uri.parse('http://192.168.1.11:3000/api/unfriend'),
          headers: {
            'Content-Type':
                'application/json',
          },
          body: jsonEncode({
            'userId': id,
            'friendId': friendList[index].id,
          }),
        );
        if (response.statusCode == 200) {
          print('unfriended successfully');
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Unfriended successfully'),
        ));
          setState(() {
          unfriendedUsers.add(friendList[index]);
        });
        } else {
          print('Error unfriending: ${response.statusCode}');
        }
      } catch (error) {
        print('Error unfriending: $error');
      }
        
      },
    )..show();
  }

  void _onButtonPressed(bool showAll) {
    setState(() {
      showAllFriends = showAll;
      searchController.clear();
      filterFriends('');
    });
  }

  void filterFriends(String query) {
    setState(() {
      if (showAllFriends) {
        filteredFriendsList = filterList(friends, query);
      } else {
        filteredRequestsList = filterList(friendRequests, query);
      }
    });
  }

  void _acceptRequest(Friend request) async {
        final id = Provider.of<GlobalState>(context, listen: false).id;

    try {
        print('in friend');
        final response = await http.post(
          Uri.parse('http://192.168.1.11:3000/api/friend'),
          headers: {
            'Content-Type':
                'application/json', 
          },
          body: jsonEncode({
            'userId': id,
            'senderId': request.id,
          }),
        );
        if (response.statusCode == 200) {
          print('friend request accepted successfully');
          ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Request accepted"),
        duration: Duration(seconds: 2),
      ),
    );

    setState(() {
      acceptedFriendRequests.add(request);
      friends.add(request);
      friendRequests.remove(request);
      filteredRequestsList.remove(request);

    });
          
        } else {
          print('Error accepting friend request: ${response}');
        }
      } catch (error) {
        print('Error accepting friend request: $error');
      }
    
  }
}

class Friend {
  final String id;
  final String name;
  final String imageUrl;

  Friend({required this.id, required this.name, required this.imageUrl});

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['_id'],
      name: json['username'],
      imageUrl: json['profilepicture'],
    );
  }
}

class FriendListItem extends StatelessWidget {
  final Friend friend;
  final VoidCallback onUnfriend;

  const FriendListItem({required this.friend, required this.onUnfriend});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40.0,
              backgroundImage: NetworkImage('http://192.168.1.11:3000/' +
                  friend.imageUrl.replaceAll('\\', '/')),
            ),
            SizedBox(width: 16.0),
            Text(
              friend.name,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                  fontSize: 20),
            ),
            Spacer(), 
            PopupMenuButton<String>(
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'unfriend',
                  child: ListTile(
                    leading: Icon(Icons.person_remove,
                        color: Color.fromARGB(255, 39, 26, 99)),
                    title: Text('Unfriend ${friend.name}'),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'message',
                  child: ListTile(
                    leading: Icon(FontAwesomeIcons.facebookMessenger,
                        color: Color.fromARGB(255, 39, 26, 99)),
                    title: Text('Message ${friend.name}'),
                  ),
                ),
              ],
              onSelected: (String value) {
                if (value == 'unfriend') {
                  onUnfriend();
                }
                if (value == 'message') {
                 Navigator.of(context).pushNamed('/chatlist');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RequestListItem extends StatefulWidget {
  final Friend request;
  final VoidCallback onDelete;
  final Function(Friend) onAccept;

  const RequestListItem(
      {required this.request, required this.onDelete, required this.onAccept});

  @override
  _RequestListItemState createState() => _RequestListItemState();
}

class _RequestListItemState extends State<RequestListItem> {
  bool requestAccepted = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40.0,
              backgroundImage: NetworkImage('http://192.168.1.11:3000/' +
                   widget.request.imageUrl.replaceAll('\\', '/')),),
            
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.request.name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                        fontSize: 20),
                  ),
                  SizedBox(height: 8.0),
                  if (!requestAccepted)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _acceptRequest();
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Color.fromARGB(255, 39, 26, 99),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text("Confirm"),
                          ),
                        ),
                        SizedBox(
                            width: 8.0), 
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              widget.onDelete();
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text("Delete"),
                          ),
                        ),
                      ],
                    ),
                  if (requestAccepted)
                    Text(
                      "Request Accepted",
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _acceptRequest() {
   

    setState(() {
      requestAccepted = true;
    });

   // Future.delayed(Duration(seconds: 1), () {

      if (requestAccepted) {
        widget.onAccept(widget.request);

        setState(() {
          requestAccepted = false;
        });
      }
   // });
  }
}
