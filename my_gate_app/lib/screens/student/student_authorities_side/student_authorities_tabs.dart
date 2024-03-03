import 'package:flutter/material.dart';
import 'package:my_gate_app/screens/student/student_authorities_side/generate_preapproval_ticket.dart';
import 'package:my_gate_app/screens/student/student_authorities_side/stream_student_authorities_ticket_table.dart';

// This file calls EnterLocation in the first tab and GeneralStudentTicketPage in the second tab

class StudentAuthoritiesTabs extends StatefulWidget {
  const StudentAuthoritiesTabs({super.key, required this.location});
  final String location;

  @override
  State<StudentAuthoritiesTabs> createState() => _StudentAuthoritiesTabsState();
}

class _StudentAuthoritiesTabsState extends State<StudentAuthoritiesTabs>
    with SingleTickerProviderStateMixin {
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

            backgroundColor: Colors.white, // Set the app bar background color to black
            title: Text(
              widget.location,
              style: const TextStyle( color: Colors.black , fontWeight: FontWeight.w800), // Set the title text color to white
            ),
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.black),
            bottom: TabBar(
              // padding: EdgeInsets.symmetric(vertical: 7),
              controller: controller,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(
                    10.0), // Set the border radius for rounded corners
              ), // Set the indicator color to white with opacity
              labelStyle: TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w900),
              unselectedLabelStyle: TextStyle(fontSize: 12,color: Colors.black),
              tabs: const [
                Tab(

                  text: 'Generate\n  Ticket',
                  icon: Icon(Icons.add),
                ),
                Tab(
                  text: '  Past\nTickets',
                  icon: Icon(Icons.history),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: controller,
            children: [
              GeneratePreApprovalTicket(location: widget.location),
              StreamStudentAuthoritiesTicketTable(location: widget.location),
            ],
          ),
        ),
      );
}
