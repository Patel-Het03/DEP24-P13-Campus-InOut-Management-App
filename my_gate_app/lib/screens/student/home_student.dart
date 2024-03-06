// ignore_for_file: prefer_const_constructors, unnecessary_brace_in_string_interps, unnecessary_string_interpolations, non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/aboutus.dart';
import 'package:my_gate_app/auth/authscreen.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/get_email.dart';
import 'package:my_gate_app/screens/profile2/profile_page.dart';
import 'package:my_gate_app/screens/profile2/profile_page_2.dart';
import 'package:my_gate_app/screens/student/raise_ticket_for_guard_or_authorities.dart';
import 'package:my_gate_app/screens/profile2/model/menu_item.dart';
import 'package:my_gate_app/screens/profile2/utils/menu_items.dart';
import 'package:my_gate_app/screens/student/student_guard_side/student_tabs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';

import 'package:my_gate_app/screens/profile2/model/user.dart';
import 'package:my_gate_app/screens/profile2/utils/user_preferences.dart';
import 'package:my_gate_app/screens/notificationPage/notification.dart';

// This file calls StudentTicketTable

class HomeStudent extends StatefulWidget {
  final String? email;
  const HomeStudent({Key? key, required this.email}) : super(key: key);

  @override
  _HomeStudentState createState() => _HomeStudentState();
}

Color getColorFromHex(String hexColor) {
  hexColor = hexColor.replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
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
    print("Current Email: " + curr_email.toString());
    databaseInterface db = new databaseInterface();
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
    print("welcome_message_local: " + welcome_message_local);
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

  Widget show_image(int index) {
    if (index < 6) {
      return Image.asset(location_images_paths[index]);
    }
    return Image.asset('assets/images/library.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
        shape: RoundedRectangleBorder(),
        centerTitle: true,
        title: Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.1,
              height: MediaQuery.of(context).size.width * 0.1,
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
            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
            Expanded(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.width * 0.022),
                    Text(
                      'Welcome Back,',
                      style: GoogleFonts.poppins(
                        color: Color.fromARGB(221, 255, 255, 255),
                        fontWeight: FontWeight.w900,
                        fontSize: MediaQuery.of(context).size.width * 0.025,
                      ),
                    ),
                    Text(
                      '${welcome_message}',
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      style: GoogleFonts.poppins(
                        color: Color.fromARGB(221, 255, 255, 255),
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.045,
                      ),
                    ),
                  ],
                ),
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
                  icon: Icon(
                    Icons.notifications,
                    color: Color.fromARGB(255, 255, 255, 255),
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
                                color: Colors.red,
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
              ),
            ],
          ),
          PopupMenuButton<MenuItem>(
            onSelected: (item) => onSelected(context, item),
            icon: Icon(
              Icons.more_vert,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            itemBuilder: (context) => [
              ...MenuItems.itemsFirst.map(buildItem).toList(),
              PopupMenuDivider(),
              ...MenuItems.itemsThird.map(buildItem).toList(),
              PopupMenuDivider(),
              ...MenuItems.itemsSecond.map(buildItem).toList(),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            // padding: EdgeInsets.only(top: 30.0),
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 232, 232, 234),
                    Color.fromARGB(255, 255, 255, 255)
                  ]),
            ),
            // color: Colors.bla,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                // MediaQuery.of(context).orientation == Orientation.landscape
                //     ? 3
                //     : 2,
                //crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                // childAspectRatio: (1.2 / 1),
                childAspectRatio: 1.0,
                // crossAxisSpacing: 100,
                // mainAxisSpacing: 100,
                // crossAxisCount: 2,
              ),
              //primary: false,
              //padding: const EdgeInsets.all(20),
              //crossAxisSpacing: 10,
              //mainAxisSpacing: 2,

              itemCount: entries.length,
              itemBuilder: (BuildContext context, int index) {
                // default to 0 if data is null
                return InkWell(
                  onTap: () {
                    // print("Email fetched from our own function: " + LoggedInDetails.getEmail());
                    if (pre_approvals[index] == true) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            // builder: (context) => StudentTicketTable(
                            //   location: entries[index],
                            // ),
                            builder: (context) =>
                                RaiseTicketForGuardOrAuthorities(
                              location: entries[index],
                              // TODO: fetch pre_approval_required from backend
                              pre_approval_required: pre_approvals[index],
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
                                    location: entries[index],
                                    pre_approval_required: pre_approvals[index],
                                  ))).then((value) => fetchData());
                    }
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.02,
                    width: MediaQuery.of(context).size.height * 0.02,
                    //margin: EdgeInsets.only(bottom: 20),
                    margin: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                          // color: inkColors[index % inkColors.length].withOpacity(0.5),
                          color: Colors.grey.withOpacity(0.6),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    // decoration: BoxDecoration(
                    //   shape: BoxShape.rectangle,
                    //   color: Colors.blue[100 * (index % 3 + 1)],
                    //   borderRadius: BorderRadius.circular(20),
                    // ),
                    //color: Colors.amber[colorCodes[index]],
                    child: Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.03,
                        ),

                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.width * 0.01,
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    '  ${entries[index]}',
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                    style: GoogleFonts.poppins(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              // Center(children )
                              Center(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.01),
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.19,

                                        // child: Image.asset(location_images_paths[index]),
                                        child: show_image(index),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.002,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: studentStatus[index]
                                                        .toLowerCase() ==
                                                    "out"
                                                ? Colors.red
                                                : Colors.green,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.03,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.01,
                                          ),
                                          Text(
                                            "Status: " +
                                                studentStatus[index]
                                                    .toUpperCase(),
                                            style: GoogleFonts.poppins(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.03,
                                              fontWeight: FontWeight.normal,
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.person,
                                            color: Colors.lightBlue,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.03,
                                          ),
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.01),
                                          Text(
                                            "In Count: ${in_count[index]}",
                                            style: GoogleFonts.roboto(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.03,
                                              fontWeight: FontWeight.normal,
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.01,
                                      ),
                                    ]),
                              )
                            ],
                          ),
                        ),
                        // Spacer(),
                        // Icon(
                        //   Icons.arrow_right,
                        //   color: Colors.lightBlue,
                        //   size: 50.0,
                        // ),
                      ],
                    ),
                  ),
                );
              },
              // separatorBuilder: (BuildContext context, int index) =>
              //     const Divider(),
            ),
          ),
          // ValueListenableBuilder<bool>(
          //   valueListenable: isLoading,
          //   builder: (context, BisLoading, child) {
          //     return Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         isLoading.value
          //             ? Center(
          //                 child: CircularProgressIndicator(),
          //               )
          //             : Container(),

          //         // rest of the code
          //       ],
          //     );
          //   },
          // ),
        ],
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
          databaseInterface db = new databaseInterface();
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
        break;
        case MenuItems.itemAboutUs:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AboutUsPage()),
        );
        break;
    }
  }
}
