import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:intl/intl.dart';
import 'package:masarna/trip/calender/dayview.dart';

class ExplorePage extends StatefulWidget {
  final DateTime selectedDate;

  final DayViewPage viewDayPage;

  ExplorePage(this.selectedDate, this.viewDayPage);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with TickerProviderStateMixin {
  final String title = "flights";
  String selectedLocation = 'Antalya'; // Default location
  bool isFABVisible = false;
  late AnimationController _animationController;
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
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Color.fromARGB(255, 39, 26, 99),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Row(
                children: [
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
    required String price,
    required String location,
    required double rating,
    required VoidCallback onTap,
    required String cardId,
  }) {
    bool isFavorite = favoritesMap[cardId] ?? false;

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
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              favoritesMap[cardId] = !isFavorite;
                            });
                          },
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.white,
                          ),
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
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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
                      Column(
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
                              Text(
                                location,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Color.fromARGB(255, 39, 26, 99),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              _showAddDialog(context, title, price, location, cardId);
                            },
                            icon: Icon(FlutterIcons.event_available_mdi),
                            label: Text('Add Event'),
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

  void _showAddDialog(BuildContext context, String title, String price, String location, String cardId) {
    TimeOfDay? _startTime;
    TimeOfDay? _endTime;

    AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.NO_HEADER,
      body: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              Text(
                'Personal Event',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Do you want to add this suggestion as a personal event?',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: _startTime ?? TimeOfDay.now(),
                      );

                      if (pickedTime != null && pickedTime != _startTime) {
                        setState(() {
                          _startTime = pickedTime;
                        });
                      }
                    },
                    icon: Icon(FlutterIcons.calendar_clock_mco),
                    label: Text('Start Time'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(213, 226, 224, 243),
                      foregroundColor: Color.fromARGB(255, 39, 26, 99),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: _endTime ?? TimeOfDay.now(),
                      );

                      if (pickedTime != null && pickedTime != _endTime) {
                        setState(() {
                          _endTime = pickedTime;
                        });
                      }
                    },
                    icon: Icon(FlutterIcons.calendar_clock_mco),
                    label: Text('End Time'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(213, 226, 224, 243),
                      foregroundColor: Color.fromARGB(255, 39, 26, 99),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ],
              ),
              if (_startTime != null && _endTime != null)
                Text(
                  'Selected Time: ${_startTime!.format(context)} - ${_endTime!.format(context)}',
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 16),
                ),
            ],
          );
        },
      ),
      btnOkOnPress: () {
        // Handle the selected day, start time, and end time
        DateTime selectedDay = widget.selectedDate;
        TimeOfDay startTime = _startTime!;
        TimeOfDay endTime = _endTime!;

        // Use the selectedDay, startTime, and endTime as needed
        print('Selected Day: ${DateFormat('yyyy-MM-dd').format(selectedDay)}');
        print('Start Time: ${startTime.format(context)}');
        print('End Time: ${endTime.format(context)}');
        print('Event Name: $title');
        print('Event Price: $price');
        print('Location Event: $location');
        widget.viewDayPage.addExploredEvent(
                selectedDay,
                startTime,
                endTime,
                title,
                price,
                location,
                true, // group events
              );
              },
              btnCancelOnPress: () {},
              btnCancelColor: Colors.grey,
              btnOkColor: Color.fromARGB(255, 39, 26, 99),
              btnOkText: 'Add',
            )..show();
          }

  Widget _buildContentflights({required String title}) {
    tabType = 'Flights';

    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.0),
        _buildExampleCard(
          title: 'Flight 1',
          location: "Antalya",
          cardId: 'flight1',
          price: "50",
          description: 'Description for Example 1.',
          onTap: () {
            // Handle tap for Example 1
          },
          imageUrl:
              'https://th.bing.com/th/id/R.757f40f8b12f06da4cb95a5f25ba8d60?rik=tXkO9YqBORITCA&riu=http%3a%2f%2f1.bp.blogspot.com%2f_3r5UDkGjDGE%2fShmHPi8X2aI%2fAAAAAAAAEwo%2f33gasvWVsTA%2fw1200-h630-p-k-no-nu%2f3082453530_ea932b4661_b.jpg&ehk=qI8uWACfXVlWNYhiGy4Mn3HQN9n5saYHanLMpKQX34s%3d&risl=&pid=ImgRaw&r=0',
          rating: 4.9,
        ),
        _buildExampleCard(
          title: 'Flight 2',
          description: 'Description for Example 2.',
          location: "Antalya",
          cardId: 'flight2',
          rating: 4.9,
          price: "50",
          onTap: () {
            // Handle tap for Example 2
          },
          imageUrl:
              'https://th.bing.com/th/id/R.757f40f8b12f06da4cb95a5f25ba8d60?rik=tXkO9YqBORITCA&riu=http%3a%2f%2f1.bp.blogspot.com%2f_3r5UDkGjDGE%2fShmHPi8X2aI%2fAAAAAAAAEwo%2f33gasvWVsTA%2fw1200-h630-p-k-no-nu%2f3082453530_ea932b4661_b.jpg&ehk=qI8uWACfXVlWNYhiGy4Mn3HQN9n5saYHanLMpKQX34s%3d&risl=&pid=ImgRaw&r=0',
        ),
        // Add more example cards as needed
      ],
    );
  }

  Widget _buildContentstays({required String title}) {
    tabType = 'Stays';
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.0),
        _buildExampleCard(
          title: 'Stay 1',
          location: "Antalya",
          cardId: 'stay1',
          price: "50",
          description:
              'Description for Example 1. This is a longer description to demonstrate text wrapping in a more realistic scenario.',
          onTap: () {
            // Handle tap for Example 1
          },
          rating: 4.9,
          imageUrl:
              'https://th.bing.com/th/id/R.757f40f8b12f06da4cb95a5f25ba8d60?rik=tXkO9YqBORITCA&riu=http%3a%2f%2f1.bp.blogspot.com%2f_3r5UDkGjDGE%2fShmHPi8X2aI%2fAAAAAAAAEwo%2f33gasvWVsTA%2fw1200-h630-p-k-no-nu%2f3082453530_ea932b4661_b.jpg&ehk=qI8uWACfXVlWNYhiGy4Mn3HQN9n5saYHanLMpKQX34s%3d&risl=&pid=ImgRaw&r=0',
        ),
        _buildExampleCard(
          title: 'Stay 2',
          location: "Antalya",
          cardId: 'stay2',
          price: "50",
          description: 'Description for Example 2.',
          onTap: () {
            // Handle tap for Example 2
          },
          rating: 4.9,
          imageUrl:
              'https://th.bing.com/th/id/R.757f40f8b12f06da4cb95a5f25ba8d60?rik=tXkO9YqBORITCA&riu=http%3a%2f%2f1.bp.blogspot.com%2f_3r5UDkGjDGE%2fShmHPi8X2aI%2fAAAAAAAAEwo%2f33gasvWVsTA%2fw1200-h630-p-k-no-nu%2f3082453530_ea932b4661_b.jpg&ehk=qI8uWACfXVlWNYhiGy4Mn3HQN9n5saYHanLMpKQX34s%3d&risl=&pid=ImgRaw&r=0',
        ),
        // Add more example cards as needed
      ],
    );
  }

  Widget _buildContenteateries({required String title}) {
    tabType = 'Eateries';
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.0),
        _buildExampleCard(
          title: 'Eatery 1',
          location: "Antalya",
          cardId: 'eat1',
          price: "50",
          rating: 4.9,
          description:
              'Description for Example 1. This is a longer description to demonstrate text wrapping in a more realistic scenario.',
          onTap: () {
            // Handle tap for Example 1
          },
          imageUrl:
              'https://th.bing.com/th/id/R.757f40f8b12f06da4cb95a5f25ba8d60?rik=tXkO9YqBORITCA&riu=http%3a%2f%2f1.bp.blogspot.com%2f_3r5UDkGjDGE%2fShmHPi8X2aI%2fAAAAAAAAEwo%2f33gasvWVsTA%2fw1200-h630-p-k-no-nu%2f3082453530_ea932b4661_b.jpg&ehk=qI8uWACfXVlWNYhiGy4Mn3HQN9n5saYHanLMpKQX34s%3d&risl=&pid=ImgRaw&r=0',
        ),
        _buildExampleCard(
          title: 'Eatery 2',
          location: "Antalya",
          cardId: 'eat2',
          price: "50",
          rating: 4.9,
          description: 'Description for Example 2.',
          onTap: () {
            // Handle tap for Example 2
          },
          imageUrl:
              'https://th.bing.com/th/id/R.757f40f8b12f06da4cb95a5f25ba8d60?rik=tXkO9YqBORITCA&riu=http%3a%2f%2f1.bp.blogspot.com%2f_3r5UDkGjDGE%2fShmHPi8X2aI%2fAAAAAAAAEwo%2f33gasvWVsTA%2fw1200-h630-p-k-no-nu%2f3082453530_ea932b4661_b.jpg&ehk=qI8uWACfXVlWNYhiGy4Mn3HQN9n5saYHanLMpKQX34s%3d&risl=&pid=ImgRaw&r=0',
        ),
        // Add more example cards as needed
      ],
    );
  }

  Widget _buildContentactivities({required String title}) {
    tabType = 'Activities';
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.0),
        _buildExampleCard(
          title: 'Activity 1',
          location: "Antalya",
          cardId: 'act1',
          rating: 4.9,
          price: "50",
          description:
              'Description for Example 1. This is a longer description to demonstrate text wrapping in a more realistic scenario.',
          onTap: () {
            // Handle tap for Example 1
          },
          imageUrl:
              'https://th.bing.com/th/id/R.757f40f8b12f06da4cb95a5f25ba8d60?rik=tXkO9YqBORITCA&riu=http%3a%2f%2f1.bp.blogspot.com%2f_3r5UDkGjDGE%2fShmHPi8X2aI%2fAAAAAAAAEwo%2f33gasvWVsTA%2fw1200-h630-p-k-no-nu%2f3082453530_ea932b4661_b.jpg&ehk=qI8uWACfXVlWNYhiGy4Mn3HQN9n5saYHanLMpKQX34s%3d&risl=&pid=ImgRaw&r=0',
        ),
        _buildExampleCard(
          title: 'Activity 2',
          location: "Antalya",
          cardId: 'act2',
          rating: 4.9,
          price: "50",
          description: 'Description for Example 2.',
          onTap: () {
            // Handle tap for Example 2
          },
          imageUrl:
              'https://th.bing.com/th/id/R.757f40f8b12f06da4cb95a5f25ba8d60?rik=tXkO9YqBORITCA&riu=http%3a%2f%2f1.bp.blogspot.com%2f_3r5UDkGjDGE%2fShmHPi8X2aI%2fAAAAAAAAEwo%2f33gasvWVsTA%2fw1200-h630-p-k-no-nu%2f3082453530_ea932b4661_b.jpg&ehk=qI8uWACfXVlWNYhiGy4Mn3HQN9n5saYHanLMpKQX34s%3d&risl=&pid=ImgRaw&r=0',
        ),
        // Add more example cards as needed
      ],
    );
  }
}