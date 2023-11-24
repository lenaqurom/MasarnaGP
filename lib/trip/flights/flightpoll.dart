import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class FlightVotingPage extends StatefulWidget {
  @override
  _FlightVotingPageState createState() => _FlightVotingPageState();
}

class _FlightVotingPageState extends State<FlightVotingPage> {
  // Store the options and their corresponding votes
  Map<String, Set<String>> votes = {};

  // Controller for the text field
  TextEditingController _textController = TextEditingController();

  // Function to add an option
  void addOption(String option) {
    if (votes.length < 5) {
      setState(() {
        votes[option] = {};
      });
    } else {
      // Optionally show an awesome dialog that the maximum number of options is reached
      _showAwesomeDialog(
        'Maximum Options Reached',
        'You cannot add more than 5 options.',
        DialogType.WARNING,
      );
    }
  }

  // Function to vote for an option
  void voteForOption(String option) {
    if (!votes[option]!.contains("user")) {
      setState(() {
        votes[option]!.add("user");
      });
    } else {
      // Optionally show an awesome dialog that the user has already voted for this option
      _showAwesomeDialog(
        'Already Voted',
        'You have already voted for this option.',
        DialogType.INFO,
      );
    }
  }

  // Function to show an awesome dialog
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

  // Function to get a colored line based on the number of votes
  Widget getVoteLine(int votesCount) {
    double percentage = votesCount / (votes.values.map((set) => set.length).reduce((a, b) => a + b) ?? 1);
    return Container(
      height: 8,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 39, 26, 99), Color.fromARGB(213, 226, 224, 243)],
          stops: [percentage, percentage],
        ),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  // Function to show a dialog to edit an option
void _showEditOptionDialog(String option) {
  _textController.text = option; // Set the initial value to the current option
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
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Edit the option
            editOption(option, _textController.text);
            _textController.clear();
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

  // Function to show a dialog to delete an option
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
        // Delete the option
        deleteOption(option);
      },
      btnOkColor: Colors.red,
      btnCancelColor: Colors.green,
      btnOkText: 'Delete',
    )..show();
  }

  // Function to edit an option
  void editOption(String oldOption, String newOption) {
    setState(() {
      votes[newOption] = votes.remove(oldOption)!;
    });
  }

  // Function to delete an option
  void deleteOption(String option) {
    setState(() {
      votes.remove(option);
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
          'Flight Voting',
          style: TextStyle(
            color: Color.fromARGB(255, 39, 26, 99),
            fontFamily: 'Dosis',
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
              // Display options
              Text(
                'Voting Options:',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'PlayfairDisplay',
                  color: Color.fromARGB(255, 39, 26, 99),
                ),
              ),
              SizedBox(height: 16),
Column(
  children: votes.keys.map((option) {
    int votesCount = votes[option]!.length;
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          option,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Votes: $votesCount',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 8),
            getVoteLine(votesCount),
          ],
        ),
        onTap: () => voteForOption(option),
        // Separate voting information and edit/delete icons
        contentPadding: EdgeInsets.all(16),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, size: 20,), // Adjust the icon size as needed
              onPressed: () {
                _showEditOptionDialog(option);
              },
            ),
            SizedBox(width: 8), // Adjust the spacing between icons
            IconButton(
              icon: Icon(Icons.delete, size: 20,), // Adjust the icon size as needed
              onPressed: () {
                _showDeleteOptionDialog(option);
              },
            ),
          ],
        ),
      ),
    );
  }).toList(),
),
              SizedBox(height: 16),
              // Add Option button
              ElevatedButton(
                onPressed: () {
                  // Check if the maximum number of options is reached before allowing to add a new option
                  if (votes.length < 5) {
                    // Show a dialog to enter a new option
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.NO_HEADER,
                      animType: AnimType.BOTTOMSLIDE,
                      title: 'Add Option',
                      body: Column(
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
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // Add the option
                              addOption(_textController.text);
                              _textController.clear();
                              Navigator.of(context).pop();
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
                      ),
                    )..show();
                  } else {
                    // Optionally show an awesome dialog that the maximum number of options is reached
                    _showAwesomeDialog(
                      'Maximum Options Reached',
                      'You cannot add more than 5 options.',
                      DialogType.WARNING,
                    );
                  }
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
                      style: TextStyle(fontSize: 18, fontFamily: 'Dosis', fontWeight: FontWeight.bold),
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
