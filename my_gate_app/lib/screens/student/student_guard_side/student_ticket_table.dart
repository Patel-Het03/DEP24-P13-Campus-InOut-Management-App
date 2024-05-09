// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_new, deprecated_member_use, non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/database/database_objects.dart';
import 'package:my_gate_app/screens/utils/scrollable_widget.dart';
import 'package:intl/intl.dart';

class StudentTicketTable extends StatefulWidget {
  StudentTicketTable({
    super.key,
    required this.location,
    required this.tickets,
    required this.pre_approval_required,
  });
  final String location;
  List<ResultObj> tickets;
  final bool pre_approval_required;

  @override
  _StudentTicketTableState createState() => _StudentTicketTableState();
}

class _StudentTicketTableState extends State<StudentTicketTable> {
  // List<TicketResultObj> tickets = [];

  @override
  void initState() {
    super.initState();
    // init();
  }

  Color getColorForType(String status) {
    switch (status) {
      // case "enter":
      //   return Color(0xff3E3E3E); // Change to your desired color
      case "enter":
        return Color(0xff3E5D5D); // Change to your desired color
      case "exit":
        return Color(0xff3E1313); // Change to your desired color
      default:
        return Colors.grey; // Default color
    }
  }


  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white, // added now
        body: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: ListView.builder(
                    itemCount: widget.tickets.length,
                    itemBuilder: (BuildContext context, int index) {
                      // final bool isExpanded = index == selectedIndex;
                      return Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  color: getColorForType(
                                      widget.tickets[index].ticket_type),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ExpansionTile(
                                  // tilePadding: EdgeInsets.zero, // Remove padding
                                  // backgroundColor: Colors.transparent, // Optional: Set background color to transparent if needed
                                  // collapsedBackgroundColor: Colors.transparent,
                                  title: Row(
                                    children: [
                                      Text(
                                        (widget.tickets[index].ticket_type ==
                                                'enter')
                                            ? "Enter"
                                            : (widget.tickets[index]
                                                        .ticket_type ==
                                                    'exit')
                                                ? 'Exit'
                                                : widget
                                                    .tickets[index].ticket_type,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox( width:10),
                                      Text(DateFormat('hh:mm a - MMM dd, yyyy').format(DateTime.parse(widget.tickets[index].date_time))),
                                    ],
                                  ),
                                  children: <Widget>[
                                    Details(widget.tickets[index]),
                                  ],
                                )),
                            SizedBox(height: 8),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),

        // Column(
        //   children: [
        //     Center(
        //       child: Container(
        //         color: Colors.orange.shade100,
        //         padding: EdgeInsets.all(1),
        //         child: Text(
        //           // "Ticket Table",
        //           "",
        //           style: GoogleFonts.roboto(
        //               fontSize: 20, fontWeight: FontWeight.bold),
        //         ),
        //       ),
        //     ),
        //     SizedBox(
        //       height: 2,
        //     ),
        //     Expanded(child: ScrollableWidget(child: buildDataTable())),
        //   ],
        // ),
      );

  Widget Details(ResultObj ticket) {
    // Parse the time string to DateTime object
    DateTime time = DateTime.parse(ticket.date_time);
    print(ticket.date_time);
    print("datetime: ${time}");
    // Format the date and time
    String formattedTime = DateFormat('MMM dd, yyyy - hh:mm a').format(time);
    return Container(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Destination :${ticket.destination_address}",
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 15,
            )),
        Text("Vehicle Number :${ticket.vehicle_number}",
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 15,
            )),
        Text("IsApproved :${ticket.is_approved}",
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 15,
            )),
        SizedBox(
          height: 10,
        )
      ]),
    );
  }

  Widget buildDataTable() {
    List<String> columns_ = [];
    if (widget.pre_approval_required) {
      columns_ = [
        'S.No.',
        'Time',
        'Entry/Exit',
        'Guard Approval',
        'Authority Status',
        'Destination Address',
        'Vehicle Number'
      ];
    } else {
      columns_ = [
        'S.No.',
        'Time',
        'Entry/Exit',
        'Guard Approval',
        'Destination Address',
        'Vehicle Number'
      ];
    }
    List<String> columns = columns_;
    return DataTable(
      // border: TableBorder.all(width: 2, color: Colors.white),
      border: TableBorder.all(width: 2, color: Colors.black),
      // border: TableBorder.all(width: 2, color: Colors.black),
      headingRowColor: MaterialStateProperty.all(Colors.pink),
      columns: getColumns(
        columns,
      ),
      rows: getRows(widget.tickets),
    );
  }

  List<DataColumn> getColumns(List<String> columns) => columns
      .map((String column) => DataColumn(
            // label: Text(column,style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
            label: Text(
              column,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ))
      .toList();

  List<DataRow> getRows(List<ResultObj> tickets) {
    List<DataRow> row_list = [];
    for (int index = 0; index < tickets.length; index++) {
      var ticket = tickets[index];
      if (widget.pre_approval_required) {
        row_list.add(DataRow(
          color: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            // All rows will have the same selected color.
            if (states.contains(MaterialState.selected)) {
              return Theme.of(context).colorScheme.primary.withOpacity(0.08);
              // return Colors.black.withOpacity(0.8);
            }
            // Even rows will have a grey color.
            if (index.isEven) {
              return Colors.grey.withOpacity(0.3);
              // return Colors.black.withOpacity(0.4);
            }
            return null; // Use default value for other states and odd rows.
            // return Colors.black.withOpacity(0.8);
          }),
          // final columns = ['S.No.', 'Time Generated', 'Entry/Exit','Guard Approval','Authority Status'];
          cells: [
            DataCell(Text((index + 1).toString(),
                style: TextStyle(color: Colors.black))),
            DataCell(Text(
                "    ${((ticket.date_time.split("T").last).split(".")[0].split(":").sublist(0, 2)).join(":")}\n${ticket.date_time.split("T")[0]}",
                style: TextStyle(color: Colors.black))),
            DataCell(Text(ticket.ticket_type.toString(),
                style: TextStyle(color: Colors.black))),
            DataCell(Text(ticket.is_approved.toString(),
                style: TextStyle(color: Colors.black))),
            DataCell(Text(ticket.authority_status.toString(),
                style: TextStyle(color: Colors.black))),
            DataCell(Text(ticket.destination_address.toString(),
                style: TextStyle(color: Colors.black))),
            DataCell(Text(ticket.vehicle_number.toString(),
                style: TextStyle(
                    color: Colors.black))), // New column for vehicle number
          ],
        ));
      } else {
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
          // final columns = ['S.No.', 'Time Generated', 'Entry/Exit','Guard Approval','Authority Status'];
          cells: [
            DataCell(Text((index + 1).toString(),
                style: TextStyle(color: Colors.black))),
            DataCell(Text(
                "    ${((ticket.date_time.split("T").last).split(".")[0].split(":").sublist(0, 2)).join(":")}\n${ticket.date_time.split("T")[0]}",
                style: TextStyle(color: Colors.black))),
            DataCell(Text(ticket.ticket_type.toString(),
                style: TextStyle(color: Colors.black))),
            DataCell(Text(ticket.is_approved.toString(),
                style: TextStyle(color: Colors.black))),
            DataCell(Text(ticket.destination_address.toString(),
                style: TextStyle(color: Colors.black))),
            DataCell(Text(ticket.vehicle_number.toString(),
                style: TextStyle(
                    color: Colors.black))), // New column for vehicle number
          ],
        ));
      }
    }
    return row_list;
  }
}
