import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_gate_app/database/database_interface.dart';
import 'package:my_gate_app/screens/profile2/admin_profile/admin_edit_profile_page.dart';
import 'package:my_gate_app/screens/profile2/authority_profile/authority_edit_profile_page.dart';
// import 'package:my_gate_app/screens/profile2/guard_profile/guard_edit_profile_page.dart';
import 'package:my_gate_app/screens/profile2/model/user.dart';
import 'package:my_gate_app/screens/profile2/utils/user_preferences.dart';
import 'package:my_gate_app/screens/profile2/widget/appbar_widget.dart';
import 'package:my_gate_app/screens/profile2/widget/button_widget.dart';
import 'package:my_gate_app/screens/profile2/widget/profile_widget.dart';
import 'package:my_gate_app/screens/profile2/edit_profile_page.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:my_gate_app/screens/profile2/widget/textfield_widget.dart';
import 'package:my_gate_app/get_email.dart';
import 'package:my_gate_app/screens/profile2/model/user.dart';
import 'package:google_fonts/google_fonts.dart';


class AdminProfilePage extends StatefulWidget {
  final String? email;
  const AdminProfilePage({Key? key, required this.email}): super(key: key);
  @override
  _AdminProfilePageState createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  var user = UserPreferences.myAdminUser;

  late String imagePath;

  var imagePicker;
  var pic;

  Future<void> init() async {
    String? curr_email = widget.email;
    print("Current Email: " + curr_email.toString());
    databaseInterface db = new databaseInterface();
    AdminUser result = await db.get_admin_by_email(curr_email);
    setState(() {
      user = result;  
      imagePath = result.imagePath;
      print("Result Name in Profile Page" + result.name);
    });

    setState(() {
      pic = NetworkImage(this.imagePath);
    });
  }
  @override
  void initState(){
    super.initState();
    String? curr_email = widget.email;
    print("Current Email: " + curr_email.toString());
    
    imagePath = UserPreferences.myAdminUser.imagePath;
    pic = NetworkImage(this.imagePath);
    imagePicker = new ImagePicker();

    init(); 
    print("User Name in Profile Page" + user.name);
    
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
          appBar: buildAppBar(context),
          body: Container(
            decoration: BoxDecoration(
              color: Colors.orange.shade100,

              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 0,
                  spreadRadius: 2,
                  offset: Offset(0,3),

                ),

              ],
            ),
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 8),
              physics: BouncingScrollPhysics(),
              children: [
                ImageWidget(),
                const SizedBox(height: 24),
                Container(
                padding: const EdgeInsets.fromLTRB(130, 5, 130, 5),
                child: TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Remove Profile Image?'),
                          content: Text(
                              'Are you sure you want to remove your profile image?'),
                          actions: [
                            TextButton(
                              child: Text('No'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('Yes'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                pick_image_blank();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Center(
                    child: Align(
                      alignment: Alignment.center,
                      child:FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          'Remove profile image',
                          style: GoogleFonts.roboto(
                            fontSize: 15,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
                buildName(user),                
              ],
            ),
          ),
        );
  }

  Widget buildName(AdminUser user) => Column(
        children: [
          Text(
            user.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(color: Colors.black.withOpacity(0.7),
            fontWeight: FontWeight.bold),
          )
        ],
      );

  Widget builText(TextEditingController controller, String label,
          final bool enabled, int maxLines) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(int.parse("0xFF344953"))),
          ),
          const SizedBox(height: 8),
          TextField(
            style: TextStyle(color: Color(int.parse("0xFF344953"))),
            enabled: enabled,
            controller: controller,
            
            decoration: InputDecoration(
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 1.0),
                borderRadius: BorderRadius.circular(12),
              ),
            
              labelStyle: TextStyle(
                color: Color(int.parse("0xFF344953")),
              ),
            ),


            maxLines: maxLines,
          ),
        ],
      );

  Future<void> pick_image() async {
    print("edit profile page image clicked 2");
    var source = ImageSource.gallery;
    XFile image = await imagePicker.pickImage(source: source);
    var widget_email = widget.email;
    if (widget_email!= null){
      await databaseInterface.send_image(image,
          "/admins/change_profile_picture_of_admin", widget_email);
    }

    databaseInterface db = new databaseInterface();
    AdminUser result = await db.get_admin_by_email(widget.email);
    
    var pic_local = await NetworkImage(result.imagePath);
    setState(() {
      pic = pic_local;
    });
  }

  Future<void> pick_image_blank() async {
    print("edit profile page image clicked 2");
    var source = ImageSource.gallery;
    var filePath =
        "assets/images/dummy_person.jpg";
    XFile image = XFile(filePath);;
    var widget_email = widget.email;
    if (widget_email!= null){
      await databaseInterface.send_image(image,
          "/admins/change_profile_picture_of_admin", widget_email);
    }

    databaseInterface db = new databaseInterface();
    AdminUser result = await db.get_admin_by_email(widget.email);
    
    var pic_local = await NetworkImage(result.imagePath);
    setState(() {
      pic = pic_local;
    });
  }

  Widget ImageWidget() {
    return Padding(
      padding: const EdgeInsets.all(9.0),
      child: Center(
        child: Stack(
          children: [
            ClipOval(
              child: Material(
                color: Colors.orangeAccent.shade200,
                child: Ink.image(
                  // image: AssetImage(image),
                  // image: NetworkImage(widget.imagePath),
                  image: pic,
                  fit: BoxFit.cover,
                  width: 180,
                  height: 180,
                  child: InkWell(onTap: () async {
                    pick_image();
                  }),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 4,
              // child: buildEditIcon(Theme.of(context).colorScheme.primary),
              child: buildEditIcon(Color(int.parse("0xFF344953"))),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEditIcon(Color color) => buildCircle(
        color: Colors.white,
        all: 3,
        child: buildCircle(
          color: color,
          all: 8,
          child: Icon(
            Icons.add_a_photo,
            color: Colors.white,
            size: 20,
          ),
        ),
      );

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
}