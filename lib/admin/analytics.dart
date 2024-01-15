import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'package:cached_network_image/cached_network_image.dart';
import 'review_model.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';


class AdminReviewPage extends StatefulWidget {
  @override
  _AdminReviewPageState createState() => _AdminReviewPageState();
}

class _AdminReviewPageState extends State<AdminReviewPage> {
  List<Review> reviews = [];

  @override
  void initState() {
    super.initState();
    // Fetch reviews from your API or any data source
    fetchReviews();
  }

   Future<void> fetchReviews() async {
     final response = await http.get(Uri.parse('http://192.168.1.11:3000/api/ratings'));

     if (response.statusCode == 200) {
       final List<dynamic> data = json.decode(response.body);
       setState(() {
         reviews = data.map((review) => Review(
           username: review['user']['username']??'',
           profileImage: review['user']['profilepicture']??'',
          rating: review['stars'].toDouble()??'',
          comment: review['comment']?? '',
         )).toList();
       });
     } else {
      throw Exception('Failed to load reviews');
     }
   }
/*Future<void> fetchReviews() async {
  // Dummy data for testing
  final List<Map<String, dynamic>> dummyData = [
    {
      "username": "JohnDoe",
      "profileImage": "https://placekitten.com/100/100",
      "rating": 4.5,
      "comment": "Great app! I love it.",
    },
    {
      "username": "AliceSmith",
      "profileImage": "https://placekitten.com/100/100",
      "rating": 3.0,
      "comment": "Good experience overall.",
    },
    {
      "username": "AliceSmith",
      "profileImage": "https://placekitten.com/100/100",
      "rating": 5.0,
      "comment": "Good experience overall.",
    },
    {
      "username": "AliceSmith",
      "profileImage": "https://placekitten.com/100/100",
      "rating": 3.0,
      "comment": "Good experience overall.",
    },

    // Add more dummy data as needed
  ];

  setState(() {
    reviews = dummyData.map((review) => Review(
      username: review['username'],
      profileImage: review['profileImage'],
      rating: review['rating'].toDouble(),
      comment: review['comment'],
    )).toList();
  });
}*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reviews',
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
      body: ListView.builder(
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return Card(
            elevation: 2.0,
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              title: Text(
                review.username,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colors.black,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RatingBar.builder(
                    initialRating: review.rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 20.0,
                    itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      // Handle rating update
                    },
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    review.comment,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              leading: CircleAvatar(
                radius: 30.0,
                backgroundColor: Colors.blue[100],
                child: ClipOval(
                  child: review.profileImage.isNotEmpty
                ?  Image.network(
                   'http://192.168.1.11:3000/' + review.profileImage.replaceAll('\\', '/'),
                    fit: BoxFit.cover,
                    width: 60.0,
                    height: 60.0,
                  )
                  :Image.asset(
                                                  "images/logo4.png",
                                                  width: 60.0,
                                                  height: 60.0,
                                                  fit: BoxFit.cover,
                                                ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
