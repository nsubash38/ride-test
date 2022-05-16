import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ridetripper/components/Drawer.dart';
import 'package:ridetripper/database/contacts_db.dart';
import 'package:ridetripper/main.dart';
import 'package:ridetripper/model/contactModel.dart';
import 'package:ridetripper/model/menu.dart';
import 'package:ridetripper/pages/ContactUs.dart';
import 'package:ridetripper/pages/SignOut.dart';
import 'package:ridetripper/pages/phoneContact.dart';
import 'package:telephony/telephony.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({Key? key}) : super(key: key);

  @override
  _EmergencyPageState createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  List<ContactModel> contacts = [];
  List<String> recipents = [];
  int? contactsNumber;
  final Telephony telephony = Telephony.instance;
  Position? _currentLocation;
  String? message;
  Timer? timer;
  int i = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshContacts();
    _getUserLocation();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  _getUserLocation() async {
    _currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> newPlace = await placemarkFromCoordinates(
        _currentLocation!.latitude, _currentLocation!.longitude);
    Placemark place = newPlace[0];
    String locationInname = place.name! +
        ", " +
        place.subLocality! +
        ", " +
        place.locality! +
        ", " +
        place.administrativeArea! +
        " " +
        place.postalCode! +
        ", " +
        place.country!;
    setState(() {
      message = "It is an emergency situation.My current location: " +
          locationInname +
          " And Lattitude: " +
          _currentLocation!.latitude.toString() +
          " and Longitude: " +
          _currentLocation!.longitude.toString();
    });
  }

  Future refreshContacts() async {
    this.contacts = await ContactsDatabase.instance.readAllContacts();
    setState(() {
      contactsNumber = contacts.length;
    });
    print(contactsNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Sidebar(
        menuOption: [
          
          MenuModel(
              menuIcon: Icons.home,
              menuName: "Home",
              goToPage: MyApp()),
          MenuModel(
              menuIcon: Icons.contact_phone,
              menuName: "Contact Us",
              goToPage: ContactUs()),
          MenuModel(
              menuIcon: Icons.logout,
              menuName: "Sign Out",
              goToPage: SignOut()),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black, size: 35),
        title: Text("Emergency Call"),
      ),
      body: contactsNumber == 0
          ? Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'There is no contact number',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  ElevatedButton(
                      child: Text("Add Contacts"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PhoneContactList()),
                        );
                      })
                ],
              ),
            )
          : Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PhoneContactList()),
                        );
                    },
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Icon(
                        Icons.add_circle,
                        color: Colors.blue,
                        size: 50,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: contacts.length,
                        itemBuilder: (context, index) {
                          ContactModel contact = contacts[index];

                          recipents.add(contact.phoneNumber);
                          return Dismissible(
                            background: Container(
                              color: Colors.red,
                              child: Container(
                                padding: EdgeInsets.only(top: 20),
                                child: Text("Swipe to Delete",
                                textAlign: TextAlign.right,
                                style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),
                                ),
                              ),
                              ),
                            key: Key(contact.id.toString()),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) async{
                              await ContactsDatabase.instance.delete(contact.id!).then((value) {
                                 Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      contact.contactName + " is removed from emegency list")));
                              });

                             
                            },
                            child: ListTile(
                              title: Text(contact.contactName,style: TextStyle(fontSize: 20),),
                              subtitle: Text(contact.phoneNumber,style: TextStyle(fontSize: 16)),
                              leading: CircleAvatar(
                                child: Text(contact.initials,style: TextStyle(fontSize: 20)),
                              ),
                            ),
                          );
                        }),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        child: Text("Send SMS",style: TextStyle(fontSize: 20),),
                        onPressed: () {
                          _sendSMS(message!, recipents);
                          timer = Timer.periodic(Duration(seconds: 30),
                              (Timer t) => _sendSMS(message!, recipents));
                        },
                      ),
                      ElevatedButton(
                        child: Text("Call 999",style: TextStyle(fontSize: 20),),
                        onPressed: () async {
                          await FlutterPhoneDirectCaller.callNumber(
                              "999");
                        },
                      ),
                      
                    ],
                  )
                ],
              ),
            ),
    );
  }

  void _sendSMS(String message, List<String> recipents) async {
    bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
    if (permissionsGranted!) {
      for (ContactModel contactModel in contacts) {
        telephony.sendSms(to: contactModel.phoneNumber, message: message);
      }
    }
    setState(() {
      i++;
    });
    if (i == 2) {
      timer!.cancel();
    }
  }
}
