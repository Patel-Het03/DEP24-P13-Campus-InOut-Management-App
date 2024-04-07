import 'package:flutter/material.dart';

class InviteeValidationPage extends StatefulWidget {
  final String ticket_id;
  const InviteeValidationPage({super.key,required this.ticket_id});

  @override
  State<InviteeValidationPage> createState() => _InviteeValidationPageState();
}

class _InviteeValidationPageState extends State<InviteeValidationPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child:Text("ticket_id ${widget.ticket_id}")
    );
  }
}