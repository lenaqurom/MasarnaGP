import 'package:flutter/material.dart';
import 'package:masarna/user/friends_list.dart';

void main() {
  runApp(MyNotificationApp());
}

class NotificationModel {
  final String type;
  final String userName;
  final String userImage;
  final String? planName; // Nullable planName parameter
  final bool isAccepted; // Add this line

  NotificationModel({
    required this.type,
    required this.userName,
    required this.userImage,
    this.planName, // Include planName in the constructor
    this.isAccepted = false, // Default value is false
  });
}

class MyNotificationApp extends StatelessWidget {
  final List<NotificationModel> notifications = [
    NotificationModel(
        type: "Friend Request",
        userName: "John Doe",
        userImage: "https://placekitten.com/100/100"),
    NotificationModel(
        type: "Friend Accept",
        userName: "Jane Smith",
        userImage: "https://placekitten.com/101/101"),
    NotificationModel(
        type: "Plan Participant",
        userName: "Bob Johnson",
        userImage: "https://placekitten.com/102/102",
        planName: "Antalya"),
    NotificationModel(
        type: "Plan Update",
        userName: "Alice Williams",
        userImage: "https://placekitten.com/103/103",
        planName: "Bali"),
    NotificationModel(
        type: "Plan Removal",
        userName: "Charlie Brown",
        userImage: "https://placekitten.com/104/104",
        planName: "Greece"),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Notifications', style: TextStyle(fontFamily: 'Montserrat', fontSize: 24, fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 39, 26, 99),),),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: NotificationPage(
          notifications: notifications,
          friends: [],
          acceptedFriendRequests: [],
        ),
      ),
    );
  }
}

class NotificationPage extends StatefulWidget {
  final List<NotificationModel> notifications;
  final List<Friend> friends; // Add this line

  final List<Friend> acceptedFriendRequests; // Add this line

  NotificationPage(
      {Key? key,
      required this.friends,
      required this.acceptedFriendRequests,
      required this.notifications})
      : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late GlobalKey<AnimatedListState> _listKey;

  @override
  void initState() {
    super.initState();
    _listKey = GlobalKey<AnimatedListState>();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      initialItemCount: widget.notifications.length,
      itemBuilder: (context, index, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: Dismissible(
            key: Key(widget.notifications[index].type),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              // Store the last deleted notification
              var lastDeletedNotification = widget.notifications[index];

              // Remove the notification from the list
              widget.notifications.removeAt(index);

              // Remove the item from the AnimatedList
              _listKey.currentState!.removeItem(
                index,
                (context, animation) => SizedBox.shrink(),
                duration: const Duration(milliseconds: 500),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Notification deleted"),
                  action: SnackBarAction(
                    label: "Undo",
                    onPressed: () {
                      setState(() {
                        // Insert the last deleted notification back to the list
                        widget.notifications.insert(index, lastDeletedNotification);

                        // Insert the item back to the AnimatedList
                        _listKey.currentState!.insertItem(index);
                      });
                    },
                  ),
                ),
              );
            },
            background: Container(
              alignment: AlignmentDirectional.centerEnd,
              color: Colors.red,
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Icon(Icons.delete, color: Colors.white),
              ),
            ),
            child: buildNotificationCard(context, widget.notifications[index]),
          ),
        );
      },
    );
  }

  Widget buildNotificationCard(
      BuildContext context, NotificationModel notification) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          // Handle notification tap
        },
        child: Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(notification.userImage),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.userName,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'Montserrat'),
                    ),
                    SizedBox(height: 8),
                    Text(
                      getNotificationText(notification),
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    if (notification.type == "Friend Request" &&
                        notification.isAccepted) ...[
                      SizedBox(height: 8),
                    ] else if (notification.type == "Friend Request" &&
                        !notification.isAccepted) ...[
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _acceptFriendRequest(notification);
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
                            width: 8.0,
                          ),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Handle deleting the friend request
                                _deleteFriendRequest(notification);
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
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getNotificationText(NotificationModel notification) {
    switch (notification.type) {
      case "Friend Request":
        return "sent you a friend request.";
      case "Friend Accept":
        return "accepted your friend request.";
      case "Plan Participant":
        return "added you to the ${notification.planName} Plan.";
      case "Plan Update":
        return "made an update to the ${notification.planName} Plan.";
      case "Plan Removal":
        return "removed you from the ${notification.planName} Plan.";
      case "Friend Confirm":
        return "You and ${notification.userName} are now friends.";
      default:
        return "";
    }
  }

  void _acceptFriendRequest(NotificationModel notification) {
    Friend newFriend =
        Friend(name: notification.userName, imageUrl: notification.userImage);

    setState(() {
      widget.friends.add(newFriend);
      widget.acceptedFriendRequests.add(newFriend);
    });

    // Find the index of the accepted notification
    int notificationIndex = widget.notifications.indexOf(notification);

    // Update the notification type and planName (if applicable) for the accepted friend request
    widget.notifications[notificationIndex] = NotificationModel(
      type: "Friend Confirm",
      userName: notification.userName,
      userImage: notification.userImage,
      isAccepted: true, // Add a flag to indicate that the request is accepted
    );

    print("Friend request from ${notification.userName} accepted.");
    print(
        "Updated Friends List: ${widget.friends.map((friend) => friend.name).toList()}");
    print(
        "Updated Accepted Friend Requests: ${widget.acceptedFriendRequests.map((friend) => friend.name).toList()}");
  }

  void _deleteFriendRequest(NotificationModel notification) {
    setState(() {
      widget.notifications.remove(notification);
    });

    print("Friend request from ${notification.userName} deleted.");
  }
}
