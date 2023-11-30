import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:masarna/globalstate.dart';
import 'package:provider/provider.dart';

class Comment {
  //final String commentId;
  final String userId;
  final String userName;
  final String commentText;
  final String profileImage;
  List<Comment> replies;

  Comment({
   // required this.commentId,
    required this.userId,
    required this.userName,
    required this.commentText,
    required this.profileImage,
    List<Comment>? replies,
  }) : this.replies = replies ?? [];
}

class StayCommentPage extends StatefulWidget {
  @override
  _StayCommentPageState createState() => _StayCommentPageState();
}

class _StayCommentPageState extends State<StayCommentPage> {
  List<Comment> comments = [];
  TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    // Dispose other controllers as needed
    super.dispose();
  }

  Future<void> fetchComments() async {
    final response = await http.get(Uri.parse(
        'http://192.168.1.3:3000/api/oneplan/6567bf72e0b164fa214f33d3/groupdayplan/6567c3038632a75709c3366d/section/stays/comments'));

    if (response.statusCode == 200) {
      // Parse the response data
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Extract the comments list from the response
      final List<dynamic> commentDataList = responseData['comments'];

      // Map the comment data to Comment objects
      final List<Comment> fetchedComments = commentDataList.map((commentData) {
        final String userId = commentData['user'];

        final List<dynamic>? repliesDataList = commentData['replies'];
        List<Comment> replies = [];

        if (repliesDataList != null) {
          replies = repliesDataList.map((replyData) {
            final String replyUserId = replyData['user'];

            return Comment(
             // commentId: replyData['_id'],
              userId: replyUserId,
              userName: replyData['username'] ?? '',
              commentText: replyData['text'] ?? '',
              profileImage: 'http://192.168.1.3:3000/' +
                  replyData['profilepicture'].replaceAll('\\', '/'),
            );
          }).toList();
        }

        return Comment(
         // commentId: commentData['_id'],
          userId: userId,
          userName: commentData['username'] ?? '',
          commentText: commentData['text'] ?? '',
          profileImage: 'http://192.168.1.3:3000/' +
              commentData['profilepicture'].replaceAll('\\', '/'),
          replies: replies,
        );
      }).toList();

      setState(() {
        comments = fetchedComments;
      });
    } else {
      // Handle error cases
      print('Failed to load comments');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Comments on Stays',
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
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return buildCommentItem(comments[index], index);
              },
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget buildCommentItem(Comment comment, int index) {
    TextEditingController _replyController = TextEditingController();
    TextEditingController _editController =
        TextEditingController(text: comment.commentText);

    return Card(
      elevation: 3,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(comment.profileImage),
            ),
            title: Text(
              comment.userName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color.fromARGB(255, 39, 26, 99),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(213, 226, 224, 243),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Text(
                  comment.commentText,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _editComment(comment, index, _editController, false);
                } else if (value == 'delete') {
                  _showDeleteConfirmation(context, index, comment, null);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit,
                        color: Color.fromARGB(255, 39, 26, 99)),
                    title: Text('Edit'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete,
                        color: Color.fromARGB(255, 39, 26, 99)),
                    title: Text('Delete'),
                  ),
                ),
              ],
            ),
          ),
          // Display replies
          if (comment.replies.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: comment.replies.map((reply) {
                  return buildReplyCommentItem(reply, index);
                }).toList(),
              ),
            ),
          // Reply TextField
          Container(
            padding: EdgeInsets.only(left: 32, right: 16, top: 16, bottom: 16),
            child: Row(
              children: [
                SizedBox(width: 8.0),
                Expanded(
                  child: TextFormField(
                    controller: _replyController,
                    decoration: InputDecoration(
                      hintText: 'Write a reply...',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    _addReply(comment, index, _replyController);
                    _replyController.clear();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 39, 26, 99),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Icon(FontAwesome.send, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReplyCommentItem(Comment reply, int parentIndex) {
    TextEditingController _editController =
        TextEditingController(text: reply.commentText);

    return ListTile(
      contentPadding: EdgeInsets.all(16),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(reply.profileImage),
      ),
      title: Text(
        reply.userName,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Color.fromARGB(255, 39, 26, 99),
        ),
      ),
      subtitle: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Color.fromARGB(213, 226, 224, 243),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(
          reply.commentText,
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            _editComment(reply, parentIndex, _editController, true);
          } else if (value == 'delete') {
            _showDeleteConfirmation(context, parentIndex, null, reply);
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'edit',
            child: ListTile(
              leading: Icon(
                Icons.edit,
                color: Color.fromARGB(255, 39, 26, 99),
              ),
              title: Text('Edit'),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'delete',
            child: ListTile(
              leading: Icon(
                Icons.delete,
                color: Color.fromARGB(255, 39, 26, 99),
              ),
              title: Text('Delete'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            SizedBox(width: 8.0),
            Expanded(
              child: TextFormField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Write a reply...',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.0),
            ElevatedButton(
              onPressed: () {
                _addComment(_commentController.text);
                _commentController.clear();
              },
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 39, 26, 99),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: Icon(FontAwesome.send, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addComment(String text) async {
    if (text.isNotEmpty) {
      // Perform the network request to add a new comment
      try {
        String userId = Provider.of<GlobalState>(context, listen: false).id;
        final response = await http.post(
          Uri.parse(
              'http://192.168.1.3:3000/api/oneplan/6567bf72e0b164fa214f33d3/groupdayplan/6567c3038632a75709c3366d/section/stays/$userId/comment'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({'text': text}),
        );
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        if (response.statusCode == 201) {
          final Map<String, dynamic> responseData = json.decode(response.body);

          // Extract the user data and profile picture URL from the response
          final Map<String, dynamic> userData = responseData['plan']['user'];
          final String profilePicture = userData['profilepicture'];

          // Combine the server base URL and the profile picture path
          final String profileImage =
              'http://192.168.1.3:3000/' + profilePicture.replaceAll('\\', '/');

          // Create the new comment with the profile picture
          final Comment newComment = Comment(
            userId: userData['_id'],
            userName: userData['username'],
            commentText: text,
            profileImage: profileImage,
          );

          // Update the UI by adding the new comment
          setState(() {
            comments.add(newComment);
          });
        } else {
          // Handle error cases
          print('Failed to add comment');
        }
      } catch (error) {
        // Handle exceptions
        print('Error adding comment: $error');
      }
    }
  }

  void _addReply(
    Comment parentComment,
    int parentIndex,
    TextEditingController replyController,
  ) async {
    String text = replyController.text;
    if (text.isNotEmpty) {
      try {
        // Obtain the user ID from your global state or another source
        String userId = Provider.of<GlobalState>(context, listen: false).id;

        // Send a POST request to the API endpoint
        final response = await http.post(
          Uri.parse(
              'http://192.168.1.3:3000/api/oneplan/6567bf72e0b164fa214f33d3/groupdayplan/6567c3038632a75709c3366d/section/stays/6567e6409dbdcbcb7b52db21/reply'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'text': text,
            'userId': userId,
          }),
        );

        if (response.statusCode == 201) {
          final dynamic responseData = json.decode(response.body);

          if (responseData is Map<String, dynamic> &&
              responseData.containsKey('plan')) {
            // Extract the user data and profile picture URL from the response
            final Map<String, dynamic> userData = responseData['user'];
            final String profilePicture = userData['profilepicture'];

            // Combine the server base URL and the profile picture path
            final String profileImage = 'http://192.168.1.3:3000/' +
                profilePicture.replaceAll('\\', '/');

            // Create the new reply with the profile picture
            final Comment newReply = Comment(
              
              userId: userData['_id'],
              userName: userData['username'],
              commentText: text,
              profileImage: profileImage,
            );

            // Update the UI by adding the new reply
            setState(() {
              parentComment.replies.add(newReply);
            });
          } else {
            // Handle unexpected response format
            print('Unexpected response format when adding reply');
          }
        } else {
          // Handle error cases
          print('Failed to add reply. Status code: ${response.statusCode}');
        }
      } catch (error) {
        // Handle exceptions
        print('Error adding reply: $error');
      }
    }
  }

  void _editComment(
    Comment comment,
    int index,
    TextEditingController editController,
    bool isReply,
  ) {
    String editedText = comment.commentText;

    AwesomeDialog(
      context: context,
      dialogType: DialogType.INFO,
      animType: AnimType.BOTTOMSLIDE,
      title: 'Edit Comment',
      desc: '',
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: editController,
          onChanged: (text) {
            editedText = text;
          },
          style: TextStyle(color: Colors.black), // Adjusted text color
          decoration: InputDecoration(
            hintText: 'Edit your comment...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
      btnOkOnPress: () {
        if (isReply) {
          _updateReply(index, editedText, comment);
        } else {
          _updateComment(index, editedText, comment);
        }
      },
      btnCancelOnPress: () {},
      btnCancelText: 'Cancel',
      btnOkText: 'Save',
    )..show();
  }

  void _updateComment(int index, String newText, Comment comment) async {
    if (newText.isNotEmpty) {
      setState(() {
        comments[index] = Comment(
          commentId: comment.commentId,
          userId: comment.userId,
          userName: comment.userName,
          commentText: newText,
          profileImage: comment.profileImage,
          replies: comment.replies,
        );
      });

      // Make API call to update the comment on the server
      final Map<String, dynamic> requestBody = {'newText': newText};
      try {
        final response = await http.put(
          Uri.parse(
              'http://192.168.1.3:3000/api/oneplan/6567bf72e0b164fa214f33d3/groupdayplan/6567c3038632a75709c3366d/section/stays/6567ed234e09ce5e1be70523'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          // The request was successful, you can log the response for more details
          print('Comment updated successfully');
          print(response.body);
        } else {
          // The request failed, print the response for debugging
          print('Failed to update comment');
          print(response.statusCode);
          print(response.body);
        }
      } catch (error) {
        // Handle exceptions, if any
        print('Error updating comment: $error');
      }
    }
  }

  void _updateReply(int parentIndex, String newText, Comment reply) async {
    setState(() {
      final updatedReplies = comments[parentIndex].replies.map((oldReply) {
        if (oldReply == reply) {
          return Comment(
            commentId: reply.commentId,
            userId: reply.userId,
            userName: reply.userName,
            commentText: newText,
            profileImage: reply.profileImage,
          );
        }
        return oldReply;
      }).toList();

      comments[parentIndex].replies = updatedReplies;
    });

    // Make API call to update the reply on the server
    final Map<String, dynamic> requestBody = {'newText': newText};
    final replyCommentId =
        reply.commentId; // Ensure you have the reply commentId

    try {
      final response = await http.put(
        Uri.parse(
            'http://192.168.1.3:3000/api/oneplan/6567bf72e0b164fa214f33d3/groupdayplan/6567c3038632a75709c3366d/section/stays/${reply.commentId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // The request was successful, you can log the response for more details
        print('Reply updated successfully');
        print(response.body);
      } else {
        // The request failed, print the response for debugging
        print('Failed to update reply');
        print(response.statusCode);
        print(response.body);
      }
    } catch (error) {
      // Handle exceptions, if any
      print('Error updating reply: $error');
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    int index,
    Comment? comment,
    Comment? reply,
  ) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.WARNING,
      animType: AnimType.BOTTOMSLIDE,
      title: 'Delete Confirmation',
      desc: 'Are you sure you want to delete this comment?',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        if (comment != null) {
          _deleteComment(index);
        } else if (reply != null) {
          _deleteReply(index, reply);
        }
      },
    )..show();
  }

  void _deleteReply(int parentIndex, Comment reply) {
    setState(() {
      comments[parentIndex].replies.remove(reply);
    });
  }

  void _deleteComment(int index) {
    setState(() {
      comments.removeAt(index);
    });
  }
}
