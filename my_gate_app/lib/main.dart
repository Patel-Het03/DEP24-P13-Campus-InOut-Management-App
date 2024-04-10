// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:my_gate_app/screens/guard/visitors/inviteeValidationPage.dart';
import 'package:my_gate_app/splash.dart';

import 'package:my_gate_app/get_email.dart';
import 'package:my_gate_app/screens/admin/home_admin.dart';
import 'package:my_gate_app/screens/authorities/authority_main.dart';
import 'package:my_gate_app/screens/guard/enter_exit.dart';
import 'package:my_gate_app/screens/student/home_student.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:my_gate_app/screens/guard/visitors/inviteeValidationPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueAccent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent, //use your hex code here
        ),
      ),
      home: FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder:
            (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final SharedPreferences prefs = snapshot.data!;
            final String? type = prefs.getString("type");
            final String? email = prefs.getString("email");
            final String? guardLocation = prefs.getString("guard_location");
            if (type != null) {
              print("type: $type");
            }
            if (type == null) {
              return Splash();
            } else if (type == "Student" && email != null) {
              LoggedInDetails.setEmail(email);
              return HomeStudent(email: LoggedInDetails.getEmail());
            } else if (type == "Authority" && email != null) {
              LoggedInDetails.setEmail(email);
              return AuthorityMain();
            } else if (type == "Admin" && email != null) {
              LoggedInDetails.setEmail(email);
              return HomeAdmin();
            } else if (type == "Guard" && email != null) {
              LoggedInDetails.setEmail(email);
              if (guardLocation != null) {
                return EntryExit(
                  guard_location: guardLocation,
                );
              } else {
                return Splash();
              }
            } else {
              return Splash();
            }
          } else {
            return Splash();  
          }
        },
      ),
      // home: AuthScreen(),
      // home:StreamBuilder(
      //     stream: FirebaseAuth.instance.authStateChanges(),
      //     builder: (context, usersnapshot) {
      //       if (usersnapshot.hasData) {
      //         //return MyHomePage(title: 'Flutter Demo Home Page');
      //         // LoggedInDetails.setEmail(getLoggedInPersonEmail().toString());
      //         return ChooseUser();
      //       } else {
      //         return AuthScreen();
      //       }
      //     }),
      debugShowCheckedModeBanner: false,
    );
    // // return InviteeValidationPage(ticket_id: "ir");
    // return MaterialApp(
    //   home:InviteeValidationPage(ticket_id: "ir")
    // );
  }
}
