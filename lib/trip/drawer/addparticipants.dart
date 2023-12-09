import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:masarna/globalstate.dart';
import 'package:provider/provider.dart';

class User {
  final String username;
  final String id;
  final String? imagePath;

  User(this.username, this.id, this.imagePath);
}

class UserListItem extends StatefulWidget {
  final User user;
  final bool isSelected;
  final Function(bool) onSelected;
  final bool isDisabled;

  UserListItem({
    required this.user,
    required this.isSelected,
    required this.onSelected,
    this.isDisabled = false,
  });

  @override
  _UserListItemState createState() => _UserListItemState();
}

class _UserListItemState extends State<UserListItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.0),
        leading: CircleAvatar(
          radius: 24.0,
          // Use a conditional expression to check if imagePath is not null
          backgroundImage: widget.user.imagePath != null
              ? NetworkImage(widget.user.imagePath!)
              : null,
        ),
        title: Text(
          widget.user.username,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        trailing: Checkbox(
          value: widget.isSelected,
          onChanged: widget.isDisabled
              ? null
              : (isSelected) {
                  setState(() {
                    widget.onSelected(isSelected ?? false);
                  });
                },
        ),
      ),
    );
  }
}

class AddParticipantsPage extends StatefulWidget {
  @override
  _AddParticipantsPageState createState() => _AddParticipantsPageState();
}

class _AddParticipantsPageState extends State<AddParticipantsPage> {
  List<User> userList = [];
  Set<String> selectedUserIds = {};
  List<User> addedMembers = [];

  @override
  void initState() {
    super.initState();

    // Fetch and set the initial state of addedMembers
    fetchMembers('65720ce9bbfa2f36ed8dd5f5').then((members) {
      if (members != null) {
        setState(() {
          addedMembers = members;
        });
      } else {
        print('Initial members list is null.');
      }
    }).catchError((error) {
      print('Error fetching initial members: $error');
    });
  }

