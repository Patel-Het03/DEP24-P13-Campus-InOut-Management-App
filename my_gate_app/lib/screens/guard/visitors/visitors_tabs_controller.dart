// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:my_gate_app/database/database_objects.dart';
import 'package:my_gate_app/screens/guard/visitors/oldVisitorsSearch.dart';
import 'package:my_gate_app/screens/guard/visitors/oldVisitorsSearchStudents.dart';

class VisitorsTabs extends StatefulWidget {
  const VisitorsTabs({
    Key? key,
    required this.username,
    required this.phonenumber,
    this.userid,
  }) : super(key: key);
  final String username;
  final String phonenumber;
  final int? userid;

  @override
  State<VisitorsTabs> createState() => _VisitorsTabsState();
}

class _VisitorsTabsState extends State<VisitorsTabs>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  List<ResultObj> tickets = [];

  // The initState and dispose state are required for adding the tabs
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
            centerTitle: true,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[Colors.purple, Colors.blue])),
            ),
            title: Text("Choose the Person",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // backgroundColor: Color.fromARGB(255, 203, 202, 202),

            bottom: TabBar(
              indicator: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
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
              tabs: [
                Tab(
                  icon: Icon(Icons.pending_actions, color: Colors.black),
                  iconMargin: EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Student',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Tab(
                  icon:
                      Icon(Icons.approval, color: Color.fromARGB(255, 0, 0, 0)),
                  iconMargin: EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Authority',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: controller,
            children: [

              oldVisitorSeacrchStudent(username: widget.username, phonenumber: widget.phonenumber),
              oldVisitorSeacrch(username: widget.username, phonenumber: widget.phonenumber),
            ],
          ),
        ),
      );

}
