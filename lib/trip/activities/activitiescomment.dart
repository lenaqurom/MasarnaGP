import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class Comment {
  final String userName;
  final String commentText;
  final String profileImage;
  List<Comment> replies;

  Comment({
    required this.userName,
    required this.commentText,
    required this.profileImage,
    List<Comment>? replies,
  }) : this.replies = replies ?? [];
}


class ActivitiesCommentPage extends StatefulWidget {
  @override
  _ActivitiesCommentPageState createState() => _ActivitiesCommentPageState();
}

class _ActivitiesCommentPageState extends State<ActivitiesCommentPage> {
  List<Comment> comments = [];
  TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Comments on Activities',
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
              backgroundImage: AssetImage(comment.profileImage),
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
                    leading: Icon(Icons.edit, color: Color.fromARGB(255, 39, 26, 99)),
                    title: Text('Edit'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Color.fromARGB(255, 39, 26, 99)),
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
                CircleAvatar(
                  backgroundImage: AssetImage('images/profile.png'),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: TextFormField(
                    controller: _replyController,
                    decoration: InputDecoration(
                      hintText: 'Write a reply...',
                      border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 39, 26, 99)),
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
        backgroundImage: AssetImage(reply.profileImage),
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
              leading: Icon(Icons.edit, color: Color.fromARGB(255, 39, 26, 99),),
              title: Text('Edit'),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete, color: Color.fromARGB(255, 39, 26, 99),),
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
            CircleAvatar(
              backgroundImage: AssetImage('images/profile.png'),
            ),
            SizedBox(width: 8.0),
            Expanded(
              child: TextFormField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  border: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 39, 26, 99)),
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

  void _addComment(String text) {
    if (text.isNotEmpty) {
      setState(() {
        comments.add(Comment(
          userName: 'Your Name',
          commentText: text,
          profileImage: 'images/profile.png',
        ));
      });
    }
  }

  void _addReply(
    Comment parentComment,
    int parentIndex,
    TextEditingController replyController,
  ) {
    String text = replyController.text;
    if (text.isNotEmpty) {
      Comment reply = Comment(
        userName: 'Your Name',
        commentText: text,
        profileImage: 'images/profile.png',
      );

      setState(() {
        parentComment.replies.add(reply);
      });
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
          _updateComment(index, editedText);
        }
      },
      btnCancelOnPress: () {},
      btnCancelText: 'Cancel',
      btnOkText: 'Save',
    )..show();
  }

  void _updateComment(int index, String newText) {
    if (newText.isNotEmpty) {
      setState(() {
        comments[index] = Comment(
          userName: comments[index].userName,
          commentText: newText,
          profileImage: comments[index].profileImage,
          replies: comments[index].replies,
        );
      });
    }
  }

  void _updateReply(int parentIndex, String newText, Comment reply) {
    setState(() {
      comments[parentIndex]
          .replies[comments[parentIndex].replies.indexOf(reply)] = Comment(
        userName: reply.userName,
        commentText: newText,
        profileImage: reply.profileImage,
      );
    });
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
