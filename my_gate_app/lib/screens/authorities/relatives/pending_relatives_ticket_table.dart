// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_new, deprecated_member_use, non_constant_identifier_names, avoid_print, must_be_immutable
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/database/database_objects.dart';
import 'package:my_gate_app/get_email.dart';
import 'package:my_gate_app/screens/profile2/profile_page.dart';
import 'package:my_gate_app/screens/utils/custom_snack_bar.dart';
import 'package:my_gate_app/screens/utils/scrollable_widget.dart';

class PendingRelativeTicketTable extends StatefulWidget {
  const PendingRelativeTicketTable({super.key});

  @override
  _PendingRelativeTicketTable createState() =>
      _PendingRelativeTicketTable();
}

class _PendingRelativeTicketTable
    extends State<PendingRelativeTicketTable> {
  String ticket_accepted_message = '';
  String ticket_rejected_message = '';

  List<StuRelTicket> tickets = [];

  List<StuRelTicket> ticketsFiltered = [];
  String searchQuery = '';

  List<StuRelTicket> selectedTickets = [];
  List<StuRelTicket> selectedTickets_action = [];

  List<String> search_entry_numbers = [];
  String chosen_entry_number = "None";
  String chosen_start_date = "None";
  String chosen_end_date = "None";
  List<bool> isSelected = [true, true];
  bool enableDateFilter = false;
  bool isFieldEmpty = true;
  int selectedIndex = -1;

  void toggleExpansion(int index) {
    setState(() {
      if (selectedIndex == index) {
        selectedIndex = -1; // Collapse if already expanded
      } else {
        selectedIndex = index; // Expand if not expanded
      }
    });
  }



  // Future<void> accept_action_tickets_authorities() async {
  //   databaseInterface db = new databaseInterface();
  //   int status_code =
  //   await db.accept_selected_tickets_authorities(selectedTickets_action);
  //   if (status_code == 200) {
  //     await init();
  //     final snackBar = get_snack_bar("Ticket accepted", Colors.green);
  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //   } else {
  //     final snackBar = get_snack_bar("Failed to accept the ticket", Colors.red);
  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //   }
  // }

  // Future<void> reject_action_tickets_authorities() async {
  //   databaseInterface db = new databaseInterface();
  //   int status_code =
  //   await db.reject_selected_tickets_authorities(selectedTickets_action);
  //   print("The status code is $status_code");
  //   if (status_code == 200) {
  //     await init();
  //     final snackBar = get_snack_bar("Ticket rejected", Colors.green);
  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //   } else {
  //     final snackBar = get_snack_bar("Failed to reject the ticket", Colors.red);
  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //   }
  // }

  // void filterTickets(String query) {
  //   if (enableDateFilter) {
  //     if (query.isEmpty) {
  //       ticketsFiltered = tickets
  //           .where((ticket) => DateTime.parse(ticket.date_time).isBefore(
  //           DateTime.parse(chosen_end_date).add(Duration(days: 1))))
  //           .toList();
  //     } else {
  //       ticketsFiltered = tickets
  //           .where((ticket) =>
  //       ticket.student_name
  //           .toLowerCase()
  //           .contains(query.toLowerCase()) &&
  //           DateTime.parse(ticket.date_time)
  //               .isAfter(DateTime.parse(chosen_start_date)) &&
  //           DateTime.parse(ticket.date_time).isBefore(
  //               DateTime.parse(chosen_end_date).add(Duration(days: 1))))
  //           .toList();
  //       print(chosen_end_date);
  //     }
  //   } else {
  //     if (query.isEmpty) {
  //       ticketsFiltered = tickets;
  //     } else {
  //       ticketsFiltered = tickets
  //           .where((ticket) =>
  //           ticket.student_name.toLowerCase().contains(query.toLowerCase()))
  //           .toList();
  //     }
  //   }
  // }
  //
  // void onSearchQueryChanged(String query) {
  //   setState(() {
  //     searchQuery = query;
  //     filterTickets(searchQuery);
  //   });
  // }
  //
  // Future<void> _selectDateRange(BuildContext context) async {
  //   final initialDateRange = DateTimeRange(
  //     start: DateTime.now(),
  //     end: DateTime.now().add(Duration(days: 7)),
  //   );
  //   DateTimeRange? selectedDateRange = await showDateRangePicker(
  //     context: context,
  //     firstDate: DateTime.now().subtract(Duration(days: 365)),
  //     lastDate: DateTime.now().add(Duration(days: 365)),
  //     initialDateRange: initialDateRange,
  //   );
  //   if (selectedDateRange != null) {
  //     setState(() {
  //       chosen_start_date = selectedDateRange.start.toString();
  //       chosen_end_date = selectedDateRange.end.toString();
  //       filterTickets(searchQuery);
  //     });
  //   }
  // }

  @override
  void initState() {
    super.initState();
    // init();

  }

  // Future<List<ResultObj2>> get_pending_tickets_for_authority() async {
  //   String authority_email = LoggedInDetails.getEmail();
  //   return await databaseInterface
  //       .get_pending_tickets_for_authorities(authority_email);
  // }

  // Future init() async {
  //   final tickets_local = await get_pending_tickets_for_authority();
  //   setState(() {
  //     tickets = tickets_local;
  //     selectedTickets = [];
  //     selectedTickets_action = [];
  //   });
  //   filterTickets(searchQuery);
  // }

  @override
  Widget build(BuildContext context) {
    print(tickets.length);
    return Scaffold(
      backgroundColor: Color(0xffFFF0D2),
      body: Column(
        children: [
          Row(children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.03,
            ),
            Container(
              // margin: EdgeInsets.all(16.0),
              width: MediaQuery.of(context).size.width * 0.73,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(5.0),
                border:
                Border(bottom: BorderSide(color: Colors.black, width: 2.0)),
              ),
              child: TextField(
                style: GoogleFonts.lato(
                  color: Colors.black,
                  fontSize: 20,
                ),
                onChanged: (text) {
                  // isFieldEmpty = text.isEmpty;
                  //
                  // onSearchQueryChanged(text);
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
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.filter_alt,
                    color: Colors.black87), // Filter icon
                onPressed: () {
                  // enableDateFilter=true;
                  // _selectDateRange(context);
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
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.filter_alt_off,
                    color: Colors.black87), // Filter icon
                onPressed: () {
                  // setState(() {
                  //   enableDateFilter = !enableDateFilter;
                  //   resetFilter(searchQuery);
                  //   // filterTickets(searchQuery);
                  // });
                },
              ),
            ),
          ]),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),

          pendingRelativeList(tickets),
          // buildSubmit(),
        ],
      ),
    );
  }

  Widget pendingRelativeList(List<StuRelTicket> mytickets) {
    return

      Expanded(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.95,
          // height:MediaQuery.of(context).size.height*0.67,
          child: ListView.builder(
            itemCount: mytickets.length,
            itemBuilder: (BuildContext context, int index) {
              final bool isExpanded = index == selectedIndex;
              return Container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xffEDC882),
                          borderRadius: BorderRadius.circular(
                              15), // Adjust the radius as needed
                        ),
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              title: Text(
                                mytickets[index].studentId,
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
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          "InviteeName :${tickets[index].inviteeName}",
                                          style: GoogleFonts.lato(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                            fontSize: 15,
                                          )),
                                      Text("InviteeRelationship :${tickets[index].inviteeRelationship}",
                                          style: GoogleFonts.lato(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                            fontSize: 15,
                                          )),
                                      Text(
                                          "Contact :${tickets[index].inviteeContact}",
                                          style: GoogleFonts.lato(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                            fontSize: 15,
                                          )),
                                      Text(
                                          "Ticket_type :${tickets[index].status}",
                                          style: GoogleFonts.lato(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                            fontSize: 15,
                                          )),
                                      SizedBox(
                                          height: 5
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.4, // 80% of screen width
                                        height: 1, // Height of the divider
                                        color: Colors.black12, // Color of the divider
                                      ),
                                      SizedBox(
                                          height: 5
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
                                        height: 1, // Height of the divider
                                        color: Colors.black12, // Color of the divider
                                      ),
                                      SizedBox(
                                          height: 5
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async{
                                              // selectedTickets_action.add(tickets[index]);
                                              // await accept_action_tickets_authorities();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
                                              ),
                                            ),
                                            child: Text(
                                              "Accept",
                                              style: GoogleFonts.mPlusRounded1c(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async{
                                              // selectedTickets_action.add(tickets[index]);
                                              // await reject_action_tickets_authorities();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
                                              ),
                                            ),
                                            child: Text(
                                              "Reject",
                                              style: GoogleFonts.mPlusRounded1c(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ]),

                              ),

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
}
