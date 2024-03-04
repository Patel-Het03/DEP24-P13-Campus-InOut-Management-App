  // ignore_for_file: non_constant_identifier_names

  import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:my_gate_app/database/database_objects.dart';
  import 'package:my_gate_app/screens/profile2/visitor_profile/visitor_profile_page.dart';
  import 'package:my_gate_app/database/database_interface.dart';
  import 'package:my_gate_app/get_email.dart';

  class PendingAuthorityVisitorTicketTable extends StatefulWidget {
    const PendingAuthorityVisitorTicketTable({Key? key}) : super(key: key);

    @override
    State<PendingAuthorityVisitorTicketTable> createState() =>
        _PendingAuthorityVisitorTicketTableState();
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

  class _PendingAuthorityVisitorTicketTableState
      extends State<PendingAuthorityVisitorTicketTable> {
    List<ResultObj4> tickets_visitors = [];
    List<ResultObj4> filtered_tickets_visitors = [];
    String searchQuery = '';
    List<String> list_of_persons = [];
    bool isFieldEmpty = true;
    FocusNode _focusNode = FocusNode();

    void filterTickets(String query) {
      if (query.isEmpty) {
        filtered_tickets_visitors = tickets_visitors;
      } else {
        filtered_tickets_visitors = tickets_visitors
            .where((ticket) =>
                ticket.visitor_name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    }

    @override
    void dispose() {
      _focusNode.dispose();
      super.dispose();
    }

    void onSearchQueryChanged(String query) {
      setState(() {
        searchQuery = query;
        filterTickets(searchQuery);
      });
    }

    List<Color?> inkColors = [
      Color.fromARGB(255, 45, 44, 42),
      getColorFromHex('f5a6ff'),
      getColorFromHex('f7f554'),
      getColorFromHex('34ebc0'),
      Color.fromARGB(255, 65, 67, 63),
      getColorFromHex('62de72'),
    ];

    Future<List<ResultObj4>> get_pending_visitor_tickets_for_authorities() async {
      print(
          '11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111');
      print(LoggedInDetails.getEmail());
      return await databaseInterface.get_pending_visitor_tickets_for_authorities(
          LoggedInDetails.getEmail());
    }

    List<String> segregrateTickettickets_visitors(List<String> allTickets) {
      List<String> ans = [];

      allTickets.forEach((element) {
        var list = element.split("\n");
        ans.add(list[0]);
      });

      return ans;
    }

    @override
    void initState() {
      super.initState();
      init();
    }

    Future init() async {
      // ignore: unused_local_variable
      var tickets_local = await get_pending_visitor_tickets_for_authorities();

      print("================================================================");
      print(tickets_local);

      // var list_of_persons_local = await databaseInterface.get_list_of_visitors();

      setState(() {
        tickets_visitors = tickets_local;
        print(
            "ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo");
        print(tickets_visitors);
        print(
            "ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo");
        print(tickets_visitors.length);

        // list_of_persons = segregrateTickettickets_visitors(list_of_persons_local);
      });
      filterTickets(searchQuery);
    }

    @override
    Widget build(BuildContext context) {
      return Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) {
          // Unfocus the TextField when clicked outside
          if (_focusNode.hasFocus) {
            _focusNode.unfocus();
          }
        },
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.white]),
            ),
            // color: Colors.bla,
            child: Column(
              children: [
                SizedBox(
                  height: 8,
                ),
                SizedBox(
                  // height: MediaQuery.of(context).size.height / 100,
                  width: MediaQuery.of(context).size.width / 1.25,
                  child: InputDecorator(
                    isEmpty: isFieldEmpty, // if true, the hint text is shown
                    decoration: InputDecoration(
                      hintText: '    Search by Name',
                      hintStyle: TextStyle(
                          color: Color.fromARGB(255, 96, 96,
                              96)), // Set the desired color for the hint text
                    ),

                    child: TextField(
                      focusNode: _focusNode,
                      style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      decoration: InputDecoration(
                        // labelText: "Name",
                        // hintText: "Enter name to filter tickets",
                        // hintStyle: TextStyle(color: Colors.grey),
                        // helperText: "Enter name to filter tickets",
                        // helperStyle: TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color.fromARGB(255, 29, 40, 204)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 36, 0, 108),
                            width: 2.0,
                          ),
                        ),
                      ),
                      onChanged: (text) {
                        isFieldEmpty = text.isEmpty;

                        onSearchQueryChanged(text);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 2.5 / 1,
                    ),
                    itemCount: filtered_tickets_visitors.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VisitorProfilePage(
                                        visitorObject:
                                            filtered_tickets_visitors[index],
                                        isEditable: true,
                                      ))).then((result) {
                            init();
                          });
                        },
                        child: Container(
                          height: 10,
                          width: 40,
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white, // Set white background color
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            border: Border.all(color: Colors.black),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(
                                    0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              FittedBox(
                                child: Container(
                                  margin: const EdgeInsets.all(20),
                                  height: 20,
                                ),
                                fit: BoxFit.fill,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        '${filtered_tickets_visitors[index].visitor_name}',
                                        style: GoogleFonts.roboto(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(255, 0, 98, 255),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        '${filtered_tickets_visitors[index].mobile_no}',
                                        style: GoogleFonts.roboto(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(255, 0, 98, 255),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        '\n${filtered_tickets_visitors[index].date_time_of_ticket_raised.split('T')[0]}',
                                        style: GoogleFonts.roboto(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Color.fromARGB(255, 102, 102, 102),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.arrow_right,
                                color: Colors.lightBlue,
                                size: 50.0,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }