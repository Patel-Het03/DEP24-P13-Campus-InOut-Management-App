// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:my_gate_app/database/database_objects.dart';
import 'package:my_gate_app/screens/guard/pending_guard_ticket_table.dart';
import 'package:my_gate_app/screens/guard/stream_guard_ticket_table.dart';

class GuardTabs extends StatefulWidget {
  const GuardTabs({
    super.key,
    required this.location,
    required this.enter_exit,
  });
  final String location;
  final String enter_exit;

  @override
  State<GuardTabs> createState() => _GuardTabsState();
}

class _GuardTabsState extends State<GuardTabs>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  List<ResultObj> tickets = [];

  // The initState and dispose state are required for adding the tabs
  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget enterExitHeader() {
    if (widget.enter_exit == 'enter') {
      return Text(
        "Enter Tickets",
        style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold),
      );
    } else {
      return Text(
        "Exit Tickets",
        style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold),
      );
    }
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  color:Colors.white
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // backgroundColor: Color.fromARGB(255, 203, 202, 202),
            title: Column(
              children: [
                enterExitHeader(),
                Text(
                  widget.location,
                  style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),

            bottom: TabBar(
              indicator: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(
                    10.0), // Set the border radius for rounded corners
              ),
              controller: controller,
              unselectedLabelColor: Colors.white.withOpacity(0.5),
              // indicatorPadding: EdgeInsets.only(left: 30, right: 30),
              // indicator: ShapeDecoration(
              //     color: Color.fromARGB(255, 255, 255, 255),
              //     shape: BeveledRectangleBorder(
              //         borderRadius: BorderRadius.circular(20),
              //         side: BorderSide(
              //           color: Color.fromARGB(255, 0, 0, 0),
              //         ))),
              // ignore: prefer_const_literals_to_create_immutables
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: TextStyle(fontSize:16,
              fontWeight:FontWeight.bold),
              unselectedLabelStyle: TextStyle(
                  // fontSize:15,
              fontWeight: FontWeight.normal),
              tabs: [
                Tab(
                  icon: Icon(Icons.pending_actions, color: Colors.black),
                  iconMargin: EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Pending\nTickets',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      // fontWeight: FontWeight.bold,
                      // fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Tab(
                  icon:
                      Icon(Icons.approval, color: Color.fromARGB(255, 0, 0, 0)),
                  iconMargin: EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Approved\n Tickets',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      // fontWeight: FontWeight.bold,
                      // fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Tab(
                  icon: Icon(Icons.cancel, color: Color.fromARGB(255, 0, 0, 0)),
                  iconMargin: EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Rejected\n Tickets',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      // fontWeight: FontWeight.bold,
                      // fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
          body: TabBarView(
            controller: controller,
            children: [
              // StreamSelectablePage(location: widget.location,),
              SelectablePage(
                  location: widget.location, enter_exit: widget.enter_exit),
              // Present in file pending_guard_ticket_table.dart
              // GuardTicketTable(location: widget.location, is_approved: "Approved",),
              // GuardTicketTable(location: widget.location, is_approved: "Rejected",),
              StreamGuardTicketTable(
                location: widget.location,
                is_approved: "Approved",
                enter_exit: widget.enter_exit,
                image_path: 'assets/images/approved.jpg',
              ),
              StreamGuardTicketTable(
                  location: widget.location,
                  is_approved: "Rejected",
                  enter_exit: widget.enter_exit,
                  image_path: 'assets/images/rejected.jpg'),
            ],
          ),
        ),
      );

  // PopupMenuItem<MenuItem> buildItem(MenuItem item) => PopupMenuItem<MenuItem>(
  //       value: item,
  //       child: Row(
  //         children: [
  //           Icon(item.icon, size: 20),
  //           const SizedBox(width: 12),
  //           Text(item.text),
  //         ],
  //       ),
  //     );

  // void onSelected(BuildContext context, MenuItem item) {
  //   switch (item) {
  //     case MenuItems.itemProfile:
  //       Navigator.of(context).push(
  //         // MaterialPageRoute(builder: (context) => ProfileController()),
  //         // MaterialPageRoute(builder: (context) => GuardProfilePage(email: LoggedInDetails.getEmail())),
  //         MaterialPageRoute(
  //             builder: (context) =>
  //                 GuardProfilePage(email: LoggedInDetails.getEmail())),
  //       );
  //       break;
  //     case MenuItems.itemLogOut:
  //       LoggedInDetails.setEmail("");
  //       Navigator.of(context).pushReplacement(
  //         MaterialPageRoute(builder: (context) => AuthScreen()),
  //       );
  //       break;
  //   }
  // }
}
