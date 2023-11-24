import 'dart:io';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class ImageViewScreen extends StatefulWidget {
  final File imageFile;
  final Function onDelete;

  ImageViewScreen({required this.imageFile, required this.onDelete});

  @override
  _ImageViewScreenState createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends State<ImageViewScreen> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    // Extract the image file name from the path
    String imageName = widget.imageFile.path.split('/').last;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromARGB(255, 39, 26, 99),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          imageName,
          style: TextStyle(
            color: Color.fromARGB(255, 39, 26, 99),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Color.fromARGB(255, 39, 26, 99)),
            onPressed: () {
              _showDeleteDialog(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Hero(
          tag: 'imageHero',
          child: Image.file(
            widget.imageFile,
            fit: BoxFit.contain, // Use BoxFit.contain for a fit without losing details
            height: screenHeight,
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.WARNING,
      animType: AnimType.BOTTOMSLIDE,
      title: 'Delete Photo',
      desc: 'Are you sure you want to delete this photo?',
      btnCancelOnPress: () {},
      btnCancelText: 'Cancel',
      btnCancelColor: Colors.grey,
      btnOkColor: Color.fromARGB(255, 39, 26, 99),
      btnOkOnPress: () {
        widget.onDelete();
        Navigator.of(context).pop(); // Pop ImageViewScreen
      },
      btnOkText: 'Delete',
    )..show();
  }
}
