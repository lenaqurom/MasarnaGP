import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:masarna/globalstate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class LocationInfo {
  final LatLng coordinates;
  final String eventType;
  final String eventName;
  LocationInfo({required this.coordinates, required this.eventType, required this.eventName});
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
    fetchMapDetails(); // Fetch budget details when the page is initialized
  }
  Future<void> fetchMapDetails() async {
    try {
      final String userId = Provider.of<GlobalState>(context, listen: false).id;
      final Uri uri = Uri.parse('http://192.168.1.104:3000/api/65720ce9bbfa2f36ed8dd5f5/655e701ae784f2d47cd02151/calendarevents');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> calendarevents = data['calendarevents'];
      print('Calendarevents: $calendarevents'); // Add this line

        setState(() {
          widget.locations = calendarevents
              .map((eventData) => LocationInfo(
                    coordinates: LatLng(
                      eventData['location'][1], // Assuming 'coordinates' is an array [longitude, latitude]
                      eventData['location'][0],
                    ),
                    eventType: eventData['type'] == 'group' ? 'group' : 'personal',
                    eventName: eventData['name'],
                  ))
              .toList();
              
        });

      } else {
        // Handle error
      print('Failed to fetch map details. Status code: ${response.statusCode}');
      if (response.statusCode == 404) {
  print('Resource not found. Response body: ${response.body}');
  // Handle accordingly, e.g., set default values or show an error message.
} else if (response.statusCode == 200) {
  // Process the successful response as before.
} else {
  print('Failed to fetch map details. Status code: ${response.statusCode}');
}

      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller; // Initialize the controller here

    if (widget.locations.isNotEmpty) {
      _getCustomMarkerIcons();
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
            Navigator.pop(context);
          },
        ),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: widget.locations.isNotEmpty ? widget.locations.first.coordinates : LatLng(0, 0),
          zoom: 15.0,
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
        eventType: "current location", eventName: 'You', // You can customize this based on your logic
      ));
    });

    // Move the camera to the new location
    mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
    );
  }

Future<void> _getCustomMarkerIcons() async {
  for (int i = 0; i < widget.locations.length; i++) {
    String markerIconPath = _getMarkerIconPath(
      widget.locations[i].eventType,
      i == widget.locations.length - 1, // Check if it's the last location (current location)
    );
    Uint8List markerIcon = await getBytesFromAsset(markerIconPath, 30, 30); // Adjust the width and height as needed
    setState(() {
      markers.add(
        Marker(
          markerId: MarkerId("marker_$i"),
          position: widget.locations[i].coordinates,
          icon: BitmapDescriptor.fromBytes(markerIcon),
          infoWindow: InfoWindow(
            title: widget.locations[i].eventName, // Use the event name as the title
            snippet: widget.locations[i].eventType,
          ),
          draggable: true,
          onDragEnd: (value) {
            // Handle marker drag
          },
        ),
      );
    });
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

  List<LatLng> sortedLocations = widget.locations.map((location) => location.coordinates).toList();

  sortedLocations.sort((a, b) {
    double distanceToA = Geolocator.distanceBetween(
      a.latitude,
      a.longitude,
      sortedLocations.first.latitude,
      sortedLocations.first.longitude,
    );

    double distanceToB = Geolocator.distanceBetween(
      b.latitude,
      b.longitude,
      sortedLocations.first.latitude,
      sortedLocations.first.longitude,
    );

    return distanceToA.compareTo(distanceToB);
  });

  List<LatLng> polylinePoints = [widget.locations.first.coordinates, ...sortedLocations];

  Set<Polyline> newPolylines = {
    Polyline(
      polylineId: PolylineId("route"),
      color: Color.fromARGB(255, 39, 26, 99),
      width: 3,
      points: polylinePoints,
    ),
  };

  setState(() {
    polylines = newPolylines;
  });
}

  Future<Uint8List> getBytesFromAsset(String path, int width, int height) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(Uint8List.view(data.buffer));
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }
}

