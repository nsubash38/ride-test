// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridetripper/model/User.dart';
import 'package:ridetripper/model/menu.dart';

class Sidebar extends StatefulWidget {
  late List<MenuModel> menuOption;
  Sidebar({required this.menuOption});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final _storage = FlutterSecureStorage();
  User user = User(
      name: "",
      phoneno: 1234,
      user_img:
          "https://firebasestorage.googleapis.com/v0/b/ridetrippermobile.appspot.com/o/blank-profile-picture-973460__340.webp?alt=media&token=cc10d674-f670-4a66-8104-6adc0250f664");

  void getUserInfo() async {
    String? role = await _storage.read(key: "role");
    String? userId = await _storage.read(key: "userID");
    FirebaseFirestore.instance
        .collection(role!)
        .doc(userId)
        .get()
        .then((value) {
      setState(() {
        user = User.fromJsonDriverInfo(value.data() as Map<String, dynamic>);
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              user.name,
              style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              "0"+user.phoneno.toString(),
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.network(
                  user.user_img,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            decoration:  BoxDecoration(
              color: Colors.blue.shade800,
            ),
          ),
          ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.menuOption.length,
              itemBuilder: (menuoption, index) {
                return buildMenuItem(
                  context: context,
                  menuText: widget.menuOption[index].menuName,
                  menuIcon: widget.menuOption[index].menuIcon,
                  goToPage: widget.menuOption[index].goToPage,
                );
              }),
        ],
      ),
    );
  }

  Widget buildMenuItem(
      {required BuildContext context,
      required String menuText,
      required IconData menuIcon,
      required Widget goToPage}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8,5,8,5),
      child: Column(
        children: [
          Container(
            height: 65,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: ListTile(
                leading: Icon(
                  menuIcon,
                  color: Colors.blue.shade800,
                  size: 40,
                ),
                title: Text(
                  menuText,
                  style: TextStyle(fontSize: 22, color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => goToPage),
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
