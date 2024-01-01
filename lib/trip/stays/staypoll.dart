import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:masarna/globalstate.dart';
import 'package:masarna/trip/homesection.dart';
import 'package:provider/provider.dart'; // Import the intl package for date/time formatting

class VotingOption {
  String id;
  String option;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  Set<String> votedUsers;
  double price = 0;
  double longitude = 0;
  double latitude = 0;
  double numvotes = 0;

  VotingOption(
    this.id,
    this.option,
    this.startTime,
    this.endTime,
    this.price,
    this.longitude,
    this.latitude,
    this.numvotes, // Add this line
  ) : votedUsers = {};
}

List<VotingOption> votes = [];

class StayVotingPage extends StatefulWidget {
  @override
  _StayVotingPageState createState() => _StayVotingPageState();
}

class _StayVotingPageState extends State<StayVotingPage> {
  TextEditingController _textController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  int totalVotes = 0;

  @override
  void initState() {
    super.initState();
    fetchOptions();
  }

  @override
  void dispose() {
    _textController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> fetchOptions() async {
    final String planId =
        Provider.of<GlobalState>(context, listen: false).planid;
    final String gdpId = Provider.of<GlobalState>(context, listen: false).gdpid;
    final String apiUrl =
        'http://192.168.1.16:3000/api/oneplan/$planId/groupdayplan/$gdpId/section/stays/poll-options'; // Update with your specific API endpoint

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> optionsData =
            jsonDecode(response.body)['pollOptions'];

        print('Options Data: $optionsData'); // Print optionsData for debugging

        setState(() {
          votes = optionsData.map((optionData) {
            return VotingOption(
              optionData['id'],
              optionData['name'],
              _parseTimeOfDay(optionData['startTime']),
              _parseTimeOfDay(optionData['endTime']),
              optionData['price'] != null
                  ? optionData['price'].toDouble()
                  : 0.0,
              optionData['location'][0].toDouble(),
              optionData['location'][1].toDouble(),
              optionData['votes'] != null
                  ? optionData['votes'].toDouble()
                  : 0.0,
            );
          }).toList();

          totalVotes = votes
              .map((option) => option.numvotes.toInt())
              .reduce((a, b) => a + b);
        });
      } else {
        print('Error response: ${response.statusCode}');
        print('Error body: ${response.body}');
        _showAwesomeDialog(
          'Error',
          'Failed to fetch poll options. Please try again.',
          DialogType.ERROR,
        );
      }
    } catch (error) {
      print('Exception during HTTP request: $error');
      _showAwesomeDialog(
        'Error',
        'An unexpected error occurred. Please try again.',
        DialogType.ERROR,
      );
    }
  }

  TimeOfDay? _parseTimeOfDay(String? timeString) {
    if (timeString == null) return null;

    DateTime dateTime = DateTime.parse(timeString).toLocal();
    return TimeOfDay.fromDateTime(dateTime);
  }

  Future<void> voteForOption(String optionId) async {
    final String planId =
        Provider.of<GlobalState>(context, listen: false).planid;
    final String gdpId = Provider.of<GlobalState>(context, listen: false).gdpid;
    final String apiUrl =
        'http://192.168.1.16:3000/api/oneplan/$planId/groupdayplan/$gdpId/section/stays/poll-option/$optionId/vote';

    try {
      final response = await http.post(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Vote recorded successfully, you may want to update UI or handle success
        print('Vote recorded successfully');

        // Extract updated votes count for the specific option from the response
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final int updatedVotes = responseData['votedOption']['votes'];

        setState(() {
          VotingOption votedOption = votes.firstWhere((v) => v.id == optionId);
          votedOption.numvotes = updatedVotes.toDouble();
          totalVotes = votes
              .map((option) => option.numvotes.toInt())
              .reduce((a, b) => a + b);
        });
      } else {
        // Handle error, maybe show an error dialog or log the error
        print('Error response: ${response.statusCode}');
        print('Error body: ${response.body}');
        // Add your error handling logic here
      }
    } catch (error) {
      // Handle exception, maybe show an error dialog or log the error
      print('Exception during HTTP request: $error');
      // Add your error handling logic here
    }
  }

  Future<void> addOptionWithTime(
      String id,
      String option,
      TimeOfDay? startTime,
      TimeOfDay? endTime,
      String price,
      double longitude,
      double latitude,
      String numvotes) async {
         String date =
              Provider.of<GlobalState>(context, listen: false).selectedFormattedDate;
    double parsedPrice = double.tryParse(price) ?? 0.0;
    double parsedVotes = double.tryParse(numvotes) ?? 0.0;
    VotingOption votingOption = VotingOption(
        id, option, startTime, endTime, parsedPrice, longitude, latitude, parsedVotes);

    // Format TimeOfDay to strings
    String formatTimeOfDay(TimeOfDay timeOfDay) {
      final now = DateTime.now();
      final dateTime = DateTime(
          now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
      return DateFormat.Hm().format(dateTime);
    }

    String formattedStartTime =
        startTime != null ? formatTimeOfDay(startTime) : '';
    String formattedEndTime = endTime != null ? formatTimeOfDay(endTime) : '';
    final String planId =
        Provider.of<GlobalState>(context, listen: false).planid;
    final String gdpId = Provider.of<GlobalState>(context, listen: false).gdpid;
    // API endpoint details
    final String apiUrl =
        'http://192.168.1.16:3000/api/oneplan/$planId/groupdayplan/$gdpId/section/stays/poll-option'; // Your full URL

    // Your backend API expects a JSON body
    final Map<String, dynamic> requestBody = {
      'date':date,
      'name': votingOption.option,
      'starttime': formattedStartTime,
      'endtime': formattedEndTime,
      'location': {'longitude': votingOption.longitude, 'latitude': votingOption.latitude },
      'price': votingOption.price,
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
        // Successfully added poll option, you may want to update UI or handle success
        setState(() {
          votes.add(votingOption);
        });
      } else {
        // Handle error, maybe show an error dialog or log the error
        print('Error response: ${response.statusCode}');
        print('Error body: ${response.body}');

        _showAwesomeDialog(
          'Error',
          'Failed to add poll option. Please try again.',
          DialogType.ERROR,
        );
      }
    } catch (error) {
      print('Exception during HTTP request: $error');
      // Handle exception, maybe show an error dialog or log the error
      _showAwesomeDialog(
        'Error',
        'An unexpected error occurred. Please try again.',
        DialogType.ERROR,
      );
    }
  }

  void _showAddVotingDialog(BuildContext context) {
    TimeOfDay? _startTime;
    TimeOfDay? _endTime;

    AwesomeDialog(
      context: context,
      dialogType: DialogType.NO_HEADER,
      animType: AnimType.BOTTOMSLIDE,
      title: 'Add Option',
      body: StatefulBuilder(builder: (context, setState) {
        return Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Enter Option',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ),
            SizedBox(height: 8),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: _priceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Enter Price (Optional)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
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
                    primary: Color.fromARGB(213, 226, 224, 243),
                    onPrimary: Color.fromARGB(255, 39, 26, 99),
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
                    primary: Color.fromARGB(213, 226, 224, 243),
                    onPrimary: Color.fromARGB(255, 39, 26, 99),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
              ],
            ),
            if (_startTime != null && _endTime != null)
              Text(
                'Selected Time: ${_startTime?.format(context)} - ${_endTime?.format(context)}',
                style: TextStyle(fontFamily: 'Montserrat', fontSize: 16),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_startTime != null && _endTime != null) {
                  addOptionWithTime(
                    '',
                    _textController.text,
                    _startTime,
                    _endTime,
                    _priceController.text,
                    0,
                    0,
                    '',
                  );
                  _textController.clear();
                  _priceController.clear();
                  _locationController.clear();
                  Navigator.of(context).pop();
                } else {
                  _showAwesomeDialog(
                    'Invalid Time',
                    'Please set both start and end times.',
                    DialogType.WARNING,
                  );
                }
              },
              child: Text('Add'),
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 39, 26, 99),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        );
      }),
    )..show();
  }

  void _showAwesomeDialog(String title, String content, DialogType dialogType) {
    AwesomeDialog(
      context: context,
      dialogType: dialogType,
      headerAnimationLoop: false,
      animType: AnimType.BOTTOMSLIDE,
      title: title,
      desc: content,
      btnOkOnPress: () {},
      btnOkColor: Color.fromARGB(255, 39, 26, 99),
      btnOkText: 'OK',
      buttonsTextStyle: TextStyle(color: Colors.white),
    )..show();
  }

  Widget getVoteLine(int numvotes) {
    double percentage = totalVotes > 0 ? numvotes / totalVotes : 0.0;

    return Container(
      height: 8,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 39, 26, 99),
            Color.fromARGB(213, 226, 224, 243),
          ],
          stops: [percentage, percentage],
        ),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  void _showEditOptionDialog(String option) {
    _textController.text = option;
    TimeOfDay? _startTime;
    TimeOfDay? _endTime;

    VotingOption existingOption = votes.firstWhere((v) => v.option == option);

    _priceController.text = existingOption.price.toString();

    AwesomeDialog(
      context: context,
      dialogType: DialogType.NO_HEADER,
      animType: AnimType.BOTTOMSLIDE,
      title: 'Edit Option',
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Edit Option',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
          SizedBox(height: 8),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _priceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Enter Price (Optional)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
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

                  if (pickedTime != null) {
                    setState(() {
                      _startTime = pickedTime;
                    });
                  }
                },
                icon: Icon(FlutterIcons.calendar_clock_mco),
                label: Text('Start Time'),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(213, 226, 224, 243),
                  onPrimary: Color.fromARGB(255, 39, 26, 99),
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

                  if (pickedTime != null) {
                    setState(() {
                      _endTime = pickedTime;
                    });
                  }
                },
                icon: Icon(FlutterIcons.calendar_clock_mco),
                label: Text('End Time'),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(213, 226, 224, 243),
                  onPrimary: Color.fromARGB(255, 39, 26, 99),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
            ],
          ),
          if (_startTime != null && _endTime != null)
            Text(
              'Selected Time: ${_startTime?.format(context)} - ${_endTime?.format(context)}',
              style: TextStyle(fontFamily: 'Montserrat', fontSize: 16),
            ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              editOption(
                option,
                _textController.text,
                _startTime,
                _endTime,
                _priceController.text,
              );
              _textController.clear();
              _priceController.clear();
              _locationController.clear();
              Navigator.of(context).pop();
            },
            child: Text('Save'),
            style: ElevatedButton.styleFrom(
              primary: Color.fromARGB(255, 39, 26, 99),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    )..show();
  }

  void _showDeleteOptionDialog(String optionId) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.WARNING,
      animType: AnimType.BOTTOMSLIDE,
      title: 'Delete Option',
      desc: 'Are you sure you want to delete this option?',
      btnCancelOnPress: () {},
      btnCancelText: 'Cancel',
      btnOkOnPress: () {
        deleteOption(optionId);
      },
      btnOkColor: Color.fromARGB(255, 39, 26, 99),
      btnCancelColor: Colors.grey,
      btnOkText: 'Delete',
    )..show();
  }

  void editOption(String oldOption, String newOption, TimeOfDay? newStartTime,
      TimeOfDay? newEndTime, String newPrice) {
    double? parsedPrice = double.tryParse(newPrice);
    double oldPrice = votes.firstWhere((v) => v.option == oldOption).price;

    setState(() {
      VotingOption editedOption =
          votes.firstWhere((v) => v.option == oldOption);
      editedOption.option = newOption;
      editedOption.startTime = newStartTime ?? editedOption.startTime;
      editedOption.endTime = newEndTime ?? editedOption.endTime;
      editedOption.price = parsedPrice ?? oldPrice;
    });
  }

  Future<void> deleteOption(String optionId) async {
    final String planId =
        Provider.of<GlobalState>(context, listen: false).planid;
    final String gdpId = Provider.of<GlobalState>(context, listen: false).gdpid;
    final String apiUrl =
        'http://192.168.1.16:3000/api/oneplan/$planId/groupdayplan/$gdpId/section/stays/poll-option/$optionId';

    try {
      final response = await http.delete(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Poll option deleted successfully, you may want to update UI or handle success
        print('Poll option deleted successfully');

        setState(() {
          votes.removeWhere((v) => v.id == optionId);
        });
      } else {
        // Handle error, maybe show an error dialog or log the error
        print('Error response: ${response.statusCode}');
        print('Error body: ${response.body}');
        // Add your error handling logic here
      }
    } catch (error) {
      // Handle exception, maybe show an error dialog or log the error
      print('Exception during HTTP request: $error');
      // Add your error handling logic here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromARGB(255, 39, 26, 99),
          ),
          onPressed: () {
Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => SectionsPage()),
                      );          },
        ),
        title: Text(
          'Stay Voting',
          style: TextStyle(
            color: Color.fromARGB(255, 39, 26, 99),
            fontFamily: 'Montserrat',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Voting Options:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                  color: Color.fromARGB(255, 39, 26, 99),
                ),
              ),
              SizedBox(height: 16),
              Column(
                children: votes.map((option) {
                  int votesCount = option.votedUsers.length;
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Stack(
                      children: [
                        ListTile(
                          title: Text(
                            option.option,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                '${option.startTime?.format(context)} - ${option.endTime?.format(context)}',
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                'Votes: ${option.numvotes.toInt()}',
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              SizedBox(height: 8),
                              getVoteLine(option.numvotes.toInt()),
                            ],
                          ),
                          onTap: () {
                            voteForOption(option.id);
                            print(option.id);
                          },
                          contentPadding: EdgeInsets.all(16),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  size: 20,
                                ),
                                onPressed: () {
                                  _showEditOptionDialog(option.option);
                                },
                              ),
                              SizedBox(width: 8),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  size: 20,
                                ),
                                onPressed: () {
                                  _showDeleteOptionDialog(option.id);
                                },
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 0.0,
                          right: 0.0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20 * 1.5,
                              vertical: 20 / 4,
                            ),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 39, 26, 99),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(22),
                                topRight: Radius.circular(22),
                              ),
                            ),
                            child: Text(
                              "\$${option.price}",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _showAddVotingDialog(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      size: 24,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Add Option',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 39, 26, 99),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
