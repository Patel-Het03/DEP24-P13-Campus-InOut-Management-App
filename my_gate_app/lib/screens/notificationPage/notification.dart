import 'package:flutter/material.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/get_email.dart';

class NotificationsPage extends StatefulWidget {
  int notificationCount;

  NotificationsPage({super.key, required this.notificationCount});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<List<String>> notifications = [];
  final Set<int> _selectedIndices = <int>{};
  String noti = "";

  @override
  void initState() {
    super.initState();
    getNotifications();
  }

  Future<void> getNotifications() async {
    List<List<String>> messages = await databaseInterface
        .fetch_notification_guard(LoggedInDetails.getEmail());
    setState(() {
      notifications = messages;
    });
  }

  String return_date_time(String datetime) {
    String date = datetime.split('T')[0];
    String time = datetime.split('T')[1];
    time = time.split('.')[0];
    return ("Date = $date , Time = $time");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context,widget.notificationCount);
          },
        ),
        iconTheme: const IconThemeData(
          color: Colors.black, // change the color of the back button here
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Colors.purple, Colors.blue])),
        ),
        // backgroundColor: Color.fromARGB(255, 180, 180, 180),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (BuildContext context, int index) {
            final List<String> notification = notifications[index];
            return ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.notifications),
              ),
              title: Text(
                "From = ${notification[1]}\nLocation = ${notification[2]}\nMessage = ${notification[3]}\nTicket Type = ${notification[5]}",
                style: TextStyle(
                  color: _selectedIndices.contains(index)
                      ? Colors.grey
                      : Colors.black,
                ),
              ),
              subtitle: Text(
                return_date_time(notification[4]),
                style: TextStyle(
                  color: _selectedIndices.contains(index)
                      ? Colors.grey
                      : Colors.black,
                ),
              ),
              trailing: const Icon(Icons.more_vert),
              onTap: () async {
                await databaseInterface.mark_individual_notification(
                    notification[0], LoggedInDetails.getEmail());
                setState(() {
                  if (_selectedIndices.contains(index)) {
                    // _selectedIndices.remove(index);
                  } else {
                    _selectedIndices.add(index);
                    widget.notificationCount--;
                  }
                });
                /* Navigator.pop(context, widget.notificationCount); */
              },
            );
          },
        ),
      ),
    );
  }
}
