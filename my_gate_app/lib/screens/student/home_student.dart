// ignore_for_file: prefer_const_constructors, unnecessary_brace_in_string_interps, unnecessary_string_interpolations, non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/aboutus.dart';
import 'package:my_gate_app/auth/authscreen.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/get_email.dart';
import 'package:my_gate_app/screens/profile2/profile_page.dart';
import 'package:my_gate_app/screens/student/raise_ticket_for_guard_or_authorities.dart';
import 'package:my_gate_app/screens/profile2/model/menu_item.dart';
import 'package:my_gate_app/screens/profile2/utils/menu_items.dart';
import 'package:my_gate_app/screens/student/student_guard_side/student_tabs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gate_app/myglobals.dart' as myglobals;
import 'dart:async';
import 'package:my_gate_app/screens/student/Invitee_Info.dart';
import 'package:my_gate_app/screens/profile2/model/user.dart';
import 'package:my_gate_app/screens/profile2/utils/user_preferences.dart';
import 'package:my_gate_app/screens/notificationPage/notification.dart';

// This file calls StudentTicketTable

class HomeStudent extends StatefulWidget {
  final String? email;
  const HomeStudent({super.key, required this.email});

  @override
  _HomeStudentState createState() => _HomeStudentState();
}

Color getColorFromHex(String hexColor) {
  hexColor = hexColor.replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF$hexColor";
  }
  if (hexColor.length == 8) {
    return Color(int.parse("0x$hexColor"));
  }
  return Colors.cyanAccent[100] as Color;
}

class _HomeStudentState extends State<HomeStudent> {
  var user = UserPreferences.myUser;

  late String imagePath;

  var imagePicker;
  final ValueNotifier<bool> updateColor = ValueNotifier(false);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  var pic;

  Future<void> init() async {
    String? curr_email = widget.email;
    print("Current Email: $curr_email");
    databaseInterface db = databaseInterface();
    User result = await db.get_student_by_email(curr_email);
    // print("result obj image path" + result.imagePath);
    setState(() {
      user = result;
      imagePath = result.imagePath;
      // print("image path inside setstate: " + imagePath);
    });

    setState(() {
      pic = result.profileImage;
    });
    /* print("Gender in yo:"+controller_gender.text); */
  }

  int notificationCount = 0;

  List<String> entries = [];
  int entries_length = 0;
  List<int> location_id = [];
  List<bool> pre_approvals = [];
  List<String> studentStatus = ["IN", "OUT", "OUT", "IN", "OUT", "IN"];
  List<int> in_count = [0, 0, 0, 0, 0, 0];

  List<Color?> inkColors = [
    Colors.orangeAccent[100],
    getColorFromHex('f5a6ff'),
    getColorFromHex('f7f554'),
    getColorFromHex('34ebc0'),
    Colors.lightGreenAccent[200],
    // Colors.cyanAccent[100],
    getColorFromHex('62de72'),
    // Colors.red[300],
  ];

  // List<String> entries = databaseInterface.getLoctions();
  String welcome_message = "Welcome";

  // Map<String, String> location_images_paths = databaseInterface.getLocationImagesPaths();
  final List<String> location_images_paths =
      databaseInterface.getLocationImagesPaths();
  //final List<int> colorCodes = <int>[600, 500, 100,600, 500, 100,600, 500, 100,600, 500, 100,600, 500, 100,600, 500, 100,600, 500, 100,];

  Future<void> get_welcome_message() async {
    String welcome_message_local =
        await databaseInterface.get_welcome_message(LoggedInDetails.getEmail());

    List<String> studentStatusDB =
        await databaseInterface.get_student_status_for_all_locations_2(
            LoggedInDetails.getEmail(), location_id);
    print("welcome_message_local: $welcome_message_local");
    print("studentStatusDB:${studentStatusDB}");
    // print(studentStatusDB);
    notificationCount = await databaseInterface
        .return_total_notification_count_guard(LoggedInDetails.getEmail());

    setState(() {
      welcome_message = welcome_message_local;
      print("Going here");
      studentStatus = studentStatusDB;
    });
  }

