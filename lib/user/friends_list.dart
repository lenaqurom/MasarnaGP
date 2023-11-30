import 'dart:async';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FriendsListPage extends StatefulWidget {
  @override
  _FriendsListPageState createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  final String userAccountFirstName = "Lina";

  List<Friend> friends = [
    Friend(name: 'John Doe', imageUrl: 'https://placekitten.com/100/100'),
    Friend(name: 'Jane Smith', imageUrl: 'https://placekitten.com/101/101'),
    Friend(name: 'Robert Johnson', imageUrl: 'https://placekitten.com/102/102'),
    Friend(name: 'Emily Davis', imageUrl: 'https://placekitten.com/103/103'),
    Friend(name: 'Michael Brown', imageUrl: 'https://placekitten.com/104/104'),
    Friend(name: 'Amanda Miller', imageUrl: 'https://placekitten.com/105/105'),
    Friend(name: 'David Wilson', imageUrl: 'https://placekitten.com/106/106'),
    Friend(
        name: 'Olivia Anderson', imageUrl: 'https://placekitten.com/107/107'),
    Friend(
        name: 'Christopher Taylor',
        imageUrl: 'https://placekitten.com/108/108'),
    Friend(name: 'Sophia White', imageUrl: 'https://placekitten.com/109/109'),
  ];

  List<Friend> friendRequests = [
    Friend(name: 'Requester 1', imageUrl: 'https://placekitten.com/110/110'),
    Friend(name: 'Requester 2', imageUrl: 'https://placekitten.com/111/111'),
    Friend(name: 'Requester 3', imageUrl: 'https://placekitten.com/112/112'),
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
  void initState() {
    super.initState();

    // Set the default tab to show all friends
    filterFriends('');

    // Listen for changes in the search input
    searchControllerStream.stream.listen((query) {
      filterFriends(query);
    });
  }

  @override
  void dispose() {
    // Close the stream controller when the widget is disposed
    searchControllerStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${userAccountFirstName}'s Friends",
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
          // Add the search input to the stream for real-time updates
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
        onDelete: () {
          setState(() {
            friendRequests.remove(requestList[index]);
            filteredRequestsList.remove(requestList[index]);
          });
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
    btnOkOnPress: () {
      // Mark the user as unfriended without removing them immediately
      setState(() {
        unfriendedUsers.add(friendList[index]);
      });
    },
  )..show();
}

  void _onButtonPressed(bool showAll) {
    setState(() {
      showAllFriends = showAll;
      // Clear the search field when switching between tabs
      searchController.clear();
      // Reset the friends list based on the current tab
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

  void _acceptRequest(Friend request) {
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
    });

    // Delay the removal from the request list
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        // Remove the accepted friend from the filteredRequestsList
        filteredRequestsList.remove(request);
      });
    });
  }
}

class Friend {
  final String name;
  final String imageUrl;

  Friend({required this.name, required this.imageUrl});
}

class FriendListItem extends StatelessWidget {
  final Friend friend;
  final VoidCallback onUnfriend;

  const FriendListItem({required this.friend, required this.onUnfriend});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Add logic for when the entire item is tapped
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40.0,
              backgroundImage: NetworkImage(friend.imageUrl),
            ),
            SizedBox(width: 16.0),
            Text(
              friend.name,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                  fontSize: 20),
            ),
            Spacer(), // Add Spacer widget to push PopupMenuButton to the end
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
        // Add logic for when the entire item is tapped
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40.0,
              backgroundImage: NetworkImage(widget.request.imageUrl),
            ),
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
                  SizedBox(height: 8.0), // Add some vertical spacing
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
                            width: 8.0), // Add some spacing between buttons
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Request accepted"),
        duration: Duration(seconds: 2),
      ),
    );

    setState(() {
      requestAccepted = true;
    });

    Future.delayed(Duration(seconds: 2), () {
      widget.onDelete();

      if (requestAccepted) {
        widget.onAccept(widget.request);

        setState(() {
          requestAccepted = false;
        });
      }
    });
  }
}
