// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:my_gate_app/aboutus.dart';
import 'package:my_gate_app/auth/authscreen.dart';
import 'package:my_gate_app/get_email.dart';
import 'package:my_gate_app/screens/authorities/authority_tabs.dart';
import 'package:my_gate_app/screens/authorities/visitor/authorityVisitor.dart';

import 'package:my_gate_app/screens/profile2/authority_profile/authority_profile_page.dart';
import 'package:my_gate_app/screens/profile2/model/menu_item.dart';
import 'package:my_gate_app/screens/profile2/utils/menu_items.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_gate_app/screens/notificationPage/notification.dart';
import 'package:my_gate_app/database/database_interface.dart';

import 'package:my_gate_app/screens/profile2/utils/user_preferences.dart';

class AuthorityMain extends StatefulWidget {
  const AuthorityMain({super.key});
  // final StriK pre_approval_required;

  @override
  State<AuthorityMain> createState() => _AuthorityMainState();
}

class _AuthorityMainState extends State<AuthorityMain> {
  int notificationCount = 0;
  String welcome_message = "Welcome";

  var user = UserPreferences.myUser;

  late String imagePath;

  var imagePicker;
  var pic;

  Future<void> init() async {
    String? curr_email = LoggedInDetails.getEmail();
    print("Current Email: $curr_email");
    databaseInterface db = databaseInterface();
    // User result = await db.get_student_by_email(curr_email);
    // // print("result obj image path" + result.imagePath);
    // setState(() {
    //   user = result;
    //   imagePath = result.imagePath;
    //   // print("image path inside setstate: " + imagePath);
    // });

    setState(() {
      pic = NetworkImage(imagePath);
    });
    /* print("Gender in yo:"+controller_gender.text); */
  }

  Future<void> get_welcome_message() async {
    String welcome_message_local =
        await databaseInterface.get_welcome_message(LoggedInDetails.getEmail());

    print("welcome_message_local: $welcome_message_local");
    print("studentStatusDB:");
    notificationCount = await databaseInterface
        .return_total_notification_count_guard(LoggedInDetails.getEmail());
    setState(() {
      welcome_message = welcome_message_local;
      print("Going here");
    });
  }

  @override
  void initState() {
    super.initState();
    get_welcome_message();

    imagePath = UserPreferences.myUser.imagePath;
    pic = NetworkImage(imagePath);

    // print("image path in image widget: " + this.imagePath);
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        title: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: ClipOval(
                child: Image(
                  image: pic,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back,',
                    style: TextStyle(
                      color: Color.fromARGB(221, 255, 255, 255),
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Open Sans',
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                    ),
                  ),
                  Text(
                    welcome_message,
                    style: TextStyle(
                      color: Color.fromARGB(221, 247, 247, 247),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Open Sans',
                      fontSize: MediaQuery.of(context).size.width * 0.057,
                    ),
                  ),
                ],
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
                  icon: Icon(Icons.notifications,
                      color: Color.fromARGB(255, 255, 255, 255)),
                  onPressed: () {
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
            icon: Icon(Icons.more_vert,
                color: Color.fromARGB(255, 255, 255, 255)),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.white]),
        ),
        child: Center(
          child: Column(
            // add Column
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Text('Welcome', style: TextStyle( // your text
              //     fontSize: 50.0,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.white)
              // ),
              // RaisedButton(onPressed: () {Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => StudentTicketTable(location: widget.location))
              // );
              // }, child: Text('Raise Ticket for Guard'),
              // ), // your button beneath text
              Image.asset('assets/images/home_authority.jpg'),
              SizedBox(
                height: 100,
              ),
              MaterialButton(
                // Student Tickets
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AuthorityTabs()));
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80.0)),
                padding: EdgeInsets.all(0.0),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      // colors: [Color(0xff374ABE), Color(0xff64B6FF)],
                      colors: [Colors.red, Colors.purple],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Container(
                    constraints:
                        BoxConstraints(maxWidth: 250.0, minHeight: 50.0),
                    alignment: Alignment.center,
                    child: Text(
                      "Student Tickets",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 50),
              MaterialButton(
                // Visitor Tickets
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AuthorityVisitor()));
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80.0)),
                padding: EdgeInsets.all(0.0),
                child: Ink(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.greenAccent, Colors.lightBlueAccent],
                        // colors: [Color(0xff374ABE), Color(0xff64B6FF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(30.0)),
                  child: Container(
                    constraints:
                        BoxConstraints(maxWidth: 250.0, minHeight: 50.0),
                    alignment: Alignment.center,
                    child: Text(
                      "Visitor Tickets",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),

              // RaisedButton(onPressed: () {}, child: Text('Raise Ticket for Authorities'),), // your button beneath text
            ],
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
          MaterialPageRoute(
              builder: (context) =>
                  AuthorityProfilePage(email: LoggedInDetails.getEmail())),
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
