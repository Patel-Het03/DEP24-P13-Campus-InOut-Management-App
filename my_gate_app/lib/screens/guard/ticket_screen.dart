import 'package:flutter/material.dart';

class TicketScreen extends StatefulWidget {
  
  const TicketScreen({
    super.key,
    required this.location,
    required this.isApproved,
    required this.enterExit,
    required this.imagePath
  });
  final String location;
  final String isApproved;
  final String enterExit;
  final String imagePath;

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  @override
  Widget build(BuildContext context) {
    return  Container(
        child:Row(
          children: [
              
          ],
        )
    );
  }
}