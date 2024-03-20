// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class TextBoxCustom extends StatelessWidget {
  TextBoxCustom({
    super.key,
    required this.labelText,
    this.onSavedFunction,
    required this.icon,
    this.form_key,
    this.onChangedFunction,
  });
  void Function(String?)? onSavedFunction;
  void Function(String?)? onChangedFunction;
  String labelText;
  Icon icon;
  Key? form_key;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textTheme: TextTheme(titleMedium: TextStyle(color: Colors.black)),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.72,
        height: 50.0, // Adjust the height as needed
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
        ),
        child: Form(
          key: form_key,
          child: TextFormField(
            keyboardType: TextInputType.emailAddress,
            key: const ValueKey('username'),
            // how does this work?
            validator: (value) {
              if (value!.isEmpty) {
                return '$labelText is empty';
              }
              return null;
            },
            onSaved: onSavedFunction,
            onChanged: onChangedFunction,
            decoration: InputDecoration(
                prefixStyle: TextStyle(color: Colors.black),

                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      border: InputBorder.none,
                      hintText: labelText,
                      hintStyle: GoogleFonts.lato(color: Colors.grey),
                prefixIcon: icon,
                
               
                ),
          ),
        ),
      ),
    );
  }
}
