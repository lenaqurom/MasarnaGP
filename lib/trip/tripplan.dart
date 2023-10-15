import 'package:flutter/material.dart';

class TripPlan extends StatefulWidget {
  const TripPlan({Key? key}) : super(key: key);

  @override
  _TripPlanState createState() => _TripPlanState();
}

class _TripPlanState extends State<TripPlan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'trip name',
          style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TripPlanButton('Flights', 0), // Pass an index to identify the section
              TripPlanButton('Stay', 1),
              TripPlanButton('Restaurants', 2),
              TripPlanButton('Activities', 3),
            ],
          ),
          SizedBox(height: 20.0),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Content for Flights
                  buildSection('Flights', 0),
                  // Content for Stay
                  buildSection('Stay', 1),
                  // Content for Restaurants
                  buildSection('Restaurants', 2),
                  // Content for Activities
                  buildSection('Activities', 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSection(String title, int index) {
    // You can customize this section further with your specific content
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 23.0,
              fontWeight: FontWeight.bold,
              
            ),
          ),
          SizedBox(height: 10.0),
          // Add content for the respective section here
        ],
      ),
    );
  }
}

class TripPlanButton extends StatelessWidget {
  final String label;
  final int index;

  TripPlanButton(this.label, this.index);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        // Scroll to the respective section based on the index
        Scrollable.ensureVisible(
          context,
          alignment: 0.0,
          duration: Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      },
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color:Color.fromARGB(255, 170, 100, 182),
        ),
      ),
    );
  }
}
