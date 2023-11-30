import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:icons_flutter/icons_flutter.dart';

class VotingOption {
  String option;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  Set<String> votedUsers;
  double price = 0;
  String location = '';

  VotingOption(
      this.option, this.startTime, this.endTime, this.price, this.location)
      : votedUsers = {}; 
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

  void addOptionWithTime(String option, TimeOfDay? startTime,
      TimeOfDay? endTime, String price, String location) {
    double parsedPrice = double.tryParse(price) ?? 0.0;

    VotingOption votingOption =
        VotingOption(option, startTime, endTime, parsedPrice, location);
    setState(() {
      votes.add(votingOption);
    });
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
                    _textController.text,
                    _startTime,
                    _endTime,
                    _priceController.text,
                    _locationController.text,
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

  void voteForOption(String option) {
    VotingOption votedOption = votes.firstWhere((v) => v.option == option);

    setState(() {
      if (!votedOption.votedUsers.contains("user")) {
        votedOption.votedUsers.add("user");
      } else {
        _showAwesomeDialog(
          'Already Voted',
          'You have already voted for this option.',
          DialogType.success,
        );
      }
    });
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

  Widget getVoteLine(int votesCount) {
    double percentage = votesCount /
        (votes
                .map((option) => option.votedUsers.length)
                .reduce((a, b) => a + b) ??
            1);
    return Container(
      height: 8,
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
                _locationController.text,
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

  void _showDeleteOptionDialog(String option) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.WARNING,
      animType: AnimType.BOTTOMSLIDE,
      title: 'Delete Option',
      desc: 'Are you sure you want to delete this option?',
      btnCancelOnPress: () {},
      btnCancelText: 'Cancel',
      btnOkOnPress: () {
        deleteOption(option);
      },
      btnOkColor: Color.fromARGB(255, 39, 26, 99),
      btnCancelColor: Colors.grey,
      btnOkText: 'Delete',
    )..show();
  }

  void editOption(String oldOption, String newOption, TimeOfDay? newStartTime,
      TimeOfDay? newEndTime, String newPrice, String newLocation) {
    double? parsedPrice = double.tryParse(newPrice);
    double oldPrice = votes.firstWhere((v) => v.option == oldOption).price;

    setState(() {
      VotingOption editedOption =
          votes.firstWhere((v) => v.option == oldOption);
      editedOption.option = newOption;
      editedOption.startTime = newStartTime ?? editedOption.startTime;
      editedOption.endTime = newEndTime ?? editedOption.endTime;
      editedOption.price = parsedPrice ?? oldPrice;
      editedOption.location = newLocation;
    });
  }

  void deleteOption(String option) {
    setState(() {
      votes.removeWhere((v) => v.option == option);
    });
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
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Stays Voting',
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
                                'Votes: $votesCount',
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              SizedBox(height: 8),
                              getVoteLine(votesCount),
                            ],
                          ),
                          onTap: () => voteForOption(option.option),
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
                                  _showDeleteOptionDialog(option.option);
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
