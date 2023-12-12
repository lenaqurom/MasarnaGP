
import 'package:flutter/material.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:intl/intl.dart';
import 'package:masarna/globalstate.dart';
import 'package:masarna/trip/calender/datetime.dart';
import 'package:masarna/trip/calender/dayview.dart';
import 'package:masarna/trip/drawer/calculatebudget.dart';
import 'package:masarna/trip/homesection.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyCalendarPage extends StatefulWidget {
  @override
  _MyCalendarPageState createState() => _MyCalendarPageState();
}

class _MyCalendarPageState extends State<MyCalendarPage> {
  List<Appointment> _events = <Appointment>[];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<DateTime, String> _groupDayPlans = {};

  @override
  void initState() {
    super.initState();
    _fetchEventsFromBackend();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Calendar',
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
                    child: Image.asset('images/logo6.png', fit: BoxFit.fill),
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
                  Navigator.pushNamed(context, '/addparticipants');
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
                 Navigator.pushReplacement(
           context, MaterialPageRoute(builder: (context) => BudgetPage()));
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
                leading: Icon(Icons.explore_sharp),
                title: Text('Explore',
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
                leading: Icon(Icons.schedule),
                title: Text('Others\' schedules',
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
                margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              ),
            ],
          ),
        ),
      ),
      body: SfCalendar(
        headerStyle: CalendarHeaderStyle(
          textStyle: TextStyle(
            fontSize: 18, // Set your desired font size
            fontWeight:
                FontWeight.bold, // Optional: You can customize the font weight
            color: Color.fromARGB(255, 39, 26, 99),
          ),
        ),
        showNavigationArrow: true,
        backgroundColor: Colors.white,
        view: CalendarView.month,
        todayHighlightColor: Color.fromARGB(255, 39, 26, 99),
        selectionDecoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: Color.fromARGB(255, 39, 26, 99), width: 2),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          shape: BoxShape.rectangle,
        ),
        dataSource: AppointmentDataSource(_events),
        scheduleViewSettings: ScheduleViewSettings(
          dayHeaderSettings: DayHeaderSettings(
            dayFormat: 'EEE',
          ),
        ),
        onTap: (CalendarTapDetails details) {
          
          if (details.targetElement == CalendarElement.calendarCell &&
              details.appointments != null &&
              details.appointments!.isNotEmpty) {
           if (details.appointments!
    .any((event) => event.color == Color(0xFF004aad))) {
final DateTime selectedDate = details.date!;
print('Selected Date: $selectedDate');

print('_groupDayPlans: $_groupDayPlans'); // Print the contents of _groupDayPlans

final groupDayPlanId = _groupDayPlans[selectedDate.toUtc()];
print('Group Day Plan ID: $groupDayPlanId');
print('selectedDate.toUtc(): ${selectedDate.toUtc()}');
print('_groupDayPlans[selectedDate.toUtc()]: ${_groupDayPlans[selectedDate.toUtc()]}');


if (groupDayPlanId != null) {
  _showGroupEventDialog(context, selectedDate, groupDayPlanId);
} else {
  // Handle the case where groupDayPlanId is null
  print("GroupDayPlanId is null!");
}




} else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DayViewPage(
                    selectedDate: details.date!,
                    events: _events,
                  ),
                ),
              );
            }
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showEventType();
        },
        backgroundColor: Color.fromARGB(255, 39, 26, 99),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showGroupEventDialog(
      BuildContext context, DateTime date, String groupPlanId) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.NO_HEADER,
      animType: AnimType.SCALE,
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This is a group event! Want to go plan with your group or see your schedule for this day?',
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 39, 26, 99),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DayViewPage(
                          selectedDate: date,
                          events: _events,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 39, 26, 99),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: Icon(Icons.schedule, size: 30, color: Colors.white),
                  label: Text(
                    'View my schedule',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                        color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: () {
                    print(groupPlanId);
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SectionsPage(planId: groupPlanId),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 39, 26, 99),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: Icon(Icons.group_work, size: 30, color: Colors.white),
                  label: Text(
                    'Plan with group',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                        color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ).show();
  }

  void _showEventType() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.NO_HEADER,
      animType: AnimType.SCALE,
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'What kind of event do you want to add?',
                style: TextStyle(
                  fontSize: 15,
                  color: Color.fromARGB(255, 39, 26, 99),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showPersonalEventForm(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 39, 26, 99),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Personal Event',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                        color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 40, // Set a fixed height for the buttons
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showGroupEventForm(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 39, 26, 99),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: Icon(
                    Icons.group,
                    size: 30,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Group Event',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                        color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ).show();
  }

  Future<void> _showPersonalEventForm(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedStartTime = TimeOfDay.now();
    TimeOfDay selectedEndTime = selectedStartTime.replacing(
      hour: (selectedStartTime.hour + 1) % TimeOfDay.hoursPerDay,
    );

    String eventName = '';
    String eventPrice = '0';

    await AwesomeDialog(
      context: context,
      dialogType: DialogType.NO_HEADER,
      animType: AnimType.SCALE,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Personal Event',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
                color: Color.fromARGB(255, 39, 26, 99),
              ),
            ),
            SizedBox(height: 8),
            _buildBorderedTextField('Event Name *', Icons.event, (value) {
              eventName = value;
            }),
            SizedBox(height: 8),
            _buildBorderedTextField('Event Price', Icons.attach_money, (value) {
              eventPrice = value;
            }, keyboardType: TextInputType.numberWithOptions(decimal: true)),
            _buildDateTimeField(
              '',
              Icons.calendar_today,
              DateChooser(
                onDateChanged: (DateTime date) {
                  setState(() {
                    selectedDate = date;
                  });
                },
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDateTimeField(
                    'Start Time',
                    Icons.access_time,
                    TimeChooser(
                      onTimeChanged: (TimeOfDay time) {
                        setState(() {
                          selectedStartTime = time;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildDateTimeField(
                    'End Time',
                    Icons.access_time,
                    TimeChooser(
                      onTimeChanged: (TimeOfDay time) {
                        setState(() {
                          selectedEndTime = time;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      btnOkColor: Color.fromRGBO(39, 26, 99, 1),
      btnOkText: 'Add',
      btnOkOnPress: () {
        if (eventName.isNotEmpty) {
          _addPersonalEvent(
            selectedDate,
            selectedStartTime,
            selectedEndTime,
            eventName,
            eventPrice,
            // personal events
          );
        } else {
          _showErrorDialog(context, 'Event Name is required.');
        }
      },
    ).show();
  }

  Future<void> _showGroupEventForm(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedStartTime = TimeOfDay.now();
    TimeOfDay selectedEndTime = selectedStartTime.replacing(
      hour: (selectedStartTime.hour + 24) % TimeOfDay.hoursPerDay,
    );

    String eventName = '';
    String eventPrice = '0';
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.NO_HEADER,
      animType: AnimType.SCALE,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Group Event',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
                color: Color.fromARGB(255, 39, 26, 99),
              ),
            ),
            _buildDateTimeField(
              '',
              Icons.calendar_today,
              DateChooser(
                onDateChanged: (DateTime date) {
                  setState(() {
                    selectedDate = date;
                  });
                },
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
      btnOkColor: Color.fromRGBO(39, 26, 99, 1),
      btnOkText: 'Add',
      btnOkOnPress: () async {
        try {
    // Replace the URL with your actual backend endpoint
    final String apiUrl = 'http://192.168.1.2:3000/api/oneplan/65720ce9bbfa2f36ed8dd5f5/groupdayplan';

  final formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    final response = await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode({
        'date': formattedDate,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Update the UI and fetch events
      setState(() {
        _fetchEventsFromBackend();
      });

      // Show a success message or perform any other actions
      print(responseData['message']);
      print(responseData['plan']);
    } else {
      // Handle errors
      print('Failed to add group event. Status code: ${response.statusCode}');
    }
  } catch (error) {
    // Handle network errors
    print('Error adding group event: $error');
  }

      },
    ).show();
  }

  Future<void> _addPersonalEvent(DateTime selectedDate, TimeOfDay startTime,
      TimeOfDay endTime, String eventName, String eventPrice) async {
    // Print the request body for debugging
    print('Request Body: ${json.encode({
          'name': eventName,
          'date': formatDateForAPI(selectedDate),
          'price': eventPrice,
          'starttime': _formatTimeOfDay(startTime),
          'endtime': _formatTimeOfDay(endTime),
          // Add other event details as needed
        })}');
    print('Event Name: ${eventName}');

    // Replace with your API endpoint
    String apiUrl =
        'http://192.168.1.2:3000/api/65720ce9bbfa2f36ed8dd5f5/personalplan/655e701ae784f2d47cd02151';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode({
          'name': eventName,
          'date': formatDateForAPI(selectedDate),
          'price': eventPrice,
          'starttime': _formatTimeOfDay(startTime),
          'endtime': _formatTimeOfDay(endTime),
          // Add other event details as needed
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        print('Personal event added successfully');
        // Refresh the calendar events after adding a new event
        _fetchEventsFromBackend();
      } else {
        print('Failed to add personal event: ${response.statusCode}');
      }
    } catch (error) {
      print('Error adding personal event: $error');
    }
  }

  String formatDateForAPI(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final formattedTime = DateFormat.Hm().format(dateTime);
    return formattedTime;
  }

  Widget _buildBorderedTextField(
    String label,
    IconData icon,
    Function(String) onChanged, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Container(
          height: 43,
          child: TextField(
            keyboardType: keyboardType,
            onChanged: onChanged,
            style:
                TextStyle(fontSize: 16, color: Color.fromARGB(255, 39, 26, 99)),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(0),
              hintText: label,
              hintStyle: TextStyle(fontSize: 16),
              prefixIcon: Icon(icon, color: Color.fromARGB(255, 39, 26, 99)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(22),
                ),
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 39, 26, 99),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(22),
                ),
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 39, 26, 99),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeField(String label, IconData icon, Widget child) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 10),
        Container(
          height: 43,
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromARGB(255, 39, 26, 99)),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Icon(icon, color: Color.fromARGB(255, 39, 26, 99)),
              SizedBox(width: 10),
              Expanded(child: Center(child: child)),
            ],
          ),
        ),
      ],
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.ERROR,
      animType: AnimType.SCALE,
      title: 'Error',
      desc: errorMessage,
      btnOkOnPress: () {
        _showGroupEventForm(context);
      },
      btnOkColor: Color.fromRGBO(39, 26, 99, 1),
    ).show();
  }

  Future<void> _fetchEventsFromBackend() async {
    final String baseUrl =
        'http://192.168.1.2:3000/api'; // Replace with your actual API base URL
    final String planId =
        '65720ce9bbfa2f36ed8dd5f5'; // Replace with your actual planId
    final String userId = Provider.of<GlobalState>(context, listen: false)
        .id; // Replace with your actual userId

    try {
      final Uri uri = Uri.parse('$baseUrl/$planId/$userId/calendarevents');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        print("fetch");

        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> calendarevents = data['calendarevents'];
        final List<dynamic> groupDayPlans = data['groupDayPlans'];

        // Clear existing events
        setState(() {
          print("setting state");
          _events.clear();
          _groupDayPlans.clear();
          for (Map<String, dynamic> event in calendarevents) {
            final DateTime startTimeDateTime =
                DateTime.parse(event['starttime']).toLocal();
            final TimeOfDay startTime =
                TimeOfDay.fromDateTime(startTimeDateTime);
            print('Start Time: $startTimeDateTime');
            final DateTime endTimeDateTime =
                DateTime.parse(event['endtime']).toLocal();
            final TimeOfDay endTime = TimeOfDay.fromDateTime(endTimeDateTime);

            print('End Time: $endTimeDateTime');

            // Create an Appointment object and add it to the _events list
            _events.add(Appointment(
              startTime: DateTime(
                startTimeDateTime.year,
                startTimeDateTime.month,
                startTimeDateTime.day,
                startTime.hour,
                startTime.minute,
              ),
              endTime: DateTime(
                endTimeDateTime.year,
                endTimeDateTime.month,
                endTimeDateTime.day,
                endTime.hour,
                endTime.minute,
              ),
              subject: event['name'],
              color: event['type'] == 'group'
                  ? Color(0xFF004aad)
                  : Color(0xFFcb6ce6),
              resourceIds: [event['price'].toString()],
            ));
          }

          // Update the UI to reflect the changes
          print('Number of events fetched: ${_events.length}');
          print('Events: $_events');

          for (Map<String, dynamic> groupDayPlan in groupDayPlans) {
              print('Group Day Plan: $groupDayPlan');
  final DateTime planDate = DateTime.parse(groupDayPlan['date']);
  final String planId = groupDayPlan['id'];
      
            // Add the planId to the groupDayPlans
            _groupDayPlans[planDate] = planId;
          }
        });
      } else {
        // Handle error - You might want to show an error message to the user
        print('Failed to fetch events. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle network errors
      print('Error fetching events: $error');
    }
  }

  void _addEvent(
    DateTime selectedDate,
    TimeOfDay startTime,
    TimeOfDay endTime,
    String eventName,
    String eventPrice,
    bool isGroupEvent,
  ) {
    final DateTime startDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      startTime.hour,
      startTime.minute,
    );
    final DateTime endDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      endTime.hour,
      endTime.minute,
    );
    bool hasGroupEventOnSelectedDay = _events.any((event) =>
        event.startTime.year == selectedDate.year &&
        event.startTime.month == selectedDate.month &&
        event.startTime.day == selectedDate.day &&
        event.color == Color(0xFF004aad));

    if (hasGroupEventOnSelectedDay && isGroupEvent) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.ERROR,
        animType: AnimType.SCALE,
        title: 'Error',
        desc: 'You can only create one group event per day.',
        btnOkOnPress: () {},
        btnOkColor: Color.fromRGBO(39, 26, 99, 1),
      ).show();

      return;
    }

    // Use firstWhere with a default value to handle the case when no element is found
    Appointment? conflictingEvent;
    try {
      conflictingEvent = _events.firstWhere(
        (event) =>
            (event.startTime.isBefore(endDate) &&
                event.endTime.isAfter(startDate)) ||
            (event.startTime.isAfter(startDate) &&
                event.startTime.isBefore(endDate)) ||
            (event.endTime.isAfter(startDate) &&
                event.endTime.isBefore(endDate)),
      );
    } catch (e) {
      conflictingEvent = null;
    }

    if (conflictingEvent != null) {
      // Replace the conflicting event
      setState(() {
        conflictingEvent?.subject = eventName;
        conflictingEvent?.startTime = startDate;
        conflictingEvent?.endTime = endDate;
        conflictingEvent?.resourceIds = [eventPrice];
        conflictingEvent?.color =
            isGroupEvent ? Color(0xFF004aad) : Color(0xFFcb6ce6);
      });

      print('Event replaced:');
      print('Event Name: ${conflictingEvent.subject}');
      print('Event Price: ${conflictingEvent.resourceIds?.first}');
      print('Event Start Time: ${conflictingEvent.startTime}');
      print('Event End Time: ${conflictingEvent.endTime}');
      print('-----');
    } else {
      // Add the event if there is no conflict
      setState(() {
        _events.add(Appointment(
          startTime: startDate,
          endTime: endDate,
          subject: eventName,
          color: isGroupEvent ? Color(0xFF004aad) : Color(0xFFcb6ce6),
          resourceIds: [eventPrice],
        ));
      });

      print('Events for ${selectedDate.toLocal().toString().split(' ')[0]}:');
      for (Appointment event in _events) {
        if (event.startTime.year == selectedDate.year &&
            event.startTime.month == selectedDate.month &&
            event.startTime.day == selectedDate.day) {
          print('Event Name: ${event.subject}');
          print('Event Price: ${event.resourceIds?.first}');
          print('Event Start Time: ${event.startTime}');
          print('Event End Time: ${event.endTime}');
          print('-----');
        }
      }
    }
  }
}