  @override
  void initState() {
    super.initState();

    databaseInterface.getLoctionsAndPreApprovals().then((result) {
      setState(() {
        entries = result.locations;
        entries_length = entries.length - 1;
        location_id = result.location_id;
        print("entries in home=${entries}");
        print("id's=${result.location_id}");
        print("preapprovals : ${result.preApprovals}");
        pre_approvals = result.preApprovals;
      });

      get_welcome_message();
      fetchData();
    });

    imagePath = UserPreferences.myUser.imagePath;
    pic = NetworkImage(imagePath);

    // print("image path in image widget: " + this.imagePath);
    init();
  }

  Future<void> fetchData() async {
    List<int> count = [];
    print("LENGTH IS");
    for (int i = 0; i < entries.length; i++) {
      print(entries.length);
      print("=====================");
      print(i);
      int value = await databaseInterface.count_inside_Location(location_id[i]);
      count.add(value);
      print("ooooooooooooooooooo");
      print(i);
      print(value);
    }

    List<String> status =
        await databaseInterface.get_student_status_for_all_locations_2(
            LoggedInDetails.getEmail(), location_id);

    setState(() {
      in_count = count;
      print("asdaasdasdasdasdasdasd");
      print(in_count);
      studentStatus = status;
      print(studentStatus);
    });
  }

