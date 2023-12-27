
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:intl/intl.dart';
import 'package:masarna/globalstate.dart';
import 'package:masarna/trip/calender/datetime.dart';
import 'package:masarna/trip/drawer/calculatebudget.dart';
import 'package:masarna/trip/explore.dart';
import 'package:masarna/trip/homesection.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class DayViewPage extends StatefulWidget {
  final DateTime selectedDate;
  final List<Appointment> events;

  DayViewPage({Key? key, required this.selectedDate, required this.events})
      : super(key: key);
  // Add a GlobalKey for accessing the _DayViewPageState class
  static late GlobalKey<_DayViewPageState> dayViewStateKey =
      GlobalKey<_DayViewPageState>();

  @override
  _DayViewPageState createState() => _DayViewPageState();

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final formattedTime = DateFormat.jm().format(dateTime);
    return formattedTime;
  }
}

class _DayViewPageState extends State<DayViewPage> {
  TextEditingController eventNameController = TextEditingController();
  TextEditingController eventPriceController = TextEditingController();
  final GlobalKey _calendarKey = GlobalKey();
  int selectedMonth = 0;
  int selectedYear = 0;
  String eventName = '';
  String eventPrice = '0';
  @override
  void initState() {
    super.initState();
    // Assign the key to the state
    DayViewPage.dayViewStateKey = GlobalKey<_DayViewPageState>();
  }

