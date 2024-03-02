import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
        backgroundColor:
            Color.fromARGB(255, 0, 0, 0), // Set the background color to white
        iconTheme: IconThemeData(
            color: Color.fromARGB(
                255, 255, 255, 255)), // Set the icon color to black
      ),
      body: Container(
        color: Colors.white, // Set the background color to white
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/IIT_Ropar.png',
              width: 200,
              height: 200,
            ),
            SizedBox(height: 16.0),
            Text(
              'About Campus-InOutMgmt',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Set the text color to black
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'This app is developed as part of our DEP course project to manage entry and exit in campus locations. It helps streamline the process and ensure the safety and security of everyone on campus.',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black), // Set the text color to black
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () async {
                    // Handle the action when "Privacy Policy" is clicked
                    await launchUrlString(
                        'https://sites.google.com/view/goyalpuneet/campus-inoutmgmt');
                  },
                  child: Text(
                    'Contributors',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    // Handle the action when "Privacy Policy" is clicked
                    await launchUrlString(
                        'https://campusinoutmgmt.blogspot.com/2023/05/campus-inoutmgmt.html');
                  },
                  child: Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