  String show_image(int index) {
    if (index < 6) {
      return location_images_paths[index];
    }
    return 'assets/images/spiral.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // bottomNavigationBar: Container(
      //   margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      //   color: Colors.grey,
      //   child: ClipRRect(
      //     borderRadius: BorderRadius.circular(20),
      //     child: BottomAppBar(
      //       color: Colors.black,
      //       elevation: 0, // Remove the default shadow
      //
      //       child: Container(
      //         height: 60, // Adjust the height as needed
      //         padding: EdgeInsets.symmetric(horizontal: 10),
      //         margin: EdgeInsets.all(0.0),
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceAround,
      //           children: [
      //             IconButton(
      //               icon: Icon(Icons.home, color: Colors.white),
      //               onPressed: () {
      //                 // Navigate to Home screen
      //               },
      //             ),
      //             IconButton(
      //               icon: Icon(Icons.person, color: Colors.white),
      //               onPressed: () {
      //                 // Navigate to Profile screen
      //               },
      //             ),
      //             IconButton(
      //               icon: Icon(Icons.logout, color: Colors.white),
      //               onPressed: () {
      //                 // Perform logout action
      //               },
      //             ),
      //           ],
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          shadowColor: Colors.grey.shade300,

          // backgroundColor: Color.fromARGB(255, 0, 0, 0),
          backgroundColor: Colors.white,
          // surfaceTintColor: Colors.green,
          // shadowColor: Colors.green,

          elevation: 0,
          shape: RoundedRectangleBorder(
              // borderRadius: BorderRadius.vertical(
              //   bottom: Radius.circular(30.0),
              // )
              ),
          centerTitle: true,
          title: Padding(
            padding: EdgeInsets.only(top: 35.0, bottom: 35.0),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 40.0, bottom: 30.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.07,
                    height: MediaQuery.of(context).size.width * 0.07,
                    child: ValueListenableBuilder<bool>(
                      valueListenable: updateColor,
                      builder: (context, newPic, child) {
                        return ClipOval(
                          child: Image(
                            image: pic,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                Expanded(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.width * 0.022),
                        Text(
                          'Hi,',
                          style: GoogleFonts.poppins(
                            // color: Color.fromARGB(221, 255, 255, 255),
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: MediaQuery.of(context).size.width * 0.025,
                          ),
                        ),
                        Text(
                          '${welcome_message}',
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          style: GoogleFonts.poppins(
                            // color: Color.fromARGB(221, 255, 255, 255),
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: MediaQuery.of(context).size.width * 0.045,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Stack(
              children: [
                SizedBox(
                  height: kToolbarHeight,
                  child: IconButton(
                    icon: Icon(
                      Icons.notifications,
                      // color: Color.fromARGB(225, 255, 255, 255),
                      color: Colors.black,
                    ),
                    onPressed: () async {
                      print("Student notification=${notificationCount}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationsPage(
                            notificationCount: notificationCount,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                StreamBuilder<int>(
                  stream: databaseInterface.get_notification_count_stream(
                    LoggedInDetails.getEmail(),
                  ),
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
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '$notificationCount',
                                  style: TextStyle(
                                    // color: Color.fromARGB(225, 255, 255, 255),
                                    color: Colors.black,
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
                ),
              ],
            ),
            PopupMenuButton<MenuItem>(
              onSelected: (item) => onSelected(context, item),
              icon: Icon(
                Icons.more_vert,
                // color: Color.fromARGB(221, 255, 255, 255),
                color: Colors.black,
              ),
              itemBuilder: (context) => [
                ...MenuItems.itemsFirst.map(buildItem),
                PopupMenuDivider(),
                ...MenuItems.itemsThird.map(buildItem),
                PopupMenuDivider(),
                ...MenuItems.itemsSecond.map(buildItem),
              ],
            ),
          ],
        ),
      ),
      // body: Stack(
      //   children: [
      //     Container(
      //       decoration: BoxDecoration(
      //           borderRadius: BorderRadius.only(
      //             topLeft: Radius.circular(35.0),
      //             topRight: Radius.circular(35.0),
      //           ),
      //           color: Colors.orange.shade100,
      //           boxShadow: [
      //             BoxShadow(
      //               color: Colors.orange.withOpacity(0.3),
      //               blurRadius: 8,
      //               spreadRadius: 2,
      //               offset: Offset(0, 3),
      //             ),
      //           ],
      //       ),
      //
      //       // padding: EdgeInsets.only(top: 30.0),
      //       height: MediaQuery.of(context).size.height,
      //       // decoration: BoxDecoration(
      //       //   color: Color(0Xfff1e2cc),
      //       // ),
      //       // color: Colors.bla,
      //       child: GridView.builder(
      //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      //           crossAxisCount: 2,
      //           // MediaQuery.of(context).orientation == Orientation.landscape
      //           //     ? 3
      //           //     : 2,
      //           //crossAxisCount: 3,
      //           crossAxisSpacing: 8,
      //           mainAxisSpacing: 8,
      //           // childAspectRatio: (1.2 / 1),
      //           childAspectRatio: 1.0,
      //           // crossAxisSpacing: 100,
      //           // mainAxisSpacing: 100,
      //           // crossAxisCount: 2,
      //         ),
      //         //primary: false,
      //         //padding: const EdgeInsets.all(20),
      //         //crossAxisSpacing: 10,
      //         //mainAxisSpacing: 2,
      //
      //         itemCount: entries.length,
      //         itemBuilder: (BuildContext context, int index) {
      //           // default to 0 if data is null
      //           return InkWell(
      //             onTap: () {
      //               // print("Email fetched from our own function: " + LoggedInDetails.getEmail());
      //               if (pre_approvals[index] == true) {
      //                 Navigator.push(
      //                     context,
      //                     MaterialPageRoute(
      //                       // builder: (context) => StudentTicketTable(
      //                       //   location: entries[index],
      //                       // ),
      //                       builder: (context) =>
      //                           RaiseTicketForGuardOrAuthorities(
      //                         location: entries[index],
      //                         // TODO: fetch pre_approval_required from backend
      //                         pre_approval_required: pre_approvals[index],
      //                       ),
      //                       // builder: (context) => EnterLocation(
      //                       //       location: entries[index],
      //                       //     )
      //                     )).then((value) => fetchData());
      //               } else {
      //                 Navigator.push(
      //                     context,
      //                     MaterialPageRoute(
      //                         builder: (context) => StudentTabs(
      //                               location: entries[index],
      //                               pre_approval_required: pre_approvals[index],
      //                             ))).then((value) => fetchData());
      //               }
      //             },
      //             child: Container(
      //               height: MediaQuery.of(context).size.height * 0.02,
      //               width: MediaQuery.of(context).size.height * 0.02,
      //               //margin: EdgeInsets.only(bottom: 20),
      //               margin: EdgeInsets.all(20),
      //               decoration: BoxDecoration(
      //
      //                 color: Colors.orange.shade600,
      //                 // border: Border.all(
      //                 //   width: 2,
      //                 //   color: Colors.black.withOpacity(0.5),
      //                 // ),
      //                 borderRadius: BorderRadius.only(
      //                     topLeft: Radius.circular(20),
      //                     topRight: Radius.circular(20),
      //                     bottomLeft: Radius.circular(20),
      //                     bottomRight: Radius.circular(20)),
      //                     boxShadow: [
      //                       BoxShadow(
      //                         // color: inkColors[index % inkColors.length].withOpacity(0.5),
      //                         color: Colors.grey.withOpacity(0.3),
      //                         spreadRadius: 5,
      //                         blurRadius: 7,
      //                         offset: Offset(0, 3), // changes position of shadow
      //                       ),
      //                     ],
      //               ),
      //               // decoration: BoxDecoration(
      //               //   shape: BoxShape.rectangle,
      //               //   color: Colors.blue[100 * (index % 3 + 1)],
      //               //   borderRadius: BorderRadius.circular(20),
      //               // ),
      //               //color: Colors.amber[colorCodes[index]],
      //               child: Column(
      //                 children: [
      //                   SizedBox(
      //                     width: MediaQuery.of(context).size.width * 0.03,
      //                   ),
      //
      //                   Container(
      //                     child: Column(
      //                       mainAxisAlignment: MainAxisAlignment.start,
      //                       crossAxisAlignment: CrossAxisAlignment.start,
      //                       children: [
      //                         SizedBox(
      //                           height:
      //                               MediaQuery.of(context).size.width * 0.01,
      //                         ),
      //                         Align(
      //                           alignment: Alignment.center,
      //                           child: FittedBox(
      //                             fit: BoxFit.contain,
      //                             child: Text(
      //                               '  ${entries[index]}',
      //                               overflow: TextOverflow.fade,
      //                               maxLines: 1,
      //                               style: GoogleFonts.poppins(
      //                                 fontSize:
      //                                     MediaQuery.of(context).size.width *
      //                                         0.04,
      //                                 fontWeight: FontWeight.w500
      //                                 color: Colors.white,
      //                               ),
      //                             ),
      //                           ),
      //                         ),
      //                         // Center(children )
      //                         Center(
      //                           child: Column(
      //                               mainAxisAlignment: MainAxisAlignment.center,
      //                               crossAxisAlignment:
      //                                   CrossAxisAlignment.center,
      //                               children: [
      //                                 Container(
      //                                   margin: EdgeInsets.only(
      //                                       top: MediaQuery.of(context)
      //                                               .size
      //                                               .width *
      //                                           0.01),
      //                                   height:
      //                                       MediaQuery.of(context).size.width *
      //                                           0.19,
      //
      //                                   // child: Image.asset(location_images_paths[index]),
      //                                   child: show_image(index),
      //                                 ),
      //                                 SizedBox(
      //                                   height:
      //                                       MediaQuery.of(context).size.height *
      //                                           0.002,
      //                                 ),
      //                                 Row(
      //                                   mainAxisAlignment:
      //                                       MainAxisAlignment.center,
      //                                   children: [
      //                                     Icon(
      //                                       Icons.location_on,
      //                                       color: studentStatus[index]
      //                                                   .toLowerCase() ==
      //                                               "out"
      //                                           ? Colors.red
      //                                           : Colors.green,
      //                                       size: MediaQuery.of(context)
      //                                               .size
      //                                               .width *
      //                                           0.03,
      //                                     ),
      //                                     SizedBox(
      //                                       width: MediaQuery.of(context)
      //                                               .size
      //                                               .width *
      //                                           0.01,
      //                                     ),
      //                                     Text(
      //                                       "Status: ${studentStatus[index]
      //                                               .toUpperCase()}",
      //                                       style: GoogleFonts.poppins(
      //                                         fontSize: MediaQuery.of(context)
      //                                                 .size
      //                                                 .width *
      //                                             0.03,
      //                                         fontWeight: FontWeight.normal,
      //                                         color:
      //                                             // Color.fromARGB(255, 0, 0, 0),
      //                                         Colors.white,
      //                                       ),
      //                                       textAlign: TextAlign.center,
      //                                     ),
      //                                   ],
      //                                 ),
      //                                 Row(
      //                                   mainAxisAlignment:
      //                                       MainAxisAlignment.center,
      //                                   children: [
      //                                     Icon(
      //                                       Icons.person,
      //                                       color: Colors.lightBlue,
      //                                       size: MediaQuery.of(context)
      //                                               .size
      //                                               .width *
      //                                           0.03,
      //                                     ),
      //                                     SizedBox(
      //                                         width: MediaQuery.of(context)
      //                                                 .size
      //                                                 .width *
      //                                             0.01),
      //                                     Text(
      //                                       "In Count: ${in_count[index]}",
      //                                       style: GoogleFonts.roboto(
      //                                         fontSize: MediaQuery.of(context)
      //                                                 .size
      //                                                 .width *
      //                                             0.03,
      //                                         fontWeight: FontWeight.normal,
      //                                         color:
      //                                             // Color.fromARGB(255, 0, 0, 0),
      //                                         Colors.white,
      //                                       ),
      //                                       textAlign: TextAlign.right,
      //                                     ),
      //                                   ],
      //                                 ),
      //                                 // SizedBox(
      //                                 //   height:
      //                                 //       MediaQuery.of(context).size.height *
      //                                 //           0.01,
      //                                 // ),
      //                               ]),
      //                         )
      //                       ],
      //                     ),
      //                   ),
      //                   // Spacer(),
      //                   // Icon(
      //                   //   Icons.arrow_right,
      //                   //   color: Colors.lightBlue,
      //                   //   size: 50.0,
      //                   // ),
      //                 ],
      //               ),
      //             ),
      //           );
      //         },
      //         // separatorBuilder: (BuildContext context, int index) =>
      //         //     const Divider(),
      //       ),
      //     ),
      //     // ValueListenableBuilder<bool>(
      //     //   valueListenable: isLoading,
      //     //   builder: (context, BisLoading, child) {
      //     //     return Column(
      //     //       mainAxisAlignment: MainAxisAlignment.center,
      //     //       children: [
      //     //         isLoading.value
      //     //             ? Center(
      //     //                 child: CircularProgressIndicator(),
      //     //               )
      //     //             : Container(),
      //
      //     //         // rest of the code
      //     //       ],
      //     //     );
      //     //   },
      //     // ),
      //   ],
      // ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your key to convenience,',
                    style: GoogleFonts.kodchasan(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Encoded in a scan!!',
                    style: GoogleFonts.kodchasan(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                // print("Email fetched from our own function: " + LoggedInDetails.getEmail());
                if (pre_approvals[0] == true) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        // builder: (context) => StudentTicketTable(
                        //   location: entries[index],
                        // ),
                        builder: (context) => RaiseTicketForGuardOrAuthorities(
                          location: entries[0],
                          // TODO: fetch pre_approval_required from backend
                          pre_approval_required: pre_approvals[0],
                        ),
                        // builder: (context) => EnterLocation(
                        //       location: entries[index],
                        //     )
                      )).then((value) => fetchData());
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StudentTabs(
                                location: entries[0],
                                pre_approval_required: pre_approvals[0],
                              ))).then((value) => fetchData());
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 0.0), // Add margin
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), // Add border radius
                  color: Color(0xff3E3E3E),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Main Gate",
                          style: GoogleFonts.mPlusRounded1c(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Status: ${studentStatus[0].toUpperCase()}",
                          style: GoogleFonts.mPlusRounded1c(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 10),
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 10), // Add margin to separate from text
                      width: 90,
                      height: 100,
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(10), // Add border radius
                          border: Border.all(color: Colors.white),
                          color: Colors.white // Add border
                          ),
                      child: ClipRRect(
                        // ClipRRect for applying border radius to the image
                        borderRadius: BorderRadius.circular(
                            10), // Same as container border radius
                        child: Image.asset(
                          "assets/images/spiral.jpg", // Use your show_image function to provide the image path
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ListView.builder(
            //   shrinkWrap: true,
            //   physics: NeverScrollableScrollPhysics(),
            //   itemCount: entries.length,
            //   itemBuilder: (BuildContext context, int index) {
            //     return Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: Card(
            //         color: Color(0xFFF3F3F3),
            //         elevation: 3,
            //         child: InkWell(
            //           onTap: () {
            //             // print("Email fetched from our own function: " + LoggedInDetails.getEmail());
            //             if (pre_approvals[index] == true) {
            //               Navigator.push(
            //                   context,
            //                   MaterialPageRoute(
            //                     // builder: (context) => StudentTicketTable(
            //                     //   location: entries[index],
            //                     // ),
            //                     builder: (context) => RaiseTicketForGuardOrAuthorities(
            //                       location: entries[index],
            //                       // TODO: fetch pre_approval_required from backend
            //                       pre_approval_required: pre_approvals[index],
            //                     ),
            //                     // builder: (context) => EnterLocation(
            //                     //       location: entries[index],
            //                     //     )
            //                   )).then((value) => fetchData());
            //             } else {
            //               Navigator.push(
            //                   context,
            //                   MaterialPageRoute(
            //                       builder: (context) => StudentTabs(
            //                         location: entries[index],
            //                         pre_approval_required: pre_approvals[index],
            //                       ))).then((value) => fetchData());
            //             }
            //           },
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.stretch,
            //             children: [
            //               Image.asset(
            //                 'assets/images/library.png',
            //                 height: 150,
            //                 fit: BoxFit.cover,
            //               ),
            //               Padding(
            //                 padding: const EdgeInsets.all(8.0),
            //                 child: Text(
            //                   entries[index],
            //                   style: TextStyle(
            //                     fontSize: 20,
            //                     fontWeight: FontWeight.bold,
            //                     color: Colors.white,
            //                   ),
            //                 ),
            //               ),
            //               Padding(
            //                 padding: const EdgeInsets.all(8.0),
            //                 child: Row(
            //                   children: [
            //                     Text(
            //                       "Status: ${studentStatus[index].toUpperCase()}",
            //                       style: TextStyle(
            //                         fontSize: 16,
            //                         color: Colors.black,
            //                       ),
            //                     ),
            //                     Spacer(),
            //                     Icon(
            //                       Icons.arrow_forward,
            //                       color: Colors.black,
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //     );
            //   },
            // ),
            SizedBox(height: 25),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Scroll horizontally
              child: Row(
                children: List.generate(
                  entries_length,
                  (index) => Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Card(
                      color: Color(0xFFF3F3F3),
                      elevation: 3,
                      child: InkWell(
                        onTap: () {
                          if (pre_approvals[index + 1] == true) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RaiseTicketForGuardOrAuthorities(
                                  location: entries[index + 1],
                                  pre_approval_required:
                                      pre_approvals[index + 1],
                                ),
                              ),
                            ).then((value) => fetchData());
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentTabs(
                                  location: entries[index + 1],
                                  pre_approval_required:
                                      pre_approvals[index + 1],
                                ),
                              ),
                            ).then((value) => fetchData());
                          }
                        },
                        child: SizedBox(
                          width: 170, // Set the width of each card

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width:
                                      150, // Set the desired width of the image
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        10), // Set border radius
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        10), // Set border radius for clipping
                                    child: Image.asset(
                                      show_image(index+1), // Dynamic image path based on entry name
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(3.0),

                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Text(
                                    entries[index + 1],
                                    style: GoogleFonts.mPlusRounded1c(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            "Status",
                                            style: GoogleFonts.mPlusRounded1c(
                                              fontSize: 12,
                                              // fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(
                                              height:
                                                  4), // Add some space between "Status" and its answer
                                          Text(
                                            "${studentStatus[index + 1].toUpperCase()}",
                                            style: GoogleFonts.mPlusRounded1c(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 16.0, 4.0, 0),
                                      child: Icon(
                                        Icons.arrow_forward,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InviteeInfoPage()),
                  );
                },
                child: Text(
                  'Invite Guest',
                  style: GoogleFonts.mPlusRounded1c(
                      fontSize: 20,
                    color:Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6), // Adjust the value as needed
                  ),

                ),
              ),

            ),
          ],
        ),
      ),
    );
  }

  // Function for Popup Menu Items
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
        Navigator.of(context)
            .push(
          MaterialPageRoute(
              builder: (context) => ProfilePage(
                  email: LoggedInDetails.getEmail(), isEditable: false)),
        )
            .then((value) async {
          String? curr_email = widget.email;
          databaseInterface db = databaseInterface();
          User result = await db.get_student_by_email(curr_email);
          pic = result.profileImage;
          updateColor.value = !updateColor.value;
          print(isLoading);
          print(
              "========================================================================================================================================");
        });
        break;
      case MenuItems.itemLogOut:
        LoggedInDetails.setEmail("");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.clear();
        Navigator.of(context).pop(); // pop the current page
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AuthScreen()),
        );
        print("lets logout and notify");
        myglobals.auth!.logout();
        // print(myglobals.auth!.loggedIn);
        break;
      case MenuItems.itemAboutUs:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AboutUsPage()),
        );
        break;
    }
  }
}
