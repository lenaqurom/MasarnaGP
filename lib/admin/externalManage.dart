import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:masarna/admin/adminNotifs.dart';
import 'package:masarna/globalstate.dart';
import 'package:masarna/trip/activities/activitiescomment.dart';
import 'package:masarna/trip/activities/activitiespoll.dart';
import 'package:masarna/trip/calender/calendar.dart';
import 'package:masarna/trip/eateries/eateriescomment.dart';
import 'package:masarna/trip/eateries/eateriespoll.dart';
import 'package:masarna/trip/flights/flightcomment.dart';
import 'package:masarna/trip/flights/flightpoll.dart';
import 'package:masarna/trip/stays/staycomment.dart';
import 'package:masarna/trip/stays/staypoll.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'dart:math';

import 'package:provider/provider.dart';

class ExternalManage extends StatefulWidget {
   // const ExternalManage({super.key, required int selectedIndex});

  @override
  _ExternalManageState createState() => _ExternalManageState();
}

class _ExternalManageState extends State<ExternalManage>
    with TickerProviderStateMixin {
  late DateTime selectedDate;

  _ExternalManageState();
  final String title = "flights";
  String selectedLocation = 'Antalya'; // Default location
  bool isFABVisible = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool isExpanded = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String tabType = '';
  late TabController _tabController;
  late int _selectedTabIndex;
  Map<String, bool> favoritesMap = {};

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = 0;
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  Future<List<Map<String, dynamic>>> fetchStaysData() async {
    // Replace this with your actual backend API call to fetch stays data
    final response =
        await http.get(Uri.parse('http://192.168.1.11:3000/api/getstays'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((data) => data as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load stays data');
    }
  }

  Future<List<Map<String, dynamic>>> fetchEateriesData() async {
    // Replace this with your actual backend API call to fetch stays data
    final response =
        await http.get(Uri.parse('http://192.168.1.11:3000/api/geteateries'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((data) => data as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load eateries data');
    }
  }

  Future<List<Map<String, dynamic>>> fetchFlightsData() async {
    // Replace this with your actual backend API call to fetch stays data
    final response =
        await http.get(Uri.parse('http://192.168.1.11:3000/api/getflights'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((data) => data as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load flights data');
    }
  }

  Future<List<Map<String, dynamic>>> fetchActivitiesData() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.11:3000/api/getactivities'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);

      // Convert dynamic list to List<Map<String, dynamic>>
      List<Map<String, dynamic>> activities =
          jsonData.cast<Map<String, dynamic>>().toList();

      return activities;
    } else {
      throw Exception('Failed to load activities data');
    }
  }

  String formatDateForAPI(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> addPersonalEvent(
    String name,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String price,
    double latitude,
    double longitude,
  ) async {
    double parsedPrice = double.tryParse(price) ?? 0.0;
    // Format TimeOfDay to strings
    String formatTimeOfDay(TimeOfDay timeOfDay) {
      String formattedHour = timeOfDay.hour.toString().padLeft(2, '0');
      String formattedMinute = timeOfDay.minute.toString().padLeft(2, '0');

      return '$formattedHour:$formattedMinute';
    }

    String formattedStartTime =
        startTime != null ? formatTimeOfDay(startTime) : '';
    String formattedEndTime = endTime != null ? formatTimeOfDay(endTime) : '';
    print(formattedEndTime);
    String planId = Provider.of<GlobalState>(context, listen: false).planid;
    String userId = Provider.of<GlobalState>(context, listen: false).id;

    final String apiUrl =
        'http://192.168.1.11:3000/api/$planId/personalplan/$userId';

    final Map<String, dynamic> requestBody = {
      'date': formatDateForAPI(selectedDate),
      'name': name,
      'starttime': formattedStartTime,
      'endtime': formattedEndTime,
      'location': {'longitude': longitude, 'latitude': latitude},
      'price': parsedPrice,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        print('bravo in explore');
      } else {
        // Handle error, maybe show an error dialog or log the error
        print('Error response: ${response.statusCode}');
        print('Error body: ${response.body}');
      }
    } catch (error) {
      print('Exception during HTTP request: $error');
    }
  }

  void _handleTabSelection() {
    setState(() {
      _selectedTabIndex = _tabController.index;

      print('Selected Tab Index: $_selectedTabIndex');

      String newTabType = '';
      switch (_selectedTabIndex) {
        case 0:
          newTabType = 'Flights';
          break;
        case 1:
          newTabType = 'Stays';
          break;
        case 2:
          newTabType = 'Eateries';
          break;
        case 3:
          newTabType = 'Activities';
          break;
      }

      updateTabType(newTabType);

      if (isExpanded) {
        // If expanded, update the tab type immediately
        updateTabType(_getTabType());
      }
    });
  }

  void updateTabType(String newTabType) {
    setState(() {
      tabType = newTabType;
    });
  }

  Widget _buildContentBasedOnTabIndex(int index) {
    switch (index) {
      case 0:
        return _buildContentflights(title: 'Flights');
      case 1:
        return _buildContentstays(title: 'Stays');
      case 2:
        return _buildContenteateries(title: 'Eateries');
      case 3:
        return _buildContentactivities(title: 'Activities');
      default:
        return Container();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Row(
                children: [
                  IconButton(
                    onPressed: () {
 Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AdminNotifs(selectedIndex: 2,)),
            );                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: Color.fromARGB(255, 39, 26, 99),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 100),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedLocation,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        size: 20,
                        color: Color.fromARGB(255, 39, 26, 99),
                      ),
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            selectedLocation = value;
                          });
                        }
                      },
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 39, 26, 99),
                      ),
                      items: ['Antalya', 'Bali', 'Paris', 'Italya']
                          .map((String location) {
                        return DropdownMenuItem<String>(
                          value: location,
                          child: Text(
                            location,
                            style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Dosis',
                                fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Spacer(), // Added Spacer to push the next content to the right
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      size: 20,
                      color: Color.fromARGB(255, 39, 26, 99),
                    ),
                    onPressed: () async {
                      print('um');
                      try {
                        await http.get(
                            Uri.parse('http://192.168.1.11:3000/api/flights'));
                        await http.get(
                            Uri.parse('http://192.168.1.11:3000/api/hotels'));
                        await http.get(Uri.parse(
                            'http://192.168.1.11:3000/api/nightlifeactivities'));
                        await http.get(Uri.parse(
                            'http://192.168.1.11:3000/api/sightseeingactivities'));
                        await http.get(Uri.parse(
                            'http://192.168.1.11:3000/api/shoppingactivities'));
                        await http.get(
                            Uri.parse('http://192.168.1.11:3000/api/eateries'));

                        print('API calls triggered successfully');
                        fetchActivitiesData();
                        fetchEateriesData();
                        fetchFlightsData();
                        fetchStaysData();
                        print('fetched new ones');
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Refresh successful'),
        ));
                      } catch (error) {
                        print('Error triggering API calls: $error');
                      }
                    },
                  ),
                ],
              ),
              backgroundColor: Colors.white,
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    text: 'Flights',
                    icon: Icon(Icons.flight, size: 20),
                  ),
                  Tab(
                    text: 'Stays',
                    icon: Icon(Icons.hotel, size: 20),
                  ),
                  Tab(
                    text: 'Eateries',
                    icon: Icon(Icons.restaurant, size: 20),
                  ),
                  Tab(
                    text: 'Activities',
                    icon: Icon(Icons.directions_run, size: 20),
                  ),
                ],
                labelColor: Color.fromARGB(255, 39, 26, 99),
                indicatorColor: Color.fromARGB(255, 39, 26, 99),
              ),
            ),
            // bottomNavigationBar: Example(initialIndex: 0),
            body: Stack(
              children: [
                TabBarView(
                  controller: _tabController,
                  children: [
                    _buildContentBasedOnTabIndex(0),
                    _buildContentBasedOnTabIndex(1),
                    _buildContentBasedOnTabIndex(2),
                    _buildContentBasedOnTabIndex(3),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExampleCard({
    required String title,
    required String description,
    required String imageUrl,
    String price = '',
    String address = '',
    double latitude = 0,
    double longitude = 0,
    String rating = '',
    required VoidCallback onTap,
    required String cardId,
    required VoidCallback onDelete,
    required int favoritesCount,
    required int reportsCount,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22.0),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                Container(
                  height: 200.0,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(22.0)),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(22.0)),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.report,
                              color: Colors.red,
                              size: 18.0,
                            ),
                            SizedBox(width: 4.0),
                            Text(
                              '$reportsCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 18.0,
                            ),
                            SizedBox(width: 4.0),
                            Text(
                              '$favoritesCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0.0,
                  left: 0.0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20 * 1.5,
                      vertical: 20 / 4,
                    ),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 39, 26, 99),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(22),
                        topLeft: Radius.circular(22),
                      ),
                    ),
                    child: Text(
                      "\$${price}",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 20.0,
                          ),
                          SizedBox(width: 4.0),
                          Text(
                            '$rating',
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[600],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Color.fromARGB(255, 39, 26, 99),
                                  size: 20.0,
                                ),
                                SizedBox(width: 4.0),
                                Flexible(
                                  child: Text(
                                    address,
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      color: Color.fromARGB(255, 39, 26, 99),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: onDelete,
                            icon: Icon(FlutterIcons.delete_ant),
                            label: Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 39, 26, 99),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTabType() {
    switch (_selectedTabIndex) {
      case 0:
        return 'Flights';
      case 1:
        return 'Stays';
      case 2:
        return 'Eateries';
      case 3:
        return 'Activities';
      default:
        return 'Flights'; // Default to Flights if the index is unknown
    }
  }

  void _showDeleteDialog(BuildContext context, String cardId) {
    AwesomeDialog(
        context: context,
        animType: AnimType.SCALE,
        dialogType: DialogType.NO_HEADER,
        body: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                Text(
                  'Delete Option',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  'Do you want to delete this suggestion?',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
              ],
            );
          },
        ),
        btnOkOnPress: () {
          _deleteCardFromDatabase(cardId);
        },
        btnCancelOnPress: () {
          // Handle cancel button press
        },
        btnCancelColor: Colors.grey,
        btnOkColor: Color.fromARGB(255, 39, 26, 99),
        btnOkText: 'Delete')
      ..show();
  }

  Future<void> _deleteCardFromDatabase(String cardId) async {
    try {
      String deletewhat = _getTabType().toLowerCase();
      print(cardId);

      final response = await http.delete(
        Uri.parse('http://192.168.1.11:3000/api/$deletewhat/$cardId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        print('Card deleted successfully');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Card deleted successfully'),
        ));
        setState(() {
          // Update the state if necessary
        });
      } else {
        // Handle error, maybe show an error dialog or log the error
        print('Error response: ${response.statusCode}');
        print('Error body: ${response.body}');
      }
    } catch (error) {
      print('Exception during HTTP request: $error');
    }
  }

  final List<String> imageUrls = [
    'https://images.unsplash.com/photo-1601754192553-fcc307b7710b?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MjB8fGZsaWdodHxlbnwwfHwwfHx8MA%3D%3D',
    'https://images.unsplash.com/photo-1506012787146-f92b2d7d6d96?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTh8fGZsaWdodHxlbnwwfHwwfHx8MA%3D%3D',
    'https://images.unsplash.com/photo-1556388158-158ea5ccacbd?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8ZmxpZ2h0fGVufDB8fDB8fHww',
  ];

  Widget _buildContentflights({required String title}) {
    tabType = 'Flights';

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchFlightsData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(''); // Loading indicator while fetching data
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No stays data available');
        } else {
          final flightsData = snapshot.data!;
          final Random random = Random();

          return ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              for (final flight in flightsData)
                _buildExampleCard(
                    latitude: flight['location'][0],
                    longitude: flight['location'][1],
                    title: flight['airline'] ?? '',
                    address: 'Antalya',
                    cardId: flight['_id'].toString(),
                    price: (flight['price'] * 1.41).ceil().toString(),
                    description: flight['description'] ?? '',
                    onTap: () {
                      // Handle tap for the stay
                    },
                    rating: flight['rating'] ?? '',
                    imageUrl: flight['image'] ?? '',
                    onDelete: () {
                      _showDeleteDialog(
                        context,
                        flight['_id'].toString(), // Pass cardId
                      );
                    },
                    favoritesCount: flight['favs'] ?? 0,
                    reportsCount: flight['reports'] ?? 0),
            ],
          );
        }
      },
    );
  }

  Widget _buildContentstays({required String title}) {
    tabType = 'Stays';
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchStaysData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(''); // Loading indicator while fetching data
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No stays data available');
        } else {
          final staysData = snapshot.data!;

          return ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              for (final stay in staysData)
                _buildExampleCard(
                    title: stay['name'] ?? '',
                    address: 'Antalya',
                    cardId: stay['_id'].toString(),
                    price: (stay['price'] / 3.5).ceil().toString(),
                    description: stay['description'] ?? '',
                    onTap: () {
                      // Handle tap for the stay
                    },
                    rating: stay['rating'] ?? '',
                    imageUrl: 'http:' + stay['image'] ?? '',
                    onDelete: () {
                      _showDeleteDialog(
                        context,
                        stay['_id'].toString(), // Pass cardId
                      );
                    },
                    favoritesCount: stay['favs'] ?? 0,
                    reportsCount: stay['reports'] ?? 0),
            ],
          );
        }
      },
    );
  }

  Widget _buildContenteateries({required String title}) {
    tabType = 'Eateries';
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchEateriesData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(''); // Loading indicator while fetching data
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No eateries data available');
        } else {
          final eateriesData = snapshot.data!;

          return ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              for (final eatery in eateriesData)
                _buildExampleCard(
                  latitude: eatery['location'][0],
                  longitude: eatery['location'][1],
                  title: eatery['name'] ?? '',
                  address: eatery['address'] ?? '',
                  cardId: eatery['_id'].toString(),
                  description: eatery['description'] ?? '',
                  onTap: () {
                    // Handle tap for the stay
                  },
                  imageUrl: eatery['image'] ?? '',
                  onDelete: () {
                    _showDeleteDialog(
                      context,
                      eatery['_id'].toString(), // Pass cardId
                    );
                  },
                  favoritesCount: eatery['favs'] ?? 0,
                  reportsCount: eatery['reports'] ?? 0,
                ),
            ],
          );
        }
      },
    );
  }

  List<Widget> _buildActivityCards(List<Map<String, dynamic>> activities) {
    return activities.map((activity) {
      return _buildExampleCard(
        title: activity['name'] ?? '',
        cardId: activity['_id'].toString() ?? '',
        description: activity['description'] ?? '',
        latitude: activity['location'][0].toDouble() ?? 0.0,
        longitude: activity['location'][1].toDouble() ?? 0.0,
        address: activity['address'] ?? 'Antalya',
        onTap: () {
          // Handle tap for the activity
        },
        imageUrl: activity['image'] ?? '',
        onDelete: () {
          _showDeleteDialog(
            context,
            activity['_id'].toString(), // Pass cardId
          );
        },
        favoritesCount: activity['favs'] ?? 0,
        reportsCount: activity['reports'] ?? 0,
      );
    }).toList();
  }

  Widget _buildContentactivities({required String title}) {
    tabType = 'Activities';
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchActivitiesData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(''); // Loading indicator while fetching data
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text('No activities data available');
          } else {
            final List<Map<String, dynamic>> activitiesData = snapshot.data!;

            List<Widget> shoppingCards = _buildActivityCards(
              activitiesData
                  .where((activity) => activity['goodfor'] == 'shopping')
                  .toList(),
            );
            List<Widget> sightseeingCards = _buildActivityCards(
              activitiesData
                  .where((activity) => activity['goodfor'] == 'sightseeing')
                  .toList(),
            );
            List<Widget> nightlifeCards = _buildActivityCards(
              activitiesData
                  .where((activity) => activity['goodfor'] == 'nightlife')
                  .toList(),
            );

            return DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: 'Shopping'),
                      Tab(text: 'Sightseeing'),
                      Tab(text: 'Night Life'),
                    ],
                    labelColor: Color.fromARGB(255, 39, 26, 99),
                    indicatorColor: Color.fromARGB(255, 39, 26, 99),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: ListView(
                            children: shoppingCards,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: ListView(
                            children: sightseeingCards,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: ListView(
                            children: nightlifeCards,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }
}
