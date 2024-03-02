// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_new, deprecated_member_use, non_constant_identifier_names, avoid_print, must_be_immutable
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/database/database_objects.dart';
import 'package:my_gate_app/get_email.dart';
import 'package:my_gate_app/screens/guard/utils/filter_page.dart';
import 'package:my_gate_app/screens/guard/utils/search_dropdown.dart';
import 'package:my_gate_app/screens/profile2/profile_page.dart';
import 'package:my_gate_app/screens/utils/custom_snack_bar.dart';
import 'package:my_gate_app/screens/utils/scrollable_widget.dart';

class PendingAuthorityTicketTable extends StatefulWidget {
  const PendingAuthorityTicketTable({Key? key}) : super(key: key);

  @override
  _PendingAuthorityTicketTableState createState() =>
      _PendingAuthorityTicketTableState();
}

class _PendingAuthorityTicketTableState
    extends State<PendingAuthorityTicketTable> {
  String ticket_accepted_message = '';
  String ticket_rejected_message = '';

  List<ResultObj2> tickets = [];
  List<ResultObj2> ticketsFiltered = [];
  String searchQuery = '';

  List<ResultObj2> selectedTickets = [];
  List<ResultObj2> selectedTickets_action = [];

  List<String> search_entry_numbers = [];
  String chosen_entry_number = "None";
  String chosen_start_date = "None";
  String chosen_end_date = "None";
  List<bool> isSelected = [true, true];
  bool enableDateFilter = false;
  bool isFieldEmpty = true;

  Future<void> accept_selected_tickets_authorities() async {
    databaseInterface db = new databaseInterface();
    int status_code =
        await db.accept_selected_tickets_authorities(selectedTickets);
    // print("The status code is " + status_code.toString());
    if (status_code == 200) {
      print("Selected tickets accepted\n");
      print("Tell this thing to the authority and update the frontend page\n");
      await init();
      final snackBar = get_snack_bar("Selected tickets accepted", Colors.green);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (status_code == 201) {
      print("Selected tickets accepted\n");
      print("Tell this thing to the authority and update the frontend page\n");
      await init();
      final snackBar = get_snack_bar("No Tickets Selected!", Colors.orange);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      print("Failed to accept the tickets\n");
      print("Tell this thing to the authority\n");
      final snackBar =
          get_snack_bar("Failed to accept the tickets", Colors.red);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> reject_selected_tickets_authorities() async {
    databaseInterface db = new databaseInterface();
    int status_code =
        await db.reject_selected_tickets_authorities(selectedTickets);
    print("The status code is " + status_code.toString());
    if (status_code == 200) {
      print("Selected tickets rejected\n");
      print("Tell this thing to the authority and update the frontend page\n");
      await init();
      final snackBar = get_snack_bar("Selected tickets rejected", Colors.green);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (status_code == 201) {
      print("Selected tickets accepted\n");
      print("Tell this thing to the authority and update the frontend page\n");
      await init();
      final snackBar = get_snack_bar("No Tickets Selected!", Colors.orange);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      print("Failed to accept the tickets\n");
      print("Tell this thing to the authority\n");
      final snackBar =
          get_snack_bar("Failed to reject the tickets", Colors.red);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> accept_action_tickets_authorities() async {
    databaseInterface db = new databaseInterface();
    int status_code =
        await db.accept_selected_tickets_authorities(selectedTickets_action);
    if (status_code == 200) {
      await init();
      final snackBar = get_snack_bar("Ticket accepted", Colors.green);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      final snackBar = get_snack_bar("Failed to accept the ticket", Colors.red);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> reject_action_tickets_authorities() async {
    databaseInterface db = new databaseInterface();
    int status_code =
        await db.reject_selected_tickets_authorities(selectedTickets_action);
    print("The status code is " + status_code.toString());
    if (status_code == 200) {
      await init();
      final snackBar = get_snack_bar("Ticket rejected", Colors.green);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      final snackBar = get_snack_bar("Failed to reject the ticket", Colors.red);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void filterTickets(String query) {
    if (enableDateFilter) {
      if (query.isEmpty) {
        ticketsFiltered = tickets
            .where((ticket) => DateTime.parse(ticket.date_time).isBefore(
                DateTime.parse(chosen_end_date!).add(Duration(days: 1))))
            .toList();
      } else {
        ticketsFiltered = tickets
            .where((ticket) =>
                ticket.student_name
                    .toLowerCase()
                    .contains(query.toLowerCase()) &&
                DateTime.parse(ticket.date_time)
                    .isAfter(DateTime.parse(chosen_start_date!)) &&
                DateTime.parse(ticket.date_time).isBefore(
                    DateTime.parse(chosen_end_date!).add(Duration(days: 1))))
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

  void onSearchQueryChanged(String query) {
    setState(() {
      searchQuery = query;
      filterTickets(searchQuery);
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
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<List<ResultObj2>> get_pending_tickets_for_authority() async {
    String authority_email = LoggedInDetails.getEmail();
    return await databaseInterface
        .get_pending_tickets_for_authorities(authority_email);
  }

  Future init() async {
    final tickets_local = await get_pending_tickets_for_authority();
    setState(() {
      tickets = tickets_local;
      selectedTickets = [];
      selectedTickets_action = [];
    });
    filterTickets(searchQuery);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Image.asset(
                  'assets/images/authority.png',
                  height: 200,
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //Center Row contents horizontally,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    //Center Row contents vertically,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //Center Row contents horizontally,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        //Center Row contents vertically,

                        children: [
                          Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 4,
                                padding: EdgeInsets.all(5),
                                child: ElevatedButton.icon(
                                  icon: Icon(
                                    Icons.check_circle_outlined,
                                    color: Colors.white,
                                    size:
                                        MediaQuery.of(context).size.width / 15,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      textStyle: const TextStyle(fontSize: 20),
                                      backgroundColor: Color.fromARGB(255, 9, 216, 9)),
                                  onPressed: () async {
                                    accept_selected_tickets_authorities();
                                  },
                                  label: Text(
                                    '',
                                    style: GoogleFonts.roboto(),
                                  ),
                                ),
                                //decoration: Decoration(),
                              ),
                              // Text(
                              //   ticket_accepted_message,
                              //   style: TextStyle(color: Colors.white),
                              // ),
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 4,
                                padding: EdgeInsets.all(5),
                                //color: Colors.green,
                                child: ElevatedButton.icon(
                                  icon: Icon(
                                    Icons.cancel,
                                    color: Colors.white,
                                    size:
                                        MediaQuery.of(context).size.width / 15,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      textStyle: const TextStyle(fontSize: 20),
                                      backgroundColor: Colors.red),
                                  onPressed: () {
                                    reject_selected_tickets_authorities();
                                  },
                                  label: Text(
                                    '',
                                    style: GoogleFonts.roboto(),
                                  ),
                                ),
                                //decoration: Decoration(),
                              ),
                              // Text(
                              //   ticket_rejected_message,
                              //   style: TextStyle(color: Colors.white),
                              // ),
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 4,
                                padding: EdgeInsets.all(5),
                                child: ElevatedButton.icon(
                                  icon: Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                    size:
                                        MediaQuery.of(context).size.width / 15,
                                  ),
                                  onPressed: () async {
                                    init();
                                  },
                                  label: Text(""),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),

                // Center(
                //   child: Container(
                //     padding: EdgeInsets.all(1),
                //     child: Text(
                //       // "Ticket Table",
                //       "",
                //       style: GoogleFonts.roboto(
                //           fontSize: 20, fontWeight: FontWeight.bold),
                //     ),
                //   ),
                // ),
                // SizedBox(
                //   height: 2,
                // ),
                // buildDataTable()
                // Text("No entries available in the ticket table"),
                // Testing()
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 1.4,
                      child: InputDecorator(
                        isEmpty:
                            isFieldEmpty, // if true, the hint text is shown
                        decoration: InputDecoration(
                          hintText: '    Search by Name',
                          hintStyle: TextStyle(
                              color: Color.fromARGB(255, 96, 96,
                                  96)), // Set the desired color for the hint text
                        ),

                        child: TextField(
                          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                          decoration: InputDecoration(
                            // labelText: "Name",
                            // hintText: "Enter name to filter tickets",
                            // hintStyle: TextStyle(color: Colors.grey),
                            // helperText: "Enter name to filter tickets",
                            // helperStyle: TextStyle(color: Colors.grey),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                          onChanged: (text) {
                            isFieldEmpty = text.isEmpty;

                            onSearchQueryChanged(text);
                          },
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 3,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.filter_list,
                        color: Color.fromARGB(255, 0, 0, 0),
                        size: 30.0,
                      ),
                      onPressed: () => _selectDateRange(context),
                    ),
                    // IconButton(
                    //   icon: Icon(
                    //     Icons.search,
                    //     color: Color.fromARGB(255, 0, 0, 0),
                    //     size: 24.0,
                    //   ),
                    //   onPressed: () {
                    //     print(this.chosen_entry_number);
                    //     print(this.chosen_start_date);
                    //     print(this.chosen_end_date);
                    //     print(this.isSelected);
                    //   },
                    // ),
                    // SizedBox(
                    //   width: 340,
                    // )
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    IntrinsicWidth(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color:
                                  Colors.grey), // Set the desired border color
                          borderRadius: BorderRadius.circular(
                              8.0), // Set the desired border radius
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              enableDateFilter = !enableDateFilter;
                              print(enableDateFilter);
                              filterTickets(searchQuery);
                            });
                          },
                          child: Row(
                            children: [
                              Theme(
                                data: ThemeData(
                                  unselectedWidgetColor: Colors
                                      .black, // Set the desired outline color
                                ),
                                child: Radio<bool>(
                                  activeColor: Colors
                                      .red, // Set the desired color for the radio button
                                  value: enableDateFilter,
                                  groupValue: true,
                                  onChanged: (value) {
                                    // setState(() {
                                    //   enableDateFilter = value!;
                                    // });
                                  },
                                ),
                              ),
                              Text(
                                'Date Filter  ',
                                style: TextStyle(
                                  color: enableDateFilter
                                      ? Colors.blue
                                      : Colors
                                          .black, // Set the desired color for the label
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Start Date: ${chosen_start_date.split(" ")[0]}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "End Date: ${chosen_end_date.split(" ")[0]}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(child: ScrollableWidget(child: buildDataTable())),
                // buildSubmit(),
              ],
            ),
          ),
        ),
      );

  // Widget Testing() {
  //   int len = tickets.length;
  //   print("len of tickets " + len.toString());
  //   if(len == 0){
  //     return Text("No entries available in the ticket table");
  //   }
  //   // return Text("No entries available in the ticket table");

  //   final columns = ['Serial No', 'Location ID', 'Time Stamp', 'Approve Status'];
  //   return DataTable(
  //     onSelectAll: (isSelectedAll) {
  //       setState(() => selectedTickets = isSelectedAll! ? tickets : []);
  //       // Utils.showSnackBar(context, 'All Selected: $isSelectedAll');
  //     },
  //     headingRowColor: MaterialStateProperty.all(Colors.red[200]),
  //     columns: getColumns(columns),
  //     rows: getRows(tickets),
  //   );
  // }

  Widget buildDataTable() {
    // Fields returned from backend [is_approved, ticket_type, date_time, location, email, student_name, authority_message]

    final columns = [
      'Student',
      'Location',
      'Time',
      'Entry/Exit',
      'Authority Message',
      'Action'
    ];

    return DataTable(
      onSelectAll: (isSelectedAll) {
        setState(() => selectedTickets = isSelectedAll! ? tickets : []);
        // Utils.showSnackBar(context, 'All Selected: $isSelectedAll');
      },
      border: TableBorder.all(width: 1, color: Color.fromARGB(255, 0, 0, 0)),
      headingRowColor: MaterialStateProperty.all(Colors.orangeAccent),
      columns: getColumns(columns),
      rows: getRows(ticketsFiltered),
    );
  }

  List<DataColumn> getColumns(List<String> columns) => columns
      .map((String column) => DataColumn(
            label: Text(
              column,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ))
      .toList();

  List<DataRow> getRows(List<ResultObj2> tickets) {
    List<DataRow> row_list = [];
    for (int index = 0; index < tickets.length; index++) {
      var ticket = tickets[index];
      row_list.add(DataRow(
        color: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          // All rows will have the same selected color.
          if (states.contains(MaterialState.selected)) {
            return Theme.of(context).colorScheme.primary.withOpacity(0.08);
          }
          // Even rows will have a grey color.
          if (index.isEven) {
            return Colors.grey.withOpacity(0.3);
          } else {
            return Color.fromARGB(255, 91, 101, 128).withOpacity(0.3);
          }
          return null; // Use default value for other states and odd rows.
        }),
        selected: selectedTickets.contains(ticket),
        onSelectChanged: (isSelected) => setState(() {
          final isAdding = isSelected != null && isSelected;

          isAdding
              ? selectedTickets.add(ticket)
              : selectedTickets.remove(ticket);
          print(selectedTickets);
        }),

        // final columns = ['S.No.', 'Student Name', 'Location', 'Time Generated', 'Entry/Exit', 'Authority Message'];
        cells: [
          DataCell(
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) =>
                          ProfilePage(email: ticket.email, isEditable: false)),
                );
              },
              child: Text(
                ticket.student_name.toString(),
                style: TextStyle(color: Colors.lightBlueAccent),
              ),
            ),
          ),
          // DataCell(Text(ticket.student_name.toString())),
          DataCell(Text(
            ticket.location.toString(),
            style: TextStyle(color: Colors.black),
          )),
          DataCell(Text(
            "    " +
                ((ticket.date_time.split("T").last)
                        .split(".")[0]
                        .split(":")
                        .sublist(0, 2))
                    .join(":") +
                "\n" +
                ticket.date_time.split("T")[0],
            style: TextStyle(color: Colors.black),
          )),
          DataCell(Text(
            ticket.ticket_type.toString(),
            style: TextStyle(color: Colors.black),
          )),
          // DataCell(Text(ticket.authority_message.toString())),
          DataCell(
            TextField(
              onChanged: (text) {
                this.tickets[index].authority_message = text;
              },
              style: TextStyle(color: Colors.black),
            ),
          ),
          DataCell(Row(
            children: [
              IconButton(
                onPressed: () async {
                  selectedTickets_action.add(ticket);
                  await accept_action_tickets_authorities();
                },
                icon: Icon(
                  // Action Button Tick
                  Icons.check_circle_outlined,
                  color: Colors.green,
                  size: 24.0,
                ),
              ),
              IconButton(
                // Action Button Cross
                onPressed: () async {
                  selectedTickets_action.add(ticket);
                  await reject_action_tickets_authorities();
                },
                icon: Icon(
                  Icons.cancel,
                  color: Colors.red,
                  size: 24.0,
                ),
              ),
            ],
          ))
        ],
      ));
    }
    return row_list;
  }
}
