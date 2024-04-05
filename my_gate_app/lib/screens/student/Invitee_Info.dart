import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/database/database_objects.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_gate_app/get_email.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';
// import 'package:my_gate_app/screens/guard/utils/UI_statics.dart'; // Import necessary dependencies
import 'package:share_plus/share_plus.dart' as myshare;
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'dart:io';
import 'dart:ui';



class InviteeInfoPage extends StatefulWidget {
  const InviteeInfoPage({Key? key}) : super(key: key);

  @override
  _InviteeInfoPageState createState() => _InviteeInfoPageState();
}

class _InviteeInfoPageState extends State<InviteeInfoPage> with SingleTickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 8,
        title: Text(
          'Invitee Info',
          style: GoogleFonts.mPlusRounded1c(color: Colors.black, fontWeight: FontWeight.w900),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        bottom: TabBar(
          controller: controller,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              width: 4,
              color: Colors.black,
            ),
          ),
          labelStyle: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w800
          ),
          unselectedLabelStyle: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w800
          ),
          tabs:  [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_circle),
                  SizedBox(width: 10),
                  Text(
                    'Form',
                    style: GoogleFonts.mPlusRounded1c(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history),
                  SizedBox(width: 10),
                  Text(
                    'Status',
                    style: GoogleFonts.mPlusRounded1c(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.black,
        child: TabBarView(
          controller: controller,
          children: [
            InviteeForm(),
            InviteeStatus(),
          ],
        ),
      ),
    ),
  );
}

class InviteeForm extends StatefulWidget {
  @override
  _InviteeFormState createState() => _InviteeFormState();
}

class _InviteeFormState extends State<InviteeForm> {
  final _formKey = GlobalKey<FormState>(); // Key for the form

