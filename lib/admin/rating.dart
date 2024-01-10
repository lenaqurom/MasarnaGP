import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:masarna/globalstate.dart';
import 'package:masarna/user/profile_page.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RatingPage(),
    );
  }
}

class RatingPage extends StatefulWidget {
  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  double _appRating = 0.0;
  String _comments = "";

  Future<void> _addRating() async {
    // Print the request body for debugging
    final String id = //'655e701ae784f2d47cd02151';
     Provider.of<GlobalState>(context, listen: false).id;

    String apiUrl = 'http://172.19.46.78:3000/api/rate';
    print(
        'rating is:' + _appRating.toString() + '' + 'comment is:' + _comments);
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode({
          'userId': id,
          'stars': _appRating,
          'comment': _comments,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('rating added successfully');
        //should nav back here
        _showSuccessDialog();
       

      } else {
        print('Failed to add rating ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rating',
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
           Navigator.pushReplacement(
           context, MaterialPageRoute(builder: (context) => ProfileScreen()));  
          },
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Text(
                  'Your feedback is valuable to us!',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 60),
                _buildRatingSection(
                  'Please rate your experience with our application:\nWas it useful for you?',
                  _appRating,
                  (rating) {
                    setState(() {
                      _appRating = rating;
                    });
                  },
                ),
                SizedBox(height: 30),
                Text(
                  'Comments/Suggestions:',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      _comments = value;
                    });
                  },
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    _addRating();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 39, 26, 99),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        'Submit Rating',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection(
      String title, double rating, ValueChanged<double> onRatingChanged) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        RatingBar.builder(
          initialRating: rating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemSize: 40,
          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: onRatingChanged,
        ),
        SizedBox(height: 20),
      ],
    );
  }

  void _showSuccessDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.SUCCES,
      animType: AnimType.BOTTOMSLIDE,
      title: 'Success!',
      desc: 'Your ratings have been submitted successfully.',
      btnOkText: 'Okay',
      btnOkOnPress: () { Navigator.pushReplacement(
           context, MaterialPageRoute(builder: (context) => ProfileScreen()));},
    )..show();
  }
}
