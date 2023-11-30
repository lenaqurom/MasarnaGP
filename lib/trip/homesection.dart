import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:masarna/trip/stays/staycomment.dart';

class HomeSectionsPage extends StatefulWidget {
  final String planId;
  HomeSectionsPage({required this.planId});
  @override
  _HomeSectionsPageState createState() => _HomeSectionsPageState();
}

class _HomeSectionsPageState extends State<HomeSectionsPage>
    with TickerProviderStateMixin {
  final String title = "flights";
  String selectedLocation = 'Antalya'; // Default location
  bool isFABVisible = false; // Add this variable
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool isExpanded = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
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
                      Navigator.of(context).pop();
                    },
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
                      items: [
                        'Antalya',
                        'Bali',
                        'Paris'
                        
                      ].map((String location) {
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
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.menu,
                    size: 20,
                    color: Color.fromARGB(255, 39, 26, 99),
                  ),
                  onPressed: () {
                    _scaffoldKey.currentState?.openEndDrawer();
                  },
                ),
              ],
              bottom: TabBar(
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
                  children: [
                    _buildContentflights(title: 'Flights'),
                    _buildContentstays(title: 'Stays'),
                    _buildContenteateries(title: 'Eateries'),
                    _buildContentactivities(title: 'Activities'),
                  ],
                ),
                Visibility(
                  visible: isFABVisible,
                  child: Positioned(
                    bottom: 85.0,
                    right: 16.0,
                    child: FloatingActionButton(
                      onPressed: () {},
                      child: Icon(Icons.poll, size: 20),
                      backgroundColor: Color.fromARGB(255, 39, 26, 99),
                    ),
                  ),
                ),
                Visibility(
                  visible: isFABVisible,
                  child: Positioned(
                    bottom: 150.0,
                    right: 16.0,
                    child: FloatingActionButton(
                      onPressed: () {
                        Navigator.of(context).push(
                       MaterialPageRoute(
                         builder: (context) => StayCommentPage(),
                        ),
                       );
                      },
                      child: Icon(FontAwesome.comment, size: 20),
                      backgroundColor: Color.fromARGB(255, 39, 26, 99),
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                _toggleExpanded();
              },
              child: AnimatedIcon(
                icon: AnimatedIcons.add_event,
                progress: _animation,
              ),
              backgroundColor: Color.fromARGB(255, 39, 26, 99),
            ),
            endDrawer: Drawer(
              child: Container(
                color: const Color.fromARGB(255, 255, 255, 255),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Center(
                          child:
                              Image.asset('images/logo6.png', fit: BoxFit.fill),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(AntDesign.adduser),
                      title: Text('Add participants',
                          style: TextStyle(
                              color: Color.fromARGB(255, 39, 26, 99),
                              fontFamily: 'Dosis',
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(AntDesign.team),
                      title: Text('See members',
                          style: TextStyle(
                              color: Color.fromARGB(255, 39, 26, 99),
                              fontFamily: 'Dosis',
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(AntDesign.calculator),
                      title: Text('Calculate budget',
                          style: TextStyle(
                              color: Color.fromARGB(255, 39, 26, 99),
                              fontFamily: 'Dosis',
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(FontAwesome.map_marker),
                      title: Text('Map',
                          style: TextStyle(
                              color: Color.fromARGB(255, 39, 26, 99),
                              fontFamily: 'Dosis',
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.photo_album),
                      title: Text('Make memories',
                          style: TextStyle(
                              color: Color.fromARGB(255, 39, 26, 99),
                              fontFamily: 'Dosis',
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(FontAwesome.send),
                      title: Text('',
                          style: TextStyle(
                              color: Color.fromARGB(255, 39, 26, 99),
                              fontFamily: 'Dosis',
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle button press
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromARGB(
                              255, 39, 26, 99), // Change the button color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                20.0), // Adjust the border radius
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(AntDesign.check, color: Colors.white),
                              SizedBox(width: 8.0),
                              Text(
                                'Finalize',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Dosis',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
              child: Image.network(
                imageUrl,
                height: 200.0,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  }
                },
                errorBuilder: (BuildContext context, Object error,
                    StackTrace? stackTrace) {
                  // Handle image loading errors here
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(Icons.error, color: Colors.red),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
      isFABVisible = !isFABVisible; // Toggle visibility based on expansion
      if (isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Widget _buildContentflights({required String title}) {
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
          description:
              'desc',
          onTap: () {
            // Handle tap for Example 1
          },
          imageUrl:
              'https://th.bing.com/th/id/R.757f40f8b12f06da4cb95a5f25ba8d60?rik=tXkO9YqBORITCA&riu=http%3a%2f%2f1.bp.blogspot.com%2f_3r5UDkGjDGE%2fShmHPi8X2aI%2fAAAAAAAAEwo%2f33gasvWVsTA%2fw1200-h630-p-k-no-nu%2f3082453530_ea932b4661_b.jpg&ehk=qI8uWACfXVlWNYhiGy4Mn3HQN9n5saYHanLMpKQX34s%3d&risl=&pid=ImgRaw&r=0',
        ),
        _buildExampleCard(
          title: 'Flight 2',
          description: '',
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
          description:
              '',
          onTap: () {
            // Handle tap for Example 1
          },
          imageUrl:
              'https://th.bing.com/th/id/R.757f40f8b12f06da4cb95a5f25ba8d60?rik=tXkO9YqBORITCA&riu=http%3a%2f%2f1.bp.blogspot.com%2f_3r5UDkGjDGE%2fShmHPi8X2aI%2fAAAAAAAAEwo%2f33gasvWVsTA%2fw1200-h630-p-k-no-nu%2f3082453530_ea932b4661_b.jpg&ehk=qI8uWACfXVlWNYhiGy4Mn3HQN9n5saYHanLMpKQX34s%3d&risl=&pid=ImgRaw&r=0',
        ),
        _buildExampleCard(
          title: 'Stay 2',
          description: '',
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

  Widget _buildContenteateries({required String title}) {
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
          description:
              '',
          onTap: () {
            // Handle tap for Example 1
          },
          imageUrl:
              'https://th.bing.com/th/id/R.757f40f8b12f06da4cb95a5f25ba8d60?rik=tXkO9YqBORITCA&riu=http%3a%2f%2f1.bp.blogspot.com%2f_3r5UDkGjDGE%2fShmHPi8X2aI%2fAAAAAAAAEwo%2f33gasvWVsTA%2fw1200-h630-p-k-no-nu%2f3082453530_ea932b4661_b.jpg&ehk=qI8uWACfXVlWNYhiGy4Mn3HQN9n5saYHanLMpKQX34s%3d&risl=&pid=ImgRaw&r=0',
        ),
        _buildExampleCard(
          title: 'Eatery 2',
          description: '',
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
          description:
              '',
          onTap: () {
            // Handle tap for Example 1
          },
          imageUrl:
              'https://th.bing.com/th/id/R.757f40f8b12f06da4cb95a5f25ba8d60?rik=tXkO9YqBORITCA&riu=http%3a%2f%2f1.bp.blogspot.com%2f_3r5UDkGjDGE%2fShmHPi8X2aI%2fAAAAAAAAEwo%2f33gasvWVsTA%2fw1200-h630-p-k-no-nu%2f3082453530_ea932b4661_b.jpg&ehk=qI8uWACfXVlWNYhiGy4Mn3HQN9n5saYHanLMpKQX34s%3d&risl=&pid=ImgRaw&r=0',
        ),
        _buildExampleCard(
          title: 'Activity 2',
          description: '',
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
