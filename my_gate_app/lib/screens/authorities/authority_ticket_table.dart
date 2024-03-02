// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_new, deprecated_member_use, non_constant_identifier_names, dead_code
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/database/database_objects.dart';
import 'package:my_gate_app/screens/guard/utils/filter_page.dart';
import 'package:my_gate_app/screens/guard/utils/search_dropdown.dart';
import 'package:my_gate_app/screens/profile2/profile_page.dart';
import 'package:my_gate_app/screens/utils/scrollable_widget.dart';
import 'package:my_gate_app/get_email.dart';

// We pass to this class the value of "is_approved" which takes the value "Accepted"|"Rejected"

class AuthorityTicketTable extends StatefulWidget {
  AuthorityTicketTable({
    Key? key,
    required this.is_approved,
    required this.tickets,
    required this.image_path,
  }) : super(key: key);
  final String is_approved;
  List<ResultObj2> tickets;
  final String image_path;

  @override
  _AuthorityTicketTableState createState() => _AuthorityTicketTableState();
}

class _AuthorityTicketTableState extends State<AuthorityTicketTable> {
  List<ResultObj2> tickets = [];
  List<ResultObj2> ticketsFiltered = [];

  List<String> search_entry_numbers = [];
  String chosen_entry_number = "None";
  String chosen_start_date = "None";
  String chosen_end_date = "None";
  List<bool> isSelected = [true, true];
  bool enableDateFilter = false;
  bool isFieldEmpty = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<List<ResultObj2>> get_tickets_for_authority() async {
    String authority_email = LoggedInDetails.getEmail();
    return await databaseInterface.get_tickets_for_authorities(
        authority_email, widget.is_approved);
  }

  Future init() async {
    final tickets = await get_tickets_for_authority();
    setState(() {
      widget.tickets = tickets;
      // int len = tickets.length;
      // if(len == 0){
      //   TicketResultObj obj = new TicketResultObj.constructor1();
      //   obj.empty_table_entry(obj);
      //   this.tickets = [];
      //   // this.tickets.add(obj);
      // }else{
      //   this.tickets = tickets;
      // }
    });
    filterTickets(searchQuery);
  }

  void filterTickets(String query) {
    if (enableDateFilter) {
      if (query.isEmpty) {
        ticketsFiltered = widget.tickets
            .where((ticket) => DateTime.parse(ticket.date_time).isBefore(
                DateTime.parse(chosen_end_date!).add(Duration(days: 1))))
            .toList();
      } else {
        ticketsFiltered = widget.tickets
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
        ticketsFiltered = widget.tickets;
      } else {
        ticketsFiltered = widget.tickets
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
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
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
                  child: Container(
                    padding: EdgeInsets.all(1),
                    child: Text(
                      // "Ticket Table",
                      "",
                      style: GoogleFonts.roboto(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
                // ClipRRect(
                //   borderRadius: BorderRadius.circular(20),
                //   child: Image.asset(
                //     widget.image_path,
                //     height: 150,
                //   ),
                // ),
                // SizedBox(
                //   height: 20,
                // ),
                SizedBox(
                  height: 20,
                ),
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
                              print("sssssssssssssssssssssssssssssssssssssss");
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
              ],
            ),
          ),
        ),
      );

  Widget buildDataTable() {
    // Fields returned from backend [is_approved, ticket_type, date_time, location, email, student_name, authority_message]

    final columns = [
      'S.No.',
      'Name',
      'Location',
      'Time',
      'Entry/Exit',
      'Authority Message'
    ];

    return DataTable(
      border: TableBorder.all(width: 1, color: Color.fromARGB(255, 0, 0, 0)),
      headingRowColor: MaterialStateProperty.all(Colors.orangeAccent),
      columns: getColumns(columns),
      rows: getRows(ticketsFiltered),
    );

    // return Scaffold(
    //   body: LayoutBuilder(
    //     builder: (context, constraints) => SingleChildScrollView(
    //       child: Column(
    //         children: [
    //           const Text('My Text'),
    //           Container(
    //             alignment: Alignment.topLeft,
    //             child: ConstrainedBox(
    //               constraints: BoxConstraints(maxWidth: constraints.maxWidth),
    //               child: DataTable(
    //                 headingRowColor: MaterialStateProperty.all(Colors.red[200]),
    //                 columns: getColumns(columns),
    //                 rows: getRows(widget.tickets),
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );

    // return DataTable(
    //   headingRowColor: MaterialStateProperty.all(Colors.red[200]),
    //   columns: getColumns(columns),
    //   rows: getRows(widget.tickets),
    // );
  }

  List<DataColumn> getColumns(List<String> columns) => columns
      .map((String column) => DataColumn(
            // label:  Flexible(
            //   child:Text(column,style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
            // )

            // label: ConstrainedBox(
            //   constraints: BoxConstraints(
            //     maxWidth: 20,
            //     minWidth: 20,
            //   ),
            //   child: Flexible(
            //       child:Text(column,style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),)),
            // ),
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
          }
          return null; // Use default value for other states and odd rows.
        }),
        // final columns = ['S.No.', 'Student Name', 'Time Generated', 'Entry/Exit', 'Authority Status'];

        // final columns = ['S.No.', 'Student Name', 'Location', 'Time Generated', 'Entry/Exit', 'Authority Message'];
        cells: [
          DataCell(
            Text(
              (index + 1).toString(),
              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
            ),
          ),
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
            style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
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
            style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          )),
          DataCell(Text(
            ticket.ticket_type.toString(),
            style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          )),
          DataCell(Text(
            ticket.authority_message.toString(),
            style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          )),
        ],
      ));
    }
    return row_list;
  }
}
