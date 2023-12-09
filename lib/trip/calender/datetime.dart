import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}

class DateChooser extends StatefulWidget {
  final Function(DateTime) onDateChanged;

  const DateChooser({Key? key, required this.onDateChanged}) : super(key: key);

  @override
  _DateChooserState createState() => _DateChooserState();
}

class _DateChooserState extends State<DateChooser> {
  DateTime selectedDate = DateTime.now();
  DateTime currentDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: currentDate,
          lastDate: DateTime(2101),
        );
        if (pickedDate != null && pickedDate != selectedDate) {
          setState(() {
            selectedDate = pickedDate;
            widget.onDateChanged(selectedDate);
          });
        }
      },
      child: Text(
        selectedDate.toLocal().toString().split(' ')[0],
      style: TextStyle(fontSize: 19,fontFamily: 'Montserrat',fontWeight: FontWeight.bold, color: Color.fromARGB(255, 39, 26, 99)),
      ),
    );
  }
}

class TimeChooser extends StatefulWidget {
  final Function(TimeOfDay) onTimeChanged;
  final TimeOfDay? initialTime;

  const TimeChooser({
    Key? key,
    required this.onTimeChanged,
    this.initialTime,
  }) : super(key: key);

  @override
  _TimeChooserState createState() => _TimeChooserState();
}

class _TimeChooserState extends State<TimeChooser> {
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    selectedTime = widget.initialTime ?? TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: selectedTime,
        );
        if (pickedTime != null) {
          setState(() {
            selectedTime = pickedTime;
            widget.onTimeChanged(selectedTime);
          });
        }
      },
      child: Text(
        selectedTime.format(context),
      style: TextStyle(fontSize: 16,fontFamily: 'Montserrat',fontWeight: FontWeight.bold, color: Color.fromARGB(255, 39, 26, 99)),
      ),
    );
  }
}
