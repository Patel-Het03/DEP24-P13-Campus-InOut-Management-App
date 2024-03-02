import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:my_gate_app/screens/profile2/themes.dart';

AppBar buildAppBar(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final icon = CupertinoIcons.moon_stars;
  var icon_color = Colors.blue.shade300;
  // var icon_color = Colors.black;
  // if( color == "black"){
  //   icon_color=Colors.black;
  // }
  return AppBar(
    leading: IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
    backgroundColor: Color.fromARGB(255, 0, 0, 0),
    iconTheme: IconThemeData(color: icon_color),
    elevation: 0,
    title: Text(
      'Profile Page',
      style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 255, 255, 255)),
    ),
    centerTitle: true,
  );
}
