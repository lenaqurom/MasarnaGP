import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:masarna/globalstate.dart';
import 'package:masarna/trip/planning.dart';
import 'package:masarna/user/friends_list.dart';
import 'package:provider/provider.dart';

class NotificationModel {
  final String? id;
  final String text;
  final String subtext;
  final String image;
  final String userId;
  final String type;

  NotificationModel({
    String? id,
    this.text = '.',
    this.subtext = '.',
    required this.image,
    this.userId = "1",
    required this.type,
  }) : id = id ?? UniqueKey().toString();

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'],
      text: json['title'],
      subtext: json['text'],
      image: json['image'] ?? '',
      userId:
          json['from'] ?? "", 
      type: json['type'],
    );
  }
}

class MyNotificationApp extends StatefulWidget {
  @override
  _MyNotificationAppState createState() => _MyNotificationAppState();
}

class _MyNotificationAppState extends State<MyNotificationApp> {
  late GlobalKey<AnimatedListState> _listKey;
  final List<NotificationModel> notifications = [];

  @override
  void initState() {
    super.initState();
    _listKey = GlobalKey<AnimatedListState>();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    String userId = Provider.of<GlobalState>(context, listen: false).id;
    print(userId);
    final url = 'http://192.168.1.11:3000/api/notifications/$userId';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print('status 200 bruv');
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> notificationsData = data['notifications'];
        final List<NotificationModel> newNotifications = notificationsData
            .map((item) => NotificationModel.fromJson(item))
            .toList();

        setState(() {
          notifications.clear();
        });

        for (var i = 0; i < newNotifications.length; i++) {
          await Future.delayed(Duration(milliseconds: 50));
          setState(() {
            notifications.add(newNotifications[i]);
            _listKey.currentState!.insertItem(i);
          });
        }
        print('hello');
        print('Notifications length: ${notifications.length}');
      } else {
        // Handle error
        print(
            'Failed to load notifications. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle error
      print('Error fetching notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('building');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Notifications',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 39, 26, 99),
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Container(
          child: AnimatedList(
            key: _listKey,
            initialItemCount: notifications.length,
            itemBuilder: (context, index, animation) {
              print('Building item at index $index');
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: Dismissible(
                  key: Key(notifications[index].id ?? UniqueKey().toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    var lastDeletedNotification = notifications[index];
                    _deleteFriendRequest(notifications[index]);

                    notifications.removeAt(index);
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
                              notifications.insert(
                                  index, lastDeletedNotification);
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
                  child: buildNotificationCard(context, notifications[index]),
                ),
              );
            },
          ),
        ),
      ),
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
          if(notification.type=='newss'){
            Navigator.pushReplacement(
           context, MaterialPageRoute(builder: (context) => FriendsListPage()));
          }
          if(notification.type=='plan'){
            Navigator.pushReplacement(
           context, MaterialPageRoute(builder: (context) => Planning()));
          }
                  },
        child: Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              if (notification.image != null &&
                  notification.image.isNotEmpty) ...[
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage('http://192.168.1.11:3000/' + notification.image.replaceAll('\\', '/')),
                    ),
                  ),
                ),
                SizedBox(width: 16),
              ],
               if (notification.image == '') ...[
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('images/logo4.png'),
                    ),
                  ),
                ),
                SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.text,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    SizedBox(height: 8),
                    // Subtext
                    Text(
                      notification.subtext,
                      style: TextStyle(
                        fontSize: 15, 
                        color: Color.fromARGB(
                            255, 128, 127, 127), 
                      ),
                    ),
                    SizedBox(height: 8),

                    if (notification.type == "req" &&
                        notification.userId != null &&
                        notification.userId.isNotEmpty) ...[
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

  void _acceptFriendRequest(NotificationModel notification) {}

  void _deleteFriendRequest(NotificationModel notification) async {
    try {
      String userId = Provider.of<GlobalState>(context, listen: false).id;

      final deleteUrl =
          'http://192.168.1.11:3000/api/notifications/$userId/${notification.id}';

      
      final response = await http.delete(Uri.parse(deleteUrl));

      if (response.statusCode == 200) {
        print('Notification deleted successfully from the backend.');

        setState(() {
          notifications.remove(notification);
        });
      } else {
        print(
            'Failed to delete notification. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }
}