  @override
  void didUpdateWidget(covariant DayViewPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedDate != widget.selectedDate) {
      // Access the SfCalendar's controller and update the display date
      (_calendarKey.currentWidget as SfCalendar).controller?.displayDate =
          widget.selectedDate;

      // Extract month and year from the selectedDate
      setState(() {
        selectedMonth = widget.selectedDate.month;
        selectedYear = widget.selectedDate.year;
      });
      _fetchCalendarEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Schedule',
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
                Icons.explore,
                color: Color.fromARGB(255, 39, 26, 99),
              ),
              onPressed: () {
                   Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExplorePage(selectedDate: widget.selectedDate),
      ),
    );
  
              }),
        ],
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
        viewHeaderStyle: ViewHeaderStyle(
            dayTextStyle: TextStyle(
                color: Color.fromARGB(255, 39, 26, 99),
                fontWeight: FontWeight.bold,
                fontSize: 15),
            dateTextStyle: TextStyle(
                color: Color.fromARGB(255, 39, 26, 99),
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        key: _calendarKey,
        showCurrentTimeIndicator: true,
        backgroundColor: Colors.white,
        view: CalendarView.day,
        todayHighlightColor: Color.fromARGB(255, 39, 26, 99),
        selectionDecoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: Color.fromARGB(255, 39, 26, 99), width: 2),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          shape: BoxShape.rectangle,
        ),
        initialDisplayDate: widget.selectedDate,
        dataSource: AppointmentDataSource(widget.events),
        scheduleViewSettings: ScheduleViewSettings(
          dayHeaderSettings: DayHeaderSettings(
            dayFormat: 'EEE',
          ),
        ),
        onTap: (CalendarTapDetails details) {
          if (details.targetElement == CalendarElement.appointment) {
            _showEditDeleteDialog(context, details.appointments!.first);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 39, 26, 99),
        onPressed: () {
          _showEventForm(context, widget.selectedDate);
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _fetchCalendarEvents() async {
    try {
      final String planId =
          Provider.of<GlobalState>(context, listen: false).planid;
      final String userId = Provider.of<GlobalState>(context, listen: false).id;
      final String gdpId =
          Provider.of<GlobalState>(context, listen: false).gdpid;
      String apiUrl =
          'http://192.168.1.16:3000/api/$planId/$userId/calendarevents/${formatDateForAPI(widget.selectedDate)}';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> eventsData =
            List<Map<String, dynamic>>.from(
                json.decode(response.body)['events']);

        final List<Appointment> fetchedEvents = eventsData.map((eventData) {
          return Appointment(
            notes: eventData['user'],
            id: eventData['_id'],
            startTime: DateTime.parse(eventData['starttime']),
            endTime: DateTime.parse(eventData['endtime']),
            subject: eventData['name'],
            resourceIds: [eventData['price'].toString()],
            color: eventData['type'] == 'group'
                ? Color(0xFF004aad)
                : Color(0xFFcb6ce6),
          );
        }).toList();

        setState(() {
          widget.events.clear();
          widget.events.addAll(fetchedEvents);
        });
      } else {
        print('Failed to fetch calendar events: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching calendar events: $error');
    }
  }

  String formatDateForAPI(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
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

    final String planId =
        Provider.of<GlobalState>(context, listen: false).planid;
    final String userId = Provider.of<GlobalState>(context, listen: false).id;
    String apiUrl = 'http://192.168.1.16:3000/api/$planId/personalplan/$userId';

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
        _fetchCalendarEvents();
      } else {
        print('Failed to add personal event: ${response.statusCode}');
      }
    } catch (error) {
      print('Error adding personal event: $error');
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final formattedTime = DateFormat.Hm().format(dateTime);
    return formattedTime;
  }

  Future<void> _updateEventOnServer(Appointment event) async {
    try {
      final String planId =
          Provider.of<GlobalState>(context, listen: false).planid;
      print('put request');
      final response = await http.put(
        Uri.parse(
            'http://192.168.1.16:3000/api/$planId/${event.notes}/calendarevents/${event.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'name': event.subject,
          'starttime': event.startTime.toUtc().toIso8601String(),
          'endtime': event.endTime.toUtc().toIso8601String(),
          'price': event.resourceIds?.first?.toString() ?? '0',
        }),
      );

      if (response.statusCode == 200) {
        print('Event updated successfully');
        // Handle success if needed
      } else {
        print('Failed to update event. Status code: ${response.statusCode}');
        // Handle error if needed
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error updating event: $e');

      // Handle network or other errors
    }
  }

  Future<void> _deleteEventOnServer(Appointment event) async {
    try {
      final String planId =
          Provider.of<GlobalState>(context, listen: false).planid;
      final String userId = Provider.of<GlobalState>(context, listen: false).id;
      final response = await http.delete(
        Uri.parse(
            'http://192.168.1.16:3000/api/$planId/$userId/calendarevents/${event.id.toString()}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        print('Event deleted successfully');
        // Handle success if needed
        setState(() {
          widget.events.remove(event);
          _fetchCalendarEvents();
        });
      } else {
        print('Failed to delete event. Status code: ${response.statusCode}');
        // Handle error if needed
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error deleting event: $e');
      // Handle network or other errors
    }
  }

  Future<void> _showEditDeleteDialog(
      BuildContext context, Appointment existingEvent) async {
    print("Before deleting in dialog - User ID: ${existingEvent.notes}");
    print("Before deleting in dialog - Event ID: ${existingEvent.id}");

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
                'Edit or Delete Event',
                style: TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 39, 26, 99),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: 200,
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ("in edit");
                    print(existingEvent.id.toString());
                    print(existingEvent.notes.toString());
                    _editEvent(existingEvent);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 39, 26, 99),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: Icon(
                    Icons.edit,
                    size: 20,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Edit',
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
                width: 200,
                height: 40, // Set a fixed height for the buttons
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteEvent(existingEvent);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 39, 26, 99),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: Icon(Icons.delete, size: 20, color: Colors.white),
                  label: Text(
                    'Delete',
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

  void _editEvent(Appointment existingEvent) {
    TimeOfDay selectedStartTime =
        TimeOfDay.fromDateTime(existingEvent.startTime);
    TimeOfDay selectedEndTime = TimeOfDay.fromDateTime(existingEvent.endTime);

    String eventName = existingEvent.subject ?? '';
    String eventPrice = existingEvent.resourceIds?.first?.toString() ?? '0';

    _showEditEventForm(
      context,
      widget.selectedDate,
      existingEvent: existingEvent,
      eventName: eventName,
      eventPrice: eventPrice,
      selectedStartTime: selectedStartTime,
      selectedEndTime: selectedEndTime,
      eventId: existingEvent.id.toString(),
      userId: existingEvent.notes.toString(),
    );
  }

  void _deleteEvent(Appointment existingEvent) {
    String eventId = existingEvent.id.toString();
    String userId = existingEvent.notes.toString();
    _deleteEventOnServer(existingEvent);
  }

  Future<void> _showEventForm(
      BuildContext context, DateTime selectedDate) async {
    TimeOfDay selectedStartTime = TimeOfDay.now();
    TimeOfDay selectedEndTime = selectedStartTime.replacing(
      hour: (selectedStartTime.hour + 1) % TimeOfDay.hoursPerDay,
    );

    eventName = '';
    eventPrice = '0';

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
            SizedBox(height: 16),
            _buildBorderedTextField('Event Name *', Icons.event, (value) {
              eventName = value;
            }),
            SizedBox(height: 16),
            _buildBorderedTextField('Event Price', Icons.attach_money, (value) {
              eventPrice = value;
            }, keyboardType: TextInputType.numberWithOptions(decimal: true)),
            SizedBox(height: 16),
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
          );
        } else {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.ERROR,
            animType: AnimType.SCALE,
            title: 'Error',
            desc: 'Event name is required',
            btnOkOnPress: () {
              _showEventForm(context, selectedDate);
            },
            btnOkColor: Color.fromRGBO(39, 26, 99, 1),
          ).show();
        }
      },
    ).show();
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
          style: TextStyle(fontSize: 16),
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

  Future<void> _showEditEventForm(
    BuildContext context,
    DateTime selectedDate, {
    Appointment? existingEvent,
    required String eventName,
    required String eventPrice,
    required TimeOfDay selectedStartTime,
    required TimeOfDay selectedEndTime,
    required String eventId,
    required String userId,
  }) async {
    TextEditingController eventNameController =
        TextEditingController(text: eventName);
    TextEditingController eventPriceController =
        TextEditingController(text: eventPrice);

    TimeOfDay updatedStartTime = selectedStartTime;
    TimeOfDay updatedEndTime = selectedEndTime;

    await AwesomeDialog(
      context: context,
      dialogType: DialogType.NO_HEADER,
      animType: AnimType.SCALE,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Edit Event',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
                color: Color.fromARGB(255, 39, 26, 99),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 43,
              child: TextField(
                controller: eventNameController,
                onChanged: (value) {
                  eventName = value;
                },
                style: TextStyle(
                    fontSize: 16, color: Color.fromARGB(255, 39, 26, 99)),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(0),
                  hintText: 'Event Name *',
                  hintStyle: TextStyle(fontSize: 16),
                  prefixIcon:
                      Icon(Icons.event, color: Color.fromARGB(255, 39, 26, 99)),
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
            SizedBox(height: 15),
            Container(
              height: 43,
              child: TextField(
                keyboardType: TextInputType.number,
                controller: eventPriceController,
                onChanged: (value) {
                  eventPrice = value;
                },
                style: TextStyle(
                    fontSize: 16, color: Color.fromARGB(255, 39, 26, 99)),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(0),
                  hintText: 'Event Price',
                  hintStyle: TextStyle(fontSize: 16),
                  prefixIcon: Icon(Icons.attach_money,
                      color: Color.fromARGB(255, 39, 26, 99)),
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
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Start Time', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      Container(
                        height: 43,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Color.fromARGB(255, 39, 26, 99)),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time,
                                color: Color.fromARGB(255, 39, 26, 99)),
                            SizedBox(width: 10),
                            Expanded(
                              child: Center(
                                child: TimeChooser(
                                  initialTime: selectedStartTime,
                                  onTimeChanged: (TimeOfDay time) {
                                    setState(() {
                                      updatedStartTime = time;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('End Time', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      Container(
                        height: 43,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Color.fromARGB(255, 39, 26, 99)),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time,
                                color: Color.fromARGB(255, 39, 26, 99)),
                            SizedBox(width: 10),
                            Expanded(
                              child: Center(
                                child: TimeChooser(
                                  initialTime: selectedEndTime,
                                  onTimeChanged: (TimeOfDay time) {
                                    setState(() {
                                      updatedEndTime = time;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
      btnOkColor: Color.fromARGB(255, 39, 26, 99),
      btnOkText: 'Save',
      btnOkOnPress: () {
        if (eventName.isNotEmpty) {
          _updateEvent(
            existingEvent!,
            selectedDate,
            updatedStartTime,
            updatedEndTime,
            eventName,
            eventPrice,
            eventId,
            userId,
          );
        }
      },
    ).show();
  }

  void _updateEvent(
    Appointment existingEvent,
    DateTime selectedDate,
    TimeOfDay updatedStartTime,
    TimeOfDay updatedEndTime,
    String eventName,
    String eventPrice,
    String eventId,
    String userId,
  ) async {
    final DateTime startDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      updatedStartTime.hour,
      updatedStartTime.minute,
    );
    final DateTime endDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      updatedEndTime.hour,
      updatedEndTime.minute,
    );

    // Check for conflicts
    /* List<Appointment> conflictingEvents = widget.events
        .where(
          (event) =>
              event != existingEvent &&
              ((event.startTime.isBefore(endDate) &&
                      event.endTime.isAfter(startDate)) ||
                  (event.startTime.isAfter(startDate) &&
                      event.startTime.isBefore(endDate)) ||
                  (event.endTime.isAfter(startDate) &&
                      event.endTime.isBefore(endDate))),
        )
        .toList();

    if (conflictingEvents.isNotEmpty) {
      // Remove conflicting events
      setState(() {
        widget.events.removeWhere(
          (event) => conflictingEvents.contains(event),
        );
      });
    }*/

    // Update the event
    setState(() {
      existingEvent.subject = eventName;
      existingEvent.startTime = startDate;
      existingEvent.endTime = endDate;
      existingEvent.resourceIds = [eventPrice];
    });

    await _updateEventOnServer(existingEvent);
    _fetchCalendarEvents();
  }
}
