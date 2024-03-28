// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/auth/authscreen.dart';
import 'package:my_gate_app/get_email.dart';
import 'package:my_gate_app/screens/admin/manage_guard/manage_guards_tabs.dart';
import 'package:my_gate_app/screens/admin/manage_admins/manage_admin_tabs.dart';
import 'package:my_gate_app/screens/admin/manage_locations/manage_location_tabs.dart';
import 'package:my_gate_app/screens/admin/statistics/statistics_tabs.dart';
import 'package:my_gate_app/screens/admin/utils/manage_using_excel/manage_excel_tabs.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/screens/profile2/admin_profile/admin_profile_page.dart';
import 'package:my_gate_app/screens/profile2/model/menu_item.dart';
import 'package:my_gate_app/screens/profile2/utils/menu_items.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gate_app/screens/notificationPage/notification.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  _HomeAdminState createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  int notificationCount = 0;
  String welcome_message = "Welcome";

  Future<void> get_welcome_message() async {
    String welcome_message_local =
        await databaseInterface.get_welcome_message(LoggedInDetails.getEmail());
    // print("welcome_message_local: " + welcome_message_local);
    setState(() {
      welcome_message = welcome_message_local;
    });
  }

  @override
  void initState() {
    super.initState();
    get_welcome_message();
    // databaseInterface.getLoctions2().then((result){
    //   setState(() {
    //     entries=result;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Color(0xFFD9D9D9),
            title: Column(
              children: [
                Center(
                  child: Text(
                    'Admin Home',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  welcome_message,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              Stack(
                children: [
                  SizedBox(
                    height: kToolbarHeight,
                    child: IconButton(
                      icon: Icon(Icons.notifications),
                      color: Colors.black,
                      onPressed: () {
                        // Handle notification button press
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NotificationsPage(
                                      notificationCount: 0,
                                    )));
                      },
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 10,
                    child: notificationCount > 0
                        ? Container(
                            padding: EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 15,
                              minHeight: 15,
                            ),
                            child: Text(
                              '$notificationCount',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Container(),
                  ),
                ],
              ),
              PopupMenuButton<MenuItem>(
                onSelected: (item) => onSelected(context, item),
                // color: Colors.black,
                itemBuilder: (context) => [
                  ...MenuItems.itemsFirst.map(buildItem),
                  PopupMenuDivider(),
                  ...MenuItems.itemsSecond.map(buildItem),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(),
              child: Container(
                // height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 13 / 800,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.25,
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          color: Colors.blue, // Change color as per your need
                        ),
                        child: Image.asset(
                          'assets/images/admin.jpg', // Replace with your image URL
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 13 / 800,
                    ),
                    Row(
                      // mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          margin: EdgeInsets.all(0.0),
                          padding: EdgeInsets.all(0.0),
                          child: AdminButton(
                            context,
                            "View Statistics",
                            StatisticsTabs(),
                            "assets/images/admin.jpg",
                            MediaQuery.of(context).size.height * 0.2,
                            MediaQuery.of(context).size.width * 5 / 12,
                          ),
                        ),
                        // statistics
                        // Spacer(),
                        // AdminButton(context,"Manage Student", Colors.amber,ManageStudentsTabs()),
                        Column(
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          // crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              margin: EdgeInsets.all(0.0),
                              padding: EdgeInsets.all(0.0),
                              child: AdminButton(
                                context,
                                "Manage Student",
                                ManageExcelTabs(
                                  appbar_title: "Manage Students",
                                  add_url: "/files/add_students_from_file",
                                  modify_url: "/files/add_students_from_file",
                                  delete_url:
                                      "/files/delete_students_from_file\n/files/delete_students_from_file_individual",
                                  entity: "Student",
                                  data_entity: "Student",
                                  column_names: [
                                    "Name",
                                    "Entry No.",
                                    "Email",
                                    "Gender",
                                    "Dept.",
                                    "Degree",
                                    "Hostel",
                                    "Room",
                                    "Year",
                                    "Mobile",
                                  ],
                                ),
                                "assets/images/Students_Admin.png",
                                MediaQuery.of(context).size.height * 72 / 800,
                                MediaQuery.of(context).size.width * 5 / 12,
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 16 / 800,
                            ),
                            Container(
                              margin: EdgeInsets.all(0.0),
                              padding: EdgeInsets.all(0.0),
                              child: AdminButton(
                                context,
                                "Manage Guards",
                                ManageGuardsTabs(
                                    data_entity: "Guard",
                                    column_names: [
                                      "Name",
                                      "Location",
                                      "Email",
                                    ]),
                                "assets/images/Pie_Graph.png",
                                MediaQuery.of(context).size.height * 72 / 800,
                                MediaQuery.of(context).size.width * 5 / 12,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 13 / 800,
                    ),
                    Container(
                      child: AdminButton(
                        context,
                        "Manage Admins",
                        ManageAdminTabs(
                          data_entity: "Admins",
                          column_names: ["Name", "Email"],
                        ),
                        "assets/images/Pie_Graph.png",
                        MediaQuery.of(context).size.height * 7 / 80,
                        MediaQuery.of(context).size.width * 11 / 12,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 13 / 800,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Container(
                              child: AdminButton(
                                context,
                                "Manage Locations",
                                ManageLocationTabs(
                                  data_entity: "Locations",
                                  column_names: [
                                    "Location",
                                    "Parent Location",
                                    "Pre Approval",
                                    "Automatic Exit",
                                  ],
                                ),
                                "assets/images/Pie_Graph.png",
                                MediaQuery.of(context).size.height * 72 / 800,
                                MediaQuery.of(context).size.width * 5 / 12,
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 13 / 800,
                            ),
                            //locations
                            Container(
                              child: AdminButton(
                                context,
                                "Manage Hostels",
                                ManageExcelTabs(
                                  appbar_title: "Manage Hostels",
                                  add_url: "/files/add_hostels_from_file",
                                  modify_url: "/files/add_hostels_from_file",
                                  delete_url: "/files/delete_hostels_from_file",
                                  entity: "Hostel",
                                  data_entity: "Hostels",
                                  column_names: [
                                    "Hostel Name",
                                  ],
                                ),
                                "assets/images/Pie_Graph.png",
                                MediaQuery.of(context).size.height * 72 / 800,
                                MediaQuery.of(context).size.width * 5 / 12,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          child: AdminButton(
                            context,
                            "Manage Authorities",
                            ManageExcelTabs(
                              appbar_title: "Manage Authorities",
                              add_url: "/files/add_authorities_from_file",
                              modify_url: "/files/add_authorities_from_file",
                              delete_url: "/files/delete_authorities_from_file",
                              entity: "Authorities",
                              data_entity: "Authorities",
                              column_names: [
                                "Name",
                                "Designation",
                                "Email",
                              ],
                            ),
                            "assets/images/Pie_Graph.png",
                            MediaQuery.of(context).size.height * 0.2,
                            MediaQuery.of(context).size.width * 5 / 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 13 / 800,
                    ),
                    Container(
                      child: AdminButton(
                        context,
                        "Manage Departments",
                        ManageExcelTabs(
                          appbar_title: "Manage Departments",
                          add_url: "/files/add_departments_from_file",
                          modify_url: "/files/add_departments_from_file",
                          delete_url: "/files/delete_departments_from_file",
                          entity: "Departments",
                          data_entity: "Departments",
                          column_names: [
                            "Department Name",
                          ],
                        ),
                        "assets/images/Pie_Graph.png",
                        MediaQuery.of(context).size.height * 7 / 80,
                        MediaQuery.of(context).size.width * 11 / 12,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 13 / 800,
                    ),
                    Container(
                      child: AdminButton(
                        context,
                        "Manage Programs",
                        ManageExcelTabs(
                          appbar_title: "Manage Programs",
                          add_url: "/files/add_programs_from_file",
                          modify_url: "/files/add_programs_from_file",
                          delete_url: "/files/delete_programs_from_file",
                          entity: "Programs",
                          data_entity: "Programs",
                          column_names: [
                            "Degree Name",
                            "Degree Duration",
                          ],
                        ),
                        "assets/images/Pie_Graph.png",
                        MediaQuery.of(context).size.height * 7 / 80,
                        MediaQuery.of(context).size.width * 11 / 12,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 13 / 800,
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  PopupMenuItem<MenuItem> buildItem(MenuItem item) => PopupMenuItem<MenuItem>(
        value: item,
        child: Row(
          children: [
            Icon(item.icon, size: 20),
            const SizedBox(width: 12),
            Text(item.text),
          ],
        ),
      );

  void onSelected(BuildContext context, MenuItem item) async {
    switch (item) {
      case MenuItems.itemProfile:
        Navigator.of(context).push(
          // MaterialPageRoute(builder: (context) => ProfileController()),
          // MaterialPageRoute(builder: (context) => GuardProfilePage(email: LoggedInDetails.getEmail())),
          MaterialPageRoute(
              builder: (context) =>
                  AdminProfilePage(email: LoggedInDetails.getEmail())),
        );
        break;
      case MenuItems.itemLogOut:
        LoggedInDetails.setEmail("");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.clear();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AuthScreen()),
        );
        break;
    }
  }
}

Widget AdminButton(BuildContext context, String ButtonText, Widget NextPage,
    String ImagePath, double h, double w) {
  return InkWell(
    onTap: () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => NextPage));
    },
    child: Container(
      height: h,
      width: w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
        color: Colors.orange.shade400,
        image: DecorationImage(
          image: AssetImage(ImagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Text(
        ButtonText,
        style: GoogleFonts.roboto(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    ),
  );
}

Widget AdminButton_1(BuildContext context, String ButtonText, Widget NextPage) {
  return InkWell(
    onTap: () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => NextPage));
    },
    child: Container(
      height: MediaQuery.of(context).size.height / 5,
      width: MediaQuery.of(context).size.width / 1.125,
      alignment: Alignment.center,
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
        // gradient: LinearGradient(
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        //   colors: [Colors.purple.shade200, Colors.lightBlueAccent],
        // ),
        color: Colors.orange.shade400,
        // color:Color(0Xff414BFFFF),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            ButtonText,
            style: GoogleFonts.roboto(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ),
    ),
  );
}
