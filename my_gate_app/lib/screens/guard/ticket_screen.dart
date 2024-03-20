import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/screens/guard/utils/UI_statics.dart';
import 'package:my_gate_app/database/database_objects.dart';
import 'package:my_gate_app/database/database_interface.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen(
      {super.key,
      required this.location,
      required this.isApproved,
      required this.enterExit,
      required this.imagePath});
  final String location;
  final String isApproved;
  final String enterExit;
  final String imagePath;

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

enum User { student, visitor }

class _TicketScreenState extends State<TicketScreen> {
  String searchQuery = '';

  List<ResultObj> tickets = [];
  List<ResultObj> ticketsFiltered = [];
  List<ResultObj4> tickets_visitors = [];
  List<ResultObj4> tickets_visitorsFiltered = [];
  List<String> search_entry_numbers = [];
  String chosen_entry_number = "None";
  String chosen_start_date = "None";
  String chosen_end_date = "None";
  List<bool> isSelected = [true, true];
  bool enableDateFilter = true;
  bool isFieldEmpty = true;
  User _person = User.student;

  int selectedIndex = -1;

  void _togglePerson(User input) {
    if (input != _person) {
      setState(() {
        _person = input;
      });
    }
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

  Widget header(String input) {
    if (input == 'enter') {
      return Text(
        "Enter Tickets",
        style: GoogleFonts.mPlusRounded1c(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      );
    } else {
      return Text(
        "Exit Tickets",
        style: GoogleFonts.mPlusRounded1c(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      );
    }
  }
  
  void filterTickets(String query) {
    if (enableDateFilter) {
      if (query.isEmpty) {
        ticketsFiltered = tickets
            .where((ticket) => DateTime.parse(ticket.date_time).isBefore(
                DateTime.parse(chosen_end_date).add(Duration(days: 1))))
            .toList();
      } else {
        ticketsFiltered = tickets
            .where((ticket) =>
                ticket.student_name
                    .toLowerCase()
                    .contains(query.toLowerCase()) &&
                DateTime.parse(ticket.date_time)
                    .isAfter(DateTime.parse(chosen_start_date)) &&
                DateTime.parse(ticket.date_time).isBefore(
                    DateTime.parse(chosen_end_date).add(Duration(days: 1))))
            .toList();
        print(chosen_end_date);
      }
    } else {
      if (query.isEmpty) {
        ticketsFiltered = tickets;
      } else {
        ticketsFiltered = tickets
            .where((ticket) =>
                ticket.student_name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    }
  }

  void resetFilter(String query){
    chosen_start_date= DateTime.now().subtract(Duration(days:1)).toString();
    chosen_end_date= DateTime.now().toString();
    filterTickets(query);
  }
  void onSearchQueryChanged(String query) {
    setState(() {
      searchQuery = query;
      filterTickets(searchQuery);
      ticketsFiltered=ticketsFiltered;
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(Duration(days: 7)),
    );
    DateTimeRange? selectedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDateRange: initialDateRange,
    );
    if (selectedDateRange != null) {
      setState(() {
        chosen_start_date = selectedDateRange.start.toString();
        chosen_end_date = selectedDateRange.end.toString();
        filterTickets(searchQuery);
      });
      print("### ${ticketsFiltered}");
    }
  }

  @override
  void initState() {
    super.initState();

    init();
  }

  Future<List<ResultObj>> get_tickets_for_guard() async {
    // De
    //
    // upon the location and ticket status, fetch the tickets
    // For example fetch all tickets of Main Gate where ticket status is accepted
    return await databaseInterface.get_tickets_for_guard(
        widget.location, widget.isApproved, widget.enterExit);
  }

  Future<List<ResultObj4>> get_approved_tickets_for_visitors() async {
    print("%%33%%");
    return await databaseInterface.return_entry_visitor_approved_ticket(
        widget.location, widget.isApproved, widget.enterExit);
  }

  Future init() async {
    // tickets = await get_tickets_for_guard();
    late List<ResultObj> tickets_local;
    late List<ResultObj4> tickets_local_2;

    tickets_local = await get_tickets_for_guard();
    print("tickets_local :${tickets_local}");

    tickets_local_2 = await get_approved_tickets_for_visitors();
    print("tickets_local_2 :${tickets_local_2}");

    setState(() {
      tickets = tickets_local;

      tickets_visitors = tickets_local_2;
    });
    print("tickets_visitors set\n${tickets_visitors}");
    // filterTickets(searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Column(children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          header(widget.enterExit),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // SizedBox(
              //   width: MediaQuery.of(context).size.width * 0.07,
              // ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.35,
                height: MediaQuery.of(context).size.height * 0.03,
                child: ElevatedButton(
                  onPressed: () {
                    _togglePerson(User.student);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_person == User.student)
                        ? hexToColor(guardColors[1])
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10.0), // Adjust the radius as needed
                    ),
                  ),
                  child: Text(
                    "Student",
                    style: (_person == User.student)
                        ? GoogleFonts.mPlusRounded1c(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.black)
                        : GoogleFonts.mPlusRounded1c(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                  ),
                ),
              ),
              // SizedBox(
              //   width: MediaQuery.of(context).size.width * 0.07,
              // ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.35,
                height: MediaQuery.of(context).size.height * 0.03,
                child: ElevatedButton(
                  onPressed: () {
                    _togglePerson(User.visitor);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_person == User.visitor)
                        ? hexToColor(guardColors[1])
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10.0), // Adjust the radius as needed
                    ),
                  ),
                  child: Text(
                    "Visitor",
                    style: (_person == User.visitor)
                        ? GoogleFonts.mPlusRounded1c(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.black)
                        : GoogleFonts.mPlusRounded1c(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          // Text("${this._person.name}"),
          SizedBox(
            height: 40,
          ),
          Row(children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.03,
            ),
            Container(
              // margin: EdgeInsets.all(16.0),
              width: MediaQuery.of(context).size.width * 0.73,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.grey[350],
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: TextField(
                style: GoogleFonts.lato(
                  color: Colors.black,
                  fontSize: 20,
                ),
                onChanged: (text) {
                  isFieldEmpty = text.isEmpty;

                  onSearchQueryChanged(text);
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(5.0, 0, 0, 14.0),
                  hintText: 'Search by Name',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.black),
                  suffixIcon: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.clear, color: Colors.black),
                    onPressed: () {
                      // Clear search field
                    },
                  ),
                  hintStyle: GoogleFonts.lato(
                    color: Colors.black87,
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.02,
            ),
            
           
            Container(
              height: 30,
              width: MediaQuery.of(context).size.width * 0.08,
              decoration: BoxDecoration(
                color: Colors.grey[350],
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.filter_alt,
                    color: Colors.black87), // Filter icon
                onPressed: () {
                  enableDateFilter=true;
                  _selectDateRange(context);
                },
              ),
            ),
             SizedBox(
              width: MediaQuery.of(context).size.width * 0.02,
            ),
            Container(
              height: 30,
              width: MediaQuery.of(context).size.width * 0.08,
              decoration: BoxDecoration(
                color: Colors.grey[350],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.filter_alt_off,
                    color: Colors.black87), // Filter icon
                onPressed: () {
                  setState(() {
                    enableDateFilter = !enableDateFilter;
                    resetFilter(searchQuery);
                    // filterTickets(searchQuery);  
                  });
                },
              ),
            ),
          ]),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          (_person == User.student)
              ? studentList(ticketsFiltered)
              : visitorList(tickets_visitors),
        ]));
  }

  Widget studentList(List<ResultObj> mytickets) {
    return 
    // mytickets.isEmpty
    //     ? Center(child: CircularProgressIndicator())
    //     :
        //  Expanded(
        //     child: ListView.builder(
        //       itemCount: mytickets.length,
        //       itemBuilder: (BuildContext context, int index) {
        //         final bool isExpanded = index == selectedIndex;
        //         return Column(
        //           children: <Widget>[
        //             ListTile(
        //               title: Text(mytickets[index].student_name,
        //                   style: GoogleFonts.lato(
        //                     fontWeight: FontWeight.w600,
        //                     color: Colors.black,
        //                   )),
        //               subtitle: Text(mytickets[index].date_time.toString()),
        //               onTap: () => toggleExpansion(index),
        //             ),
        //             if (isExpanded)
        //               Padding(
        //                 padding: EdgeInsets.symmetric(horizontal: 16.0),
        //                 child: Column(
        //                     mainAxisAlignment: MainAxisAlignment.start,
        //                     children: [
        //                       Text("Email : ${mytickets[index].email}"),
        //                       Text(
        //                           "Destination Address : ${mytickets[index].destination_address}"),
        //                       Text(
        //                           "Vehicle Number : ${mytickets[index].vehicle_number}"),
        //                     ]),
        //               ),
        //             Divider(), // Add divider between list items
        //           ],
        //         );
        //       },
        //     ),
        //   );
        Expanded(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              // height:MediaQuery.of(context).size.height*0.67,
              child: ListView.builder(
                itemCount: mytickets.length,
                itemBuilder: (BuildContext context, int index) {
                  final bool isExpanded = index == selectedIndex;
                  return 
                  Container(
                  child:Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: hexToColor(guardColors[1]),
                            borderRadius: BorderRadius.circular(
                                15), // Adjust the radius as needed
                          ),
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                title: Text(
                                  mytickets[index].student_name,
                                  style: GoogleFonts.lato(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                // subtitle: Text(mytickets[index]
                                    // .date_time_guard
                                    // .toString()),
                                onTap: () => toggleExpansion(index),
                              ),

                              if (isExpanded)
                                Container(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "email :${mytickets[index].email}",
                                            style: GoogleFonts.lato(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                              fontSize: 15,
                                            )),
                                        Text(
                                            "Mobile Number :${mytickets[index].vehicle_number}",
                                            style: GoogleFonts.lato(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                              fontSize: 15,
                                            )),
                                        Text(
                                            "Additonal Visitors :${mytickets[index]}",
                                            style: GoogleFonts.lato(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                              fontSize: 15,
                                            )),
                                        
                                      ]),
                                ),

                              // Add divider between list items
                            ],
                          ),
                        ),

                        SizedBox(
                          height: 5,
                        ),
                      ]
                      ),
                      );
                },
              ),
            ),
          );
  }

  Widget visitorList(mytickets) {
    print("widget visitor list");
    print(tickets_visitorsFiltered);
    return 
    // mytickets.isEmpty
    //     ? Center(child: CircularProgressIndicator())
    //     : 
        Expanded(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              // height:MediaQuery.of(context).size.height*0.67,
              child: ListView.builder(
                itemCount: mytickets.length,
                itemBuilder: (BuildContext context, int index) {
                  final bool isExpanded = index == selectedIndex;
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: hexToColor(guardColors[1]),
                            borderRadius: BorderRadius.circular(
                                15), // Adjust the radius as needed
                          ),
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                title: Text(
                                  mytickets[index].visitor_name,
                                  style: GoogleFonts.lato(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Text(mytickets[index]
                                    .date_time_guard
                                    .toString()),
                                onTap: () => toggleExpansion(index),
                              ),
                              if (isExpanded)
                                Container(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "Duration :${mytickets[index].duration_of_stay}",
                                            style: GoogleFonts.lato(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                              fontSize: 15,
                                            )),
                                        Text(
                                            "Mobile Number :${mytickets[index].mobile_no}",
                                            style: GoogleFonts.lato(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                              fontSize: 15,
                                            )),
                                        Text(
                                            "Additonal Visitors :${mytickets[index].num_additional}",
                                            style: GoogleFonts.lato(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                              fontSize: 15,
                                            )),
                                        Text(
                                            "Car Number: ${mytickets[index].car_number}",
                                            style: GoogleFonts.lato(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                              fontSize: 15,
                                            )),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.01)
                                      ]),
                                ),

                              // Add divider between list items
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                      ]);
                },
              ),
            ),
          );
  }
}
