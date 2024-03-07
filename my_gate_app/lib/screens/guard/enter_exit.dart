// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:my_gate_app/aboutus.dart';
import 'package:my_gate_app/auth/authscreen.dart';
import 'package:my_gate_app/get_email.dart';
import 'package:my_gate_app/screens/profile2/guard_profile/guard_profile_page.dart';
import 'package:my_gate_app/screens/profile2/model/menu_item.dart';
import 'package:my_gate_app/screens/profile2/utils/menu_items.dart';
import 'package:permission_handler/permission_handler.dart';
import 'guard_tabs.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gate_app/screens/notificationPage/notification.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:my_gate_app/screens/profile2/validification_page.dart';

class EntryExit extends StatefulWidget {
  const EntryExit({
    super.key,
    required this.guard_location,
  });
  final String guard_location;

  @override
  State<EntryExit> createState() => _EntryExitState();
}

class _EntryExitState extends State<EntryExit> {
  String welcome_message = "Welcome";
  int notificationCount = /* databaseInterface.return_total_notification_count_guard(LoggedInDetails.getEmail()) */ 0;

  Future<void> get_welcome_message() async {
    String welcome_message_local =
        await databaseInterface.get_welcome_message(LoggedInDetails.getEmail());
    notificationCount = await databaseInterface
        .return_total_notification_count_guard(LoggedInDetails.getEmail());
    setState(() {
      welcome_message = welcome_message_local;
    });
  }

  Future<String?> _qrScanner() async {
    var cameraStatus = await Permission.camera.status;
    if (cameraStatus.isGranted) {
      String? qrdata = await scanner.scan();
      return qrdata;
    } else {
      var isGrant = await Permission.camera.request();
      if (isGrant.isGranted) {
        String? qrdata = await scanner.scan();
        return qrdata;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    get_welcome_message();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color.fromARGB(255, 253, 253, 255),
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        flexibleSpace: Container(
          // decoration: BoxDecoration(
          //     gradient: LinearGradient(
          //         begin: Alignment.centerLeft,
          //         end: Alignment.centerRight,
          //         colors: <Color>[Colors.purple, Colors.blue])
          // ),
        ),
        title: Column(
          children: [
            Text(
              'Guard Home',
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              welcome_message,
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              SizedBox(
                height: kToolbarHeight,
                child: IconButton(
                  icon: Icon(
                    Icons.notifications,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    List<List<String>> messages = await databaseInterface
                        .fetch_notification_guard(LoggedInDetails.getEmail());

                    // print(messages);
                    print("messages printed in page");
                    print(messages);

                    // await databaseInterface
                    //     .mark_stakeholder_notification_as_false(
                    //         LoggedInDetails.getEmail());
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationsPage(
                                  notificationCount: notificationCount,
                                )));
                  },
                ),
              ),
              StreamBuilder<int>(
                stream: databaseInterface
                    .get_notification_count_stream(LoggedInDetails.getEmail()),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    int notificationCount = snapshot.data ?? 0;
                    return Positioned(
                      right: 0,
                      top: 10,
                      child: notificationCount > 0
                          ? Container(
                              padding: EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              constraints: BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '$notificationCount',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : Container(),
                    );
                  } else {
                    return Container();
                  }
                },
              )
            ],
          ),
          PopupMenuButton<MenuItem>(
            onSelected: (item) => onSelected(context, item),
            icon: Icon(Icons.more_vert, color: Colors.white),
            itemBuilder: (context) => [
              ...MenuItems.itemsFirst.map(buildItem),
              PopupMenuDivider(),
              ...MenuItems.itemsThird.map(buildItem),
              PopupMenuDivider(),
              ...MenuItems.itemsSecond.map(buildItem),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
          child: Container(
            decoration: BoxDecoration(
                  // image: DecorationImage(
                  // image: AssetImage("assets/images/bulb.jpg"),
                  // fit: BoxFit.cover,
              color:Color(0xFFf1e2cc),


            ),
            child: Center(
              child: Column(
                // add Column
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/images/enter_exit.webp'),
                  SizedBox(
                    height: 30,
                  ),
                  MaterialButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GuardTabs(
                            location: widget.guard_location,
                            enter_exit: "enter",
                          ),
                        ),
                      );
                    },

                    padding: EdgeInsets.all(0.0),
                    child: Ink(
                      decoration: BoxDecoration(
                        color:Colors.grey[800],
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Container(
                        constraints:
                            BoxConstraints(maxWidth: 250.0, minHeight: 70.0),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_circle_down,
                                color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Enter Tickets",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                  MaterialButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GuardTabs(
                            location: widget.guard_location,
                            enter_exit: "exit",
                          ),
                        ),
                      );
                    },

                    padding: EdgeInsets.all(0.0),
                    child: Ink(
                      decoration: BoxDecoration(
                        color:Colors.grey[800],
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Container(
                        constraints:
                            BoxConstraints(maxWidth: 250.0, minHeight: 70.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_circle_up, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              "Exit Tickets",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  MaterialButton(
                    onPressed: () async {
                      String? qrdata = await _qrScanner();
                      if (qrdata != null) {
                        // Do something with qrdata
                        // print("qrdata bhai=${qrdata}");
                        List<String> qrDataList = qrdata.split('\n');
                        print("email of student${qrDataList[1]}");
                        String email_of_student = qrDataList[1];
                        String veh_reg = qrDataList[2];
                        String dest_address = qrDataList[0];
                        // String entry_no =
                        String ticket_type = qrDataList[3];
                        String location_of_student = qrDataList[4];

                        // String? location_name=qrDataList[4];
                        // print("${}");
                        if (widget.guard_location == location_of_student) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => Validification_page(
                                email: email_of_student,
                                guard_location: widget.guard_location,
                                vehicle_reg: veh_reg,
                                ticket_type: ticket_type,
                                destination_addr: dest_address,
                                guard_email: LoggedInDetails.getEmail(),
                                isEditable: false,
                                student_location: location_of_student,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'You are not authorized for $location_of_student Locations'),
                              backgroundColor:
                                  Colors.red, // Set the background color to red
                            ),
                          );
                        }
                      } else {
                        // Handle the case where qrdata is null
                        print("qrdata bhai=$qrdata");
                      }
                    },

                    padding: EdgeInsets.all(0.0),
                    child: Ink(
                      decoration: BoxDecoration(
                        color:Colors.grey[800],
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Container(
                        constraints:
                            BoxConstraints(maxWidth: 250.0, minHeight: 70.0),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_rounded,
                                color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Scan QR",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // RaisedButton(onPressed: () {}, child: Text('Raise Ticket for Authorities'),), // your button beneath text
                ],
              ),
            ),
          ),
        ),
      ),
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
                  GuardProfilePage(email: LoggedInDetails.getEmail())),
        );
        break;
      case MenuItems.itemLogOut:
        LoggedInDetails.setEmail("");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.clear();
        Navigator.of(context).pop(); // pop the current page
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AuthScreen()),
        );
        break;
        case MenuItems.itemAboutUs:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AboutUsPage()),
        );
        break;
    }
  }
}
