import 'package:flutter/material.dart';
import 'package:my_gate_app/screens/guard/visitors/oldVisitorsSearch.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/screens/guard/visitors/visitors_tabs_controller.dart';

class selectVisitor extends StatefulWidget {
  @override
  _selectVisitorState createState() => _selectVisitorState();
}

class _selectVisitorState extends State<selectVisitor> {
  String _name = "";
  String _phoneNumber = "";

  List<User> _users = [];

  List<User> searchUsers(String name, String phoneNumber) {
    return _users
        .where((user) =>
            user.name.toLowerCase().contains(name.toLowerCase()) &&
            user.phoneNumber.contains(phoneNumber))
        .toList();
  }

  User? _selectedUser;

  void getUsers() async {
    List<String> visitorList = await databaseInterface.get_list_of_visitors();
    print("ooooooooooooooooooooooooooooooooooooooooooooooo");
    print(visitorList);
    print("ooooooooooooooooooooooooooooooooooooooooooooooo");
    List<User> userList = visitorList.map((visitorString) {
      List<String> parts = visitorString.split(',');
      return User(
        id: int.parse(parts[2]),
        name: parts[1].trim(),
        phoneNumber: parts[0].trim(),
      );
    }).toList();
    setState(() {
      _users = userList;
    });
  }

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 180, 180, 180),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[Colors.purple, Colors.blue])),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Search/Add Visitor',
              style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width / 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              decoration: InputDecoration(labelText: "Name"),
              onChanged: (value) {
                setState(() {
                  _name = value;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: "Phone Number"),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _phoneNumber = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            Text("Search Results:"),
            Expanded(
              child: ListView.builder(
                itemCount: (_name.isEmpty && _phoneNumber.isEmpty)
                    ? 0
                    : searchUsers(_name, _phoneNumber).length.clamp(0, 4),
                itemBuilder: (context, index) {
                  final user = searchUsers(_name, _phoneNumber)[index];
                  return ListTile(
                    title: Text(user.name),
                    subtitle: Text(user.phoneNumber),
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VisitorsTabs(
                            username: user.name,
                            userid: user.id,
                            phonenumber: user.phoneNumber,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_name.isNotEmpty && _phoneNumber.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VisitorsTabs(
                        username: _name,
                        phonenumber: _phoneNumber,
                      ),
                    ),
                  ).then((value) => initState());
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(
                          "Name/Phone number fields required for adding new visitor."),
                      action: SnackBarAction(
                        label: "OK",
                        onPressed: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        },
                      ),
                    ),
                  );
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 8.0),
                  Text("New User"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class User {
  final int id;
  final String name;
  final String phoneNumber;

  User({required this.id, required this.name, required this.phoneNumber});
}
