import 'package:flutter/material.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:masarna/trip/calender/datetime.dart';
import 'package:masarna/trip/calender/dayview.dart';
import 'package:masarna/trip/sections.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class MyCalendarPage extends StatefulWidget {
  @override
  _MyCalendarPageState createState() => _MyCalendarPageState();
}

class _MyCalendarPageState extends State<MyCalendarPage> {
  List<Appointment> _events = <Appointment>[];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
                      margin:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    ),
                  ],
                ),
              ),
            ),
      body: SfCalendar(
        headerStyle: CalendarHeaderStyle(
          textStyle: TextStyle(
            fontSize: 18, // Set your desired font size
            fontWeight: FontWeight.bold, // Optional: You can customize the font weight
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
              _showGroupEventDialog(context, details.date!);
            } else {
              Navigator.push(
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
        
        child: Icon(Icons.add, color: Colors.white,),
      ),
    );
  }

  void _showGroupEventDialog(BuildContext context, DateTime date) {
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
                    color: Colors.white
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 40, 
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SectionsPage(),
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
                    color: Colors.white
                  ),
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
                icon: Icon(Icons.person, size: 30, color: Colors.white,),
                label: Text(
                  'Personal Event',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color: Colors.white
                  ),
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
                icon: Icon(Icons.group, size: 30, color: Colors.white,),
                label: Text(
                  'Group Event',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color: Colors.white
                  ),
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
          },
              keyboardType: TextInputType.numberWithOptions(decimal: true)),
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
        _addEvent(
          selectedDate,
          selectedStartTime,
          selectedEndTime,
          eventName,
          eventPrice,
          false, // personal events
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
    btnOkOnPress: () {
        _addEvent(
          selectedDate,
          selectedStartTime,
          selectedEndTime,
          eventName,
          eventPrice,
          true, // group events
        );
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
          style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 39, 26, 99)), 
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
      Text(label, style: TextStyle(fontSize: 14),),
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
    btnOkOnPress: () {
    },
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
        conflictingEvent?.color = isGroupEvent ? Color(0xFF004aad) : Color(0xFFcb6ce6);
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

