import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:masarna/globalstate.dart';
import 'package:masarna/trip/calender/calendar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class LocationInfo {
  final LatLng coordinates;
  final String eventType;
  final String eventName;
  LocationInfo(
      {required this.coordinates,
      required this.eventType,
      required this.eventName});
}

class MapPage extends StatefulWidget {
  late List<LocationInfo> locations = [];

  MapPage();

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  List<Marker> markers = [];
  Set<Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    fetchMapDetails();
    // Fetch budget details when the page is initialized
  }

  Future<void> fetchMapDetails() async {
    try {
      final String userId = Provider.of<GlobalState>(context, listen: false).id;
      final String planId =
          Provider.of<GlobalState>(context, listen: false).planid;

      final Uri uri = Uri.parse(
          'http://192.168.1.11:3000/api/$planId/$userId/calendarevents');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> calendarevents = data['calendarevents'];
        print('-------------Calendarevents: $calendarevents'); // Add this line

        setState(() {
          widget.locations = calendarevents
              .map((eventData) => LocationInfo(
                    coordinates: LatLng(
                      eventData['location'][
                          1], // Assuming 'coordinates' is an array [longitude, latitude]
                      eventData['location'][0],
                    ),
                    eventType:
                        eventData['type'] == 'group' ? 'group' : 'personal',
                    eventName: eventData['name'],
                  ))
              .toList();
                _getCustomMarkerIcons(); // Move the call here

        });
      } else {
        // Handle error
        print(
            'Failed to fetch map details. Status code: ${response.statusCode}');
        if (response.statusCode == 404) {
          print('Resource not found. Response body: ${response.body}');
          // Handle accordingly, e.g., set default values or show an error message.
        } else if (response.statusCode == 200) {
          // Process the successful response as before.
        } else {
          print(
              'Failed to fetch map details. Status code: ${response.statusCode}');
        }
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    if (mapController != null && widget.locations.isNotEmpty) {
      _createPolylines();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Map',
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
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(41.9028, 12.4964),
        //  widget.locations.isNotEmpty
           //   ? widget.locations.first.coordinates
            //  : LatLng(0, 0),
          zoom: 5.0,
        ),
        markers: Set<Marker>.from(markers),
        polylines: polylines,
      ),
    );
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();

    if (status == PermissionStatus.denied) {
      // Handle denied permission
      print("Location permission denied");
    } else if (status == PermissionStatus.granted) {
      // Permission granted, proceed with your location-related tasks
      _getUserLocation();
    }
  }

 Future<void> _getUserLocation() async {
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
  setState(() {
    widget.locations.add(LocationInfo(
      coordinates: LatLng(position.latitude, position.longitude),
      eventType: "current location",
      eventName: 'You', // You can customize this based on your logic
    ));
  });
   print('Total locations including current location: ${widget.locations.length}');


  // Move the camera to the new location
  mapController?.animateCamera(
    CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
  );

  // Call _getCustomMarkerIcons after updating the state
  _getCustomMarkerIcons();
}

/*
Future<void> _getUserLocation() async {
  // Replace these values with the desired coordinates for your current location
  double latitude = 32.2227; // Example latitude
  double longitude = 35.2621; // Example longitude

  setState(() {
    widget.locations.add(LocationInfo(
      coordinates: LatLng(latitude, longitude),
      eventType: "current location",
      eventName: 'You', // You can customize this based on your logic
    ));
  });
     print('Total locations including current location: ${widget.locations.length}');


  // Move the camera to the new location
  mapController?.animateCamera(
    CameraUpdate.newLatLng(LatLng(latitude, longitude)),
  );
   _getCustomMarkerIcons();
}*/



 Future<void> _getCustomMarkerIcons() async {
  for (int i = 0; i < widget.locations.length; i++) {
    print('----------------------------------');
    print('Marker $i coordinates: ${widget.locations[i].coordinates}');

    String markerIconPath = _getMarkerIconPath(
      widget.locations[i].eventType,
      i == widget.locations.length - 1, // Check if it's the last location
    );

    print('Marker $i: $markerIconPath');

    Uint8List markerIcon = await getBytesFromAsset(markerIconPath, 30, 30);

    if (markerIcon.isNotEmpty) {
      print('Marker $i loaded successfully');

      setState(() {
        markers.add(
          Marker(
            markerId: MarkerId("marker_$i"),
            position: widget.locations[i].coordinates,
            icon: BitmapDescriptor.fromBytes(markerIcon),
            infoWindow: InfoWindow(
              title: widget.locations[i].eventName,
              snippet: widget.locations[i].eventType,
            ),
            draggable: true,
            onDragEnd: (value) {
              // Handle marker drag
            },
          ),
        );
      });
    } else {
      print('Failed to load marker $i');
    }
  }
}

  String _getMarkerIconPath(String eventType, bool isCurrentLocation) {
    if (isCurrentLocation) {
      return 'images/design3 (2).png';
    } else {
      switch (eventType) {
        case 'personal':
          return 'images/bb.png';
        case 'group':
          return 'images/gr.png';
        default:
          return 'images/design3 (2).png';
      }
    }
  }

Future<void> _createPolylines() async {
  // Ensure there are at least two locations in the list
  if (widget.locations.length < 2) {
    return;
  }

  // Filter out the current location
  List<LatLng> nonCurrentLocations = widget.locations
      .where((location) => location.eventType != "current location")
      .map((location) => location.coordinates)
      .toList();

  // Ensure there are non-current locations remaining
  if (nonCurrentLocations.length < 2) {
    return;
  }

  // Sort the non-current locations
  nonCurrentLocations.sort((a, b) {
    double distanceToA = Geolocator.distanceBetween(
      a.latitude,
      a.longitude,
      nonCurrentLocations.first.latitude,
      nonCurrentLocations.first.longitude,
    );

    double distanceToB = Geolocator.distanceBetween(
      b.latitude,
      b.longitude,
      nonCurrentLocations.first.latitude,
      nonCurrentLocations.first.longitude,
    );

    return distanceToA.compareTo(distanceToB);
  });

  // Create new polylines
  Set<Polyline> newPolylines = {
    Polyline(
      polylineId: PolylineId("route"),
      color: Color.fromARGB(255, 39, 26, 99),
      width: 3,
      points: nonCurrentLocations,
    ),
  };

  // Update the state with the new polylines
  setState(() {
    polylines = newPolylines;
  });
}






  Future<Uint8List> getBytesFromAsset(
      String path, int width, int height) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec =
        await ui.instantiateImageCodec(Uint8List.view(data.buffer));
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }
}
