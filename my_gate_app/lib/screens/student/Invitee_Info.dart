import 'package:my_gate_app/screens/student/result_obj.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/screens/guard/utils/UI_statics.dart'; // Import necessary dependencies

class InviteeInfoPage extends StatefulWidget {
  const InviteeInfoPage({Key? key}) : super(key: key);

  @override
  _InviteeInfoPageState createState() => _InviteeInfoPageState();
}

class _InviteeInfoPageState extends State<InviteeInfoPage> with SingleTickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 8,
        title: Text(
          'Invitee Info',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        bottom: TabBar(
          controller: controller,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              width: 4,
              color: Colors.black,
            ),
          ),
          labelStyle: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w800
          ),
          unselectedLabelStyle: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w800
          ),
          tabs:  [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_circle),
                  SizedBox(width: 10),
                  Text(
                    'Form',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history),
                  SizedBox(width: 10),
                  Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.black,
        child: TabBarView(
          controller: controller,
          children: [
            InviteeForm(),
            InviteeStatus(),
          ],
        ),
      ),
    ),
  );
}

class InviteeForm extends StatefulWidget {
  @override
  _InviteeFormState createState() => _InviteeFormState();
}

class _InviteeFormState extends State<InviteeForm> {
  final _formKey = GlobalKey<FormState>(); // Key for the form

  String _name = '';
  String _relationship = '';
  String _contact = '';
  String _purpose = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      // appBar: AppBar(
      //   title: Text('Invitee Form', style: GoogleFonts.mPlusRounded1c(color: Colors.black)), // Set app bar title color to black
      //   backgroundColor: Colors.white, // Set app bar background color to white
      // ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: GoogleFonts.mPlusRounded1c(color: Colors.black), // Set label text color to black using Google Fonts
                ),
                style: GoogleFonts.mPlusRounded1c(color: Colors.black), // Set input text color to black using Google Fonts
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Relationship',
                  labelStyle: GoogleFonts.mPlusRounded1c(color: Colors.black), // Set label text color to black using Google Fonts
                ),
                style: GoogleFonts.mPlusRounded1c(color: Colors.black), // Set input text color to black using Google Fonts
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the relationship';
                  }
                  return null;
                },
                onSaved: (value) {
                  _relationship = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Contact',
                  labelStyle: GoogleFonts.mPlusRounded1c(color: Colors.black), // Set label text color to black using Google Fonts
                ),
                style: GoogleFonts.mPlusRounded1c(color: Colors.black), // Set input text color to black using Google Fonts
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the contact';
                  }
                  return null;
                },
                onSaved: (value) {
                  _contact = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Purpose to Invite',
                  labelStyle: GoogleFonts.mPlusRounded1c(color: Colors.black), // Set label text color to black using Google Fonts
                ),
                style: GoogleFonts.mPlusRounded1c(color: Colors.black), // Set input text color to black using Google Fonts
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the purpose to invite';
                  }
                  return null;
                },
                onSaved: (value) {
                  _purpose = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Submit your form data here
                    print(
                        'Name: $_name, Relationship: $_relationship, Contact: $_contact, Purpose: $_purpose');
                  }
                },
                child: Text('Submit'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.black), // Set button background color to black
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class InviteeStatus extends StatefulWidget {
  @override
  _InviteeStatusState createState() => _InviteeStatusState();
}

class _InviteeStatusState extends State<InviteeStatus> {
  String searchQuery = '';
  List<ResultObj> tickets = []; // Define necessary variables
  List<ResultObj> ticketsFiltered = [];
  int selectedIndex = -1; // Define selectedIndex variable

  @override
  void initState() {
    super.initState();
    tickets = _generateDummyData(); // Initialize tickets with dummy data
    ticketsFiltered = List.from(tickets);
  }

  void toggleExpansion(int index) {
    setState(() {
      if (selectedIndex == index) {
        selectedIndex = -1; // Collapse if already expanded
      } else {
        selectedIndex = index; // Expand if not expanded
      }
    });
  }

  List<ResultObj> _generateDummyData() {
    // Create a list of dummy ResultObj objects
    return [
      ResultObj(
        name: 'Aryan',
        status: 'Pending',
        mobileNumber: '+1234567890',
      ),
      ResultObj(
        name: 'Akshay',
        status: 'Accepted',
        mobileNumber: '+1987654321',
      ),
      ResultObj(
        name: 'Rohit',
        status: 'Rejected',
        mobileNumber: '+12345678930',
      ),
      ResultObj(
        name: 'Rohan',
        status: 'Pending',
        mobileNumber: '+3234567820',
      ),
      // Add more dummy data as needed
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          // Implement UI for displaying tickets here
          Expanded(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              child: ListView.builder(
                itemCount: ticketsFiltered.length,
                itemBuilder: (BuildContext context, int index) {
                  final bool isExpanded = index == selectedIndex;
                  return Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xff3E3E3E),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            title: Text(
                              ticketsFiltered[index].name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: isExpanded
                                ? Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8),
                                Text(
                                  'Status: ${ticketsFiltered[index].status}',
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Mobile Number: ${ticketsFiltered[index].mobileNumber}',
                                ),
                                // Add more details here as needed
                              ],
                            )
                                : null,
                            onTap: () => toggleExpansion(index),
                            trailing: Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