  Future<List<User>> fetchFriendList(String userId) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.7:3000/api/memberstoadd/$userId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((friend) {
        return User(
          friend['username'],
          friend['_id'],
          'http://192.168.1.7:3000/' +
              friend['profilepicture'].replaceAll('\\', '/'),
        );
      }).toList();
    } else {
      throw Exception('Failed to load friend list');
    }
  }

  Future<List<User>> fetchMembers(String planId) async {
    final String baseUrl = 'http://192.168.1.7:3000/api';
    final String endpoint = '/oneplan/$planId/members';

    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['members'];
        return data.map((member) {
          print('Profile Picture: ${member['profilepicture']}');
          return User(
            member['username'],
            member['user'],
            'http://192.168.1.7:3000/' +
                    member['profilepicture'].replaceAll('\\', '/') ??
                null,
          );
        }).toList();
      } else {
        throw Exception('Failed to load members');
      }
    } catch (error) {
      print('Error fetching members: $error');
      throw error;
    }
  }

  /*void _showAddUsersDialog() async {
    List<String>? result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return UserListDialog(
          userList: userList,
          selectedUserIds: selectedUserIds,
        );
      },
    );

    if (result != null) {
      // Update selectedUserIds with both old and newly selected user IDs
      setState(() {
        selectedUserIds.addAll(result);
      });
    }
  }
*/
  void _removeUser(User user) {
    String userId = user.id;
    AwesomeDialog(
      context: context,
      dialogType: DialogType.WARNING,
      headerAnimationLoop: false,
      title: 'Delete Participant',
      desc: 'Are you sure you want to delete this participant?',
      btnCancelOnPress: () {},
      btnCancelColor: Colors.grey,
      btnOkColor: Color.fromARGB(255, 39, 26, 99),
      btnOkText: 'Delete',
      btnOkOnPress: () async {
        try {
          // Make the DELETE request to remove the user from the plan
          String planId = '65720ce9bbfa2f36ed8dd5f5'; // Replace with your actual plan ID
          String url = 'http://192.168.1.7:3000/api/oneplan/$planId/members/$userId';

          final response = await http.delete(Uri.parse(url));

          if (response.statusCode == 200) {
          print('Member deleted successfully');
          // Reload the page without keeping it in the stack
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => AddParticipantsPage(),
            ),
          );
        } else {
          print('Failed to delete member: ${response.statusCode}');
        }
      } catch (error) {
        print('Error deleting member: $error');
      }
    },
    )..show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Participants',
          style: TextStyle(
            fontFamily: 'Dosis',
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
        children: [
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${selectedUserIds.length} Participants',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Dosis',
                    fontSize: 22.0,
                    color: Color.fromARGB(255, 39, 26, 99),
                  ),
                ),
                MaterialButton(
                  onPressed: () async {
                    try {
                      String id =
                          Provider.of<GlobalState>(context, listen: false).id;
                      List<User> friendList = await fetchFriendList(
                          id); // Replace 'USER_ID' with the actual user ID
                      List<String>? result = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return UserListDialog(
                            userList: friendList,
                            selectedUserIds: selectedUserIds,
                          );
                        },
                      );

                      if (result != null) {
                        setState(() {
                          selectedUserIds.addAll(result);
                        });
                      }
                    } catch (e) {
                      print('Error fetching friend list: $e');
                    }
                  },
                  color: Color.fromARGB(255, 39, 26, 99),
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(AntDesign.adduser, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: addedMembers.length,
              itemBuilder: (context, index) {
                //  final String userId = selectedUserIds.elementAt(index);
                final User user = addedMembers[index];
                // userList.firstWhere((user) => user.id == userId, orElse: () {
                // return User('Unknown', 'unknown_id', 'images/profile.png');
                // });
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    leading: CircleAvatar(
                      backgroundImage: user.imagePath != null
                          ? NetworkImage(user.imagePath as String)
                          : null,
                    ),
                    title: Text(
                      user.username,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),
                    trailing: IconButton(
                      icon: Icon(AntDesign.delete),
                      onPressed: () {
                         _removeUser(user);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserListDialog extends StatefulWidget {
  final List<User> userList;
  final Set<String> selectedUserIds;

  UserListDialog({required this.userList, required this.selectedUserIds});

  @override
  _UserListDialogState createState() => _UserListDialogState();
}

class _UserListDialogState extends State<UserListDialog> {
  bool selectAll = false;

  Future<void> addMembers(String planId, List<String> userIds) async {
    final String baseUrl = 'http://192.168.1.7:3000/api';
    final String endpoint = '/oneplan/$planId/members';

    try {
      for (String userId in userIds) {
        final response = await http.post(
          Uri.parse('$baseUrl$endpoint/$userId'),
        );

        if (response.statusCode == 200) {
          print('Member added successfully');
        } else {
          print('Failed to add member: ${response.statusCode}');
        }
      }
// Fetch and update the added members
      //   final List<User> members = await fetchMembers(planId);
      //   setState(() {
      //      addedMembers = members;
      //    });
    } catch (error) {
      print('Error adding members: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Add Friends",
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Dosis'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                selectAll = !selectAll;
                if (selectAll) {
                  widget.selectedUserIds.addAll(
                    widget.userList.map((user) => user.username),
                  );
                } else {
                  widget.selectedUserIds.clear();
                }
              });
            },
            child: Text(
              selectAll ? 'Deselect All' : 'Select All',
              style: TextStyle(
                fontSize: 16.0,
                fontFamily: 'PlayfairDisplay',
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 39, 26, 99),
              ),
            ),
          ),
        ],
      ),
      content: Container(
        height: 200,
        width: 300,
        child: ListView.builder(
          itemCount: widget.userList.length,
          itemBuilder: (context, index) {
            final User user = widget.userList[index];
            final bool isSelected = widget.selectedUserIds.contains(user.id);
            final bool isDisabled =
                isSelected; // Disable checkbox for already selected users
            return UserListItem(
              user: user,
              isSelected: isSelected,
              onSelected: (isSelected) {
                setState(() {
                  if (!isDisabled) {
                    if (isSelected) {
                      widget.selectedUserIds.add(user.id);
                    } else {
                      widget.selectedUserIds.remove(user.id);
                    }
                  }
                  selectAll =
                      widget.selectedUserIds.length == widget.userList.length;
                });
              },
              isDisabled: isDisabled,
              
            );
          },
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () async {
            try {
              await addMembers(
                  '65720ce9bbfa2f36ed8dd5f5', widget.selectedUserIds.toList());
              // Replace 'YOUR_PLAN_ID' with the actual plan ID
            } catch (e) {
              print('Error adding members: $e');
            }
            // Pass the selected user IDs back to the caller
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => AddParticipantsPage(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            primary: Color.fromARGB(255, 39, 26, 99),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          child: Text(
            'OK',
            style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'PlayfairDisplay'),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // Close the dialog without returning selected user IDs
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          child: Text(
            'Cancel',
            style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'PlayfairDisplay'),
          ),
        ),
      ],
    );
  }
}
