import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class User {
  final String username;
  final String imagePath;

  User(this.username, this.imagePath);
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
          backgroundImage: AssetImage(widget.user.imagePath),
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

class UserListDialog extends StatefulWidget {
  final List<User> userList;
  final Set<String> selectedUserIds;

  UserListDialog({required this.userList, required this.selectedUserIds});

  @override
  _UserListDialogState createState() => _UserListDialogState();
}

class _UserListDialogState extends State<UserListDialog> {
  bool selectAll = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Add Friends",
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, fontFamily: 'Dosis'),
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
              style: TextStyle(fontSize: 16.0, fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.bold, color: Color.fromARGB(255, 39, 26, 99),),
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
            final bool isSelected = widget.selectedUserIds.contains(user.username);
            final bool isDisabled = isSelected; // Disable checkbox for already selected users
            return UserListItem(
              user: user,
              isSelected: isSelected,
              onSelected: (isSelected) {
                setState(() {
                  if (!isDisabled) {
                    if (isSelected) {
                      widget.selectedUserIds.add(user.username);
                    } else {
                      widget.selectedUserIds.remove(user.username);
                    }
                  }
                  selectAll = widget.selectedUserIds.length == widget.userList.length;
                });
              },
              isDisabled: isDisabled,
            );
          },
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            // Pass the selected user IDs back to the caller
            Navigator.of(context).pop(widget.selectedUserIds.toList());
          },
          style: ElevatedButton.styleFrom(
            primary: Color.fromARGB(255, 39, 26, 99),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          child: Text(
            'OK',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, fontFamily: 'PlayfairDisplay'),
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
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, fontFamily: 'PlayfairDisplay'),
          ),
        ),
      ],
    );
  }
}

class AddParticipantsPage extends StatefulWidget {
  @override
  _AddParticipantsPageState createState() => _AddParticipantsPageState();
}

class _AddParticipantsPageState extends State<AddParticipantsPage> {
  List<User> userList = [
    User('User1', 'images/profile.png'),
    User('User2', 'images/profile.png'),
    User('User3', 'images/profile.png'),
    User('User4', 'images/profile.png'),
    User('User5', 'images/profile.png'),
    User('User6', 'images/profile.png'),
    User('User7', 'images/profile.png'),
    User('User8', 'images/profile.png'),
    User('User9', 'images/profile.png'),
    User('User10', 'images/profile.png'),
    User('User11', 'images/profile.png'),
    User('User12', 'images/profile.png'),
    User('User13', 'images/profile.png'),
    // Add more dummy users as needed
  ];

  Set<String> selectedUserIds = {};

  void _showAddUsersDialog() async {
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

  void _removeUser(String userId) {
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
      btnOkOnPress: () {
        setState(() {
          selectedUserIds.remove(userId);
        });
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Dosis', fontSize: 22.0, color: Color.fromARGB(255, 39, 26, 99),),
                ),
                MaterialButton(
                  onPressed: _showAddUsersDialog,
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
              itemCount: selectedUserIds.length,
              itemBuilder: (context, index) {
                final String userId = selectedUserIds.elementAt(index);
                final User user = userList.firstWhere((user) => user.username == userId);
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(user.imagePath),
                    ),
                    title: Text(
                      user.username,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),
                    trailing: IconButton(
                      icon: Icon(AntDesign.delete),
                      onPressed: () {
                        _removeUser(userId);
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

void main() {
  runApp(MaterialApp(
    home: AddParticipantsPage(),
  ));
}
