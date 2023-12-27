import 'package:masarna/globalstate.dart';
import 'package:masarna/trip/calender/calendar.dart';
import 'package:masarna/trip/calender/dayview.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({Key? key}) : super(key: key);
  // static late GlobalKey<_BudgetPageState> budgetStateKey =
  //   GlobalKey<_BudgetPageState>();

  @override
  State<BudgetPage> createState() => _BudgetPageState();
  //   @override
  // void initState() {
  //   super.initState();
  //   // Assign the key to the state
  //   BudgetPage.budgetStateKey = GlobalKey<_BudgetPageState>();
  // }
}

class _BudgetPageState extends State<BudgetPage> {
  List<Event> events = [];

  @override
  void initState() {
    super.initState();
    fetchBudgetDetails(); // Fetch budget details when the page is initialized
  }

  Future<void> fetchBudgetDetails() async {
    try {
      final String userId = Provider.of<GlobalState>(context, listen: false).id;
      final String planId = Provider.of<GlobalState>(context, listen: false).planid; 
    final Uri uri =
          Uri.parse('http://192.168.1.13:3000/api/$planId/$userId/calendarevents');
      final response = await http.get(
          uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> calendarevents = data['calendarevents'];

        setState(() {
          events = calendarevents
              .map((eventData) => Event(
                    name: eventData['name'],
                    type: eventData['type'] == 'group'
                        ? EventType.group
                        : EventType.personal,
                    price: eventData['price'].toDouble(),
                    date: DateTime.parse(eventData['date']),
                  ))
              .toList();
        });
      } else {
        // Handle error
        print('Failed to fetch budget details');
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Budget Overview',
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
           context, MaterialPageRoute(builder: (context) => MyCalendarPage()));
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Color.fromARGB(255, 39, 26, 99)),
            onPressed: () {
              showSearch(
                context: context,
                delegate: EventSearch(events),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ..._buildEventList(),
                ],
              ),
            ),
          ),
          _buildGrandTotal(),
        ],
      ),
    );
  }

  List<Widget> _buildEventList() {
    List<Widget> widgets = [];

    // Group events by date
    Map<DateTime, List<Event>> groupedEvents = {};
    for (var event in events) {
if (event.type == EventType.group && event.name == 'dummy') {
      continue;
    }

      if (!groupedEvents.containsKey(event.date)) {
        groupedEvents[event.date] = [];
      }
      groupedEvents[event.date]?.add(event);
    }

    
  // Sort dates from least recent to most recent
  var sortedDates = groupedEvents.keys.toList()
    ..sort((a, b) => a.compareTo(b));

    // Build cards for each date
    for (var date in sortedDates) {
    widgets.add(_buildDateCard(date, groupedEvents[date]!));
  }

    return widgets;
  }

  Widget _buildDateCard(DateTime date, List<Event> events) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 39, 26, 99),
                fontFamily: 'Montserrat',
              ),
            ),
            SizedBox(height: 16),
            Column(
              children: events.map((event) => _buildEventCard(event)).toList(),
            ),
            SizedBox(height: 16),
            _buildTotalForDate(events),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: event.type == EventType.personal
              ? Colors.pink[50]
              : Colors.blue[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            ListTile(
              contentPadding: EdgeInsets.all(16),
              title: Text(
                event.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: event.type == EventType.personal
                      ? Colors.pink[800]
                      : Color(0xFF004aad),
                ),
              ),
            ),
            Positioned(
              top: 0.0,
              right: 0.0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 13 * 1.5,
                  vertical: 15 / 4,
                ),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 39, 26, 99),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  "\$${event.price}",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalForDate(List<Event> events) {
    double totalForDate = _calculateTotalForDate(events);
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 39, 26, 99),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Price',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
              fontFamily: 'Montserrat',
            ),
          ),
          Text(
            '$totalForDate \$',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotalForDate(List<Event> events) {
    double totalForDate = 0.0;
    for (var event in events) {
      totalForDate += event.price;
    }
    return totalForDate;
  }

  Widget _buildGrandTotal() {
    double grandTotal = _calculateGrandTotal();
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 2, vertical: 0.3),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 39, 26, 99),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Grand Total',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
              fontFamily: 'Montserrat',
            ),
          ),
          Text(
            '$grandTotal \$',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  double _calculateGrandTotal() {
    double grandTotal = 0.0;
    for (var event in events) {
      grandTotal += event.price;
    }
    return grandTotal;
  }
}

class Event {
  String name;
  EventType type;
  double price;
  DateTime date;

  Event({
    required this.name,
    required this.type,
    required this.price,
    required this.date,
  });
  _budgetEvent(String name, String price, DateTime date, bool isGroupEvent) {
    this.name = name;
    this.price = double.parse(price);
    this.date = date;
    if (isGroupEvent == false) {
      type = EventType.personal;
    } else {
      type = EventType.group;
    }
    isGroupEvent = false;
    print('Event budget added:');
    print('Event Name: $name');
    print('Event Price: $price');
    print('Event Date: $date');
    print('isGroupEvent: $isGroupEvent');
    print('-----');
  }
}

enum EventType {
  personal,
  group,
}

class EventSearch extends SearchDelegate<Event> {
  final List<Event> events;

  EventSearch(this.events);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(
          Icons.clear,
          color: Color.fromARGB(255, 39, 26, 99),
        ),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back,
        color: Color.fromARGB(255, 39, 26, 99),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  String get searchFieldLabel => 'Search on Date';

  @override
  Widget buildResults(BuildContext context) {
    final results = events.where((event) =>
        '${event.date.day}/${event.date.month}/${event.date.year}'
            .contains(query))
                  .where((event) => !(event.type == EventType.group && event.name == 'dummy'));


    return _buildSearchResults(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = events.where((event) =>
        '${event.date.day}/${event.date.month}/${event.date.year}'
            .contains(query))
                  .where((event) => !(event.type == EventType.group && event.name == 'dummy'));


    return _buildSearchResults(results);
  }

  Widget _buildSearchResults(Iterable<Event> results) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Search Results',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 39, 26, 99),
              fontFamily: 'Montserrat',
            ),
          ),
          SizedBox(height: 16),
          results.isEmpty
              ? Center(
                  child: Text(
                    'No events found for the selected date',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                )
              : Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children:
                        results.map((event) => _buildEventCard(event)).toList(),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        tileColor: event.type == EventType.personal
            ? Colors.pink[50]
            : Colors.blue[50],
        contentPadding: EdgeInsets.all(16),
        title: Text(
          event.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: event.type == EventType.personal
                ? Colors.pink[800]
                : Color(0xFF004aad),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: ${event.date.day}/${event.date.month}/${event.date.year}',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Price: ${event.price} \$',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