  String _name = '';
  String _relationship = '';
  String _contact = '';
  String _purpose = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      // appBar: AppBar(
      //   title: Text('Invitee Form', style: GoogleFonts.mPlusRounded1c(color: Colors.black)), // Set app bar title color to black
      //   backgroundColor: Colors.white, // Set app bar background color to white
      // ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,

          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: GoogleFonts.mPlusRounded1c(color: Colors.black), // Set label text color to black using Google Fonts
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black), // Set bottom border color to black
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black), // Set bottom border color to black when focused
                    ),



                  ),
                  style: GoogleFonts.mPlusRounded1c(color: Colors.black,fontWeight: FontWeight.bold), // Set input text color to black using Google Fonts
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _name = value!;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Relationship',
                    labelStyle: GoogleFonts.mPlusRounded1c(color: Colors.black), // Set label text color to black using Google Fonts
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black), // Set bottom border color to black
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black), // Set bottom border color to black when focused
                    ),
                  ),
                  style: GoogleFonts.mPlusRounded1c(color: Colors.black,fontWeight: FontWeight.bold), // Set input text color to black using Google Fonts
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the relationship';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _relationship = value!;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Contact',
                    labelStyle: GoogleFonts.mPlusRounded1c(color: Colors.black), // Set label text color to black using Google Fonts
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black), // Set bottom border color to black
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black), // Set bottom border color to black when focused
                    ),
                  ),
                  style: GoogleFonts.mPlusRounded1c(color: Colors.black,fontWeight: FontWeight.bold), // Set input text color to black using Google Fonts
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the contact';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _contact = value!;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Purpose to Invite',
                    labelStyle: GoogleFonts.mPlusRounded1c(color: Colors.black), // Set label text color to black using Google Fonts
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black), // Set bottom border color to black
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black), // Set bottom border color to black when focused
                    ),
                  ),
                  style: GoogleFonts.mPlusRounded1c(color: Colors.black,fontWeight: FontWeight.bold), // Set input text color to black using Google Fonts
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the purpose to invite';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _purpose = value!;
                  },
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async{
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Submit your form data here
                      print(
                          'Name: $_name, Relationship: $_relationship, Contact: $_contact, Purpose: $_purpose');
                      databaseInterface db=new databaseInterface();
                      String email = LoggedInDetails.getEmail();
                      // Find the index of the "@" symbol
                      int atIndex = email.indexOf('@');
            
                      // Extract the substring before the "@" symbol
                      String extracted = email.substring(0, atIndex);
            
                      String extractedStudent=extracted.toUpperCase();
                      print(extractedStudent);
                      int statusCode;
                      statusCode= await  db.GenerateRelativesTicket(
                        extractedStudent,
                         _name,
                        _relationship,
                        _contact,
                        _purpose,
                      );
                      if(statusCode==200){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Request Raised Sucessfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        _formKey.currentState!.reset();
                      }
                      else if(statusCode==500){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Request hasn\'t been submitted.\nError In Backend'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
            
                    }
                  },
                  child: Center(
                    child: Text(
                        'Submit',
                      style: GoogleFonts.mPlusRounded1c(
                        fontSize: 15,
                        color:Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.black), // Set button background color to black
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class InviteeStatus extends StatefulWidget {
  @override
  _InviteeStatusState createState() => _InviteeStatusState();
}

class _InviteeStatusState extends State<InviteeStatus> {
  String searchQuery = '';
  List<RelativeResultObj> tickets = []; // Define necessary variables
  List<RelativeResultObj> ticketsFiltered = [];
  int selectedIndex = -1; // Define selectedIndex variable

  @override
  void initState() {
    super.initState();
    // tickets = _generateDummyData(); // Initialize tickets with dummy data
    // ticketsFiltered = List.from(tickets);
    // print("hhhhelllo");
    _fetchTickets();
  }
  Future<void> _fetchTickets() async {
    try {
      String email = LoggedInDetails.getEmail();
      // Find the index of the "@" symbol
      int atIndex = email.indexOf('@');

      // Extract the substring before the "@" symbol
      String extracted = email.substring(0, atIndex);

      String extractedStudent=extracted.toUpperCase();
      databaseInterface db=new databaseInterface();

      List<RelativeResultObj> fetchedTickets = await db.GetStudentRelativeTickets(extractedStudent);
      setState(() {
        tickets = fetchedTickets;
        ticketsFiltered = List.from(tickets);
      });
    } catch (e) {
      print("Error fetching tickets: $e");
      // Handle error accordingly
    }
  }

  void toggleExpansion(int index) {
    setState(() {
      if (selectedIndex == index) {
        selectedIndex = -1; // Collapse if already expanded
      } else {
        selectedIndex = index; // Expand if not expanded
      }
    });
  }
  Future<File?> generateQrCode(String dataToGenerate) async {
    final qrValidationResult = QrValidator.validate(
      data: dataToGenerate,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );






    if (qrValidationResult.isValid) {
      final QrCode? qrCode = qrValidationResult.qrCode;
      final QrPainter qrPainter = QrPainter.withQr(
        qr: qrCode!,
        color:Colors.blue,
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
        ),


      );
      final ByteData? bytes = await qrPainter.toImageData(
        200,
        format: ImageByteFormat.png,
      );

      if (bytes == null) {
        // Handle this block the way you want
        return null;
      }

      final Directory tempDir = await getTemporaryDirectory();
      final File tempQrFile = await File('${tempDir.path}/qr.jpg').create();
      final Uint8List list = bytes.buffer.asUint8List();

      await tempQrFile.writeAsBytes(list);
      return tempQrFile;
    }
    return null;
  }
  Future<void> shareQrCode(String url) async {
    final file = await generateQrCode(url);

    if (file != null) {
      print("sharing QR");
      print("${file.path}");

      await myshare.Share.shareXFiles([myshare.XFile(file.path, mimeType: "image/jpg")]);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          // Implement UI for displaying tickets here
          Expanded(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              child: ListView.builder(
                itemCount: ticketsFiltered.length,
                itemBuilder: (BuildContext context, int index) {
                  final bool isExpanded = index == selectedIndex;
                  return Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xff3E3E3E),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            title: Row(
                              children: [
                                Text(
                                  ticketsFiltered[index].name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (ticketsFiltered[index].status == "Accepted")
                                  IconButton(
                                    icon: Icon(Icons.qr_code),
                                    onPressed: () {
                                      // Show modal bottom sheet with QR code
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Container(
                                            color: Colors.transparent,
                                            child: Container(
                                              padding: EdgeInsets.all(16.0),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: const Radius.circular(10),
                                                  topRight: const Radius.circular(10),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  QrImageView(
                                                    data: "Hello",
                                                    backgroundColor: Colors.white,
                                                    size: 200,
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    'Share this QR code with your guest.',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  SizedBox(height: 16), // Added some space
                                                  ElevatedButton.icon(
                                                    onPressed: () {
                                                      // Implement sharing functionality
                                                      shareQrCode('Your invitee details here'); // Replace with actual invitee details
                                                    },
                                                    icon: Icon(
                                                      Icons.share,
                                                      color: Colors.white
                                                    ),
                                                    label: Text(
                                                        'Share',
                                                      style: TextStyle(color: Colors.white),
                                                    ),
                                                  ),

                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                              ],
                            ),
                            subtitle: isExpanded
                                ? Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8),
                                Text(
                                  'Status: ${ticketsFiltered[index].status}',
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Mobile Number: ${ticketsFiltered[index].mobileNumber}',
                                ),
                                // Add more details here as needed
                              ],
                            )
                                : null,
                            onTap: () => toggleExpansion(index),
                            trailing: Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
