import 'dart:core';
import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:flutter/services.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ridetripper/model/User.dart';
import 'package:ridetripper/model/menu.dart';
import 'package:ridetripper/pages/ContactUs.dart';
import 'package:ridetripper/pages/Emergency.dart';
import 'package:ridetripper/pages/GoogleMap.dart';
import 'package:ridetripper/pages/MapPage.dart';
import 'package:ridetripper/pages/RequestTrip.dart';
import 'package:ridetripper/pages/SignOut.dart';
import 'package:ridetripper/pages/UpcomingPage.dart';
import 'package:ridetripper/pages/VehicleRegitration.dart';
import 'package:ridetripper/service/notificationservice.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart' as osm;

import '../components/Drawer.dart';

class DriverNewTrip extends StatefulWidget {
  const DriverNewTrip({Key? key}) : super(key: key);

  @override
  _DriverNewTripState createState() => _DriverNewTripState();
}

class _DriverNewTripState extends State<DriverNewTrip> {
  List dropdownItemList = [];

  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _sLoc = TextEditingController();
  TextEditingController _eLoc = TextEditingController();
  TextEditingController numSeats = TextEditingController();
  dynamic vType;
  bool isBike = true;
  SearchInfo sSearchInfo = SearchInfo();
  SearchInfo eSearchInfo = SearchInfo();
  final _storage = FlutterSecureStorage();
  late User user;

  void getVehicleList() async {
    FirebaseFirestore.instance
        .collection("driver")
        .doc(await _storage.read(key: "userID"))
        .get()
        .then((value) {
      setState(() {
        user = User.fromJson(value.data()!);
        user.vehicleList!.forEach((element) {
          final vehicleList = {
            'label':
                element["vehicle_type"] + " | " + element["vehicle_number"],
            'value': element["vehicle_type"] + "," + element["vehicle_number"]
          };
          dropdownItemList.add(vehicleList);
        });
      });
    });
  }

  handleTripConfirm() {
    if (sSearchInfo.address == null ||
        eSearchInfo.address == null ||
        numSeats.text.isEmpty ||
        _dateController.text.isEmpty ||
        _timeController.text.isEmpty ||
        vType == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Field Cannot be Empty')));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MapPage(
                  sLatlng: sSearchInfo,
                  eLatlng: eSearchInfo,
                  nSeats: int.parse(numSeats.text),
                  sDate: _dateController.text,
                  sTime: _timeController.text,
                  vType: vType["value"],
                  user: user,
                )),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getVehicleList();
    LocalNotificationService.BFDNotification(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: Sidebar(
        menuOption: [
          MenuModel(
              menuIcon: Icons.tour_outlined,
              menuName: "Upcoming Trip",
              goToPage: DriverUpcoming()),
          MenuModel(
              menuIcon: Icons.request_page,
              menuName: "Requested Trip",
              goToPage: DriverRequestTrip()),
          MenuModel(
              menuIcon: Icons.local_taxi,
              menuName: "New Vehicle",
              goToPage: NewVehicleRegistration()),
          MenuModel(
              menuIcon: Icons.taxi_alert,
              menuName: "Emergency",
              goToPage: EmergencyPage()),
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
        centerTitle: true,
        title: Text(
          "Go",
          style: GoogleFonts.dancingScript(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.blue.shade800),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black, size: 35),
      ),
      body: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height -
              AppBar().preferredSize.height,
          maxWidth: MediaQuery.of(context).size.width,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 15, 0, 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Trip Infomation",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w800),
                    )
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(22),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final SearchInfo result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MapScreen()),
                          );
                          setState(() {
                            sSearchInfo = result;
                            _sLoc.text = result.address.toString();
                          });
                        },
                        child: TextField(
                          enabled: false,
                          controller: _sLoc,
                          keyboardType: TextInputType.text,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                              labelText: "Starting Location",
                              labelStyle:
                                  TextStyle(color: Colors.grey.shade800),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              prefixIcon: Icon(
                                Icons.not_listed_location,
                                size: 35.0,
                                color: Colors.blue.shade800,
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () async {
                          final SearchInfo result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MapScreen()),
                          );
                          setState(() {
                            eSearchInfo = result;
                            _eLoc.text = result.address.toString();
                          });
                        },
                        child: TextField(
                          enabled: false,
                          controller: _eLoc,
                          keyboardType: TextInputType.text,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            labelText: "Where To?",
                            labelStyle: TextStyle(color: Colors.grey.shade800),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            prefixIcon: Icon(
                              Icons.not_listed_location,
                              size: 35.0,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () => pickDate(context, _dateController),
                        child: TextField(
                          keyboardType: TextInputType.text,
                          controller: _dateController,
                          enabled: false,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              labelText: "Starting Date",
                              labelStyle:
                                  TextStyle(color: Colors.grey.shade800),
                              fillColor: Colors.grey.shade200,
                              prefixIcon: Icon(
                                Icons.date_range,
                                size: 35,
                                color: Colors.blue.shade800,
                              )),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () => pickTime(context, _timeController),
                        child: TextField(
                          keyboardType: TextInputType.text,
                          controller: _timeController,
                          style: TextStyle(fontSize: 20),
                          enabled: false,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            labelText: "Starting Time",
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            labelStyle: TextStyle(color: Colors.grey.shade800),
                            prefixIcon: Icon(
                              Icons.timer,
                              size: 35.0,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.local_taxi,
                              size: 35,
                              color: Colors.blue.shade800,
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            CoolDropdown(
                              selectedItemTS:
                                  TextStyle(color: Colors.blue, fontSize: 14),
                              dropdownList: dropdownItemList,
                              dropdownHeight: 250,
                              onChange: (e) {
                                vType = e;
                                print(e);
                                if (vType["value"]
                                    .toString()
                                    .startsWith("Bike")) {
                                  setState(() {
                                    isBike = false;
                                  });
                                  numSeats.text = "1";
                                } else {
                                  setState(() {
                                    isBike = true;
                                  });
                                }
                              },
                              resultWidth: 273,
                              placeholder: "Select Vehicle",
                              resultBD: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              iconSize: 20,
                              placeholderTS: TextStyle(
                                  color: Colors.grey.shade800, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        enabled: isBike,
                        controller: numSeats,
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                            labelText: "Number of Seats",
                            labelStyle: TextStyle(color: Colors.grey.shade800),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            prefixIcon: Icon(
                              Icons.event_seat,
                              size: 35.0,
                              color: Colors.blue.shade800,
                            )),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Container(
                        width: double.infinity,
                        child: RaisedButton(
                          onPressed: () {
                            handleTripConfirm();
                          },
                          color: Colors.blue.shade600,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              "Confirm Trip",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RiderSearchTrip extends StatefulWidget {
  const RiderSearchTrip({Key? key}) : super(key: key);

  @override
  _RiderSearchTripState createState() => _RiderSearchTripState();
}

class _RiderSearchTripState extends State<RiderSearchTrip> {
  List dropdownItemList = [
    {'label': '1', 'value': '1'},
    {'label': '2', 'value': '2'},
    {'label': '3', 'value': '3'},
    {'label': '4', 'value': '4'},
    {'label': '5', 'value': '5'},
  ];
  TextEditingController _dateController = TextEditingController();
  TextEditingController _sLoc = TextEditingController();
  TextEditingController _eLoc = TextEditingController();
  dynamic numSeats;

  SearchInfo sSearchInfo = SearchInfo();
  SearchInfo eSearchInfo = SearchInfo();

  handleSearch() {
    if (sSearchInfo.address == null ||
        eSearchInfo.address == null ||
        numSeats == null ||
        _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Field Cannot be Empty')));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MapPage(
                  sLatlng: sSearchInfo,
                  eLatlng: eSearchInfo,
                  nSeats: int.parse(numSeats["value"]),
                  sDate: _dateController.text,
                )),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    LocalNotificationService.BFDNotification(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: Sidebar(
        menuOption: [
          MenuModel(
              menuIcon: Icons.tour_outlined,
              menuName: "Upcoming Trip",
              goToPage: RiderUpcomingPage()),
          MenuModel(
              menuIcon: Icons.request_page,
              menuName: "Requested Trip",
              goToPage: RiderRequestTrip()),
          MenuModel(
              menuIcon: Icons.taxi_alert,
              menuName: "Emergency",
              goToPage: EmergencyPage()),
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
        centerTitle: true,
        title: Text(
          "Go",
          style: GoogleFonts.dancingScript(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.blue.shade800),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black, size: 35),
      ),
      body: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height -
              AppBar().preferredSize.height,
          maxWidth: MediaQuery.of(context).size.width,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Search Trip",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w800),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final SearchInfo result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MapScreen()),
                          );
                          setState(() {
                            sSearchInfo = result;
                            _sLoc.text = result.address.toString();
                          });
                        },
                        child: TextField(
                          enabled: false,
                          controller: _sLoc,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                              labelText: "PickUp  Location",
                              labelStyle:
                                  TextStyle(color: Colors.grey.shade800),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              prefixIcon: Icon(
                                Icons.not_listed_location,
                                size: 35.0,
                                color: Colors.blue.shade800,
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      GestureDetector(
                        onTap: () async {
                          final SearchInfo result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MapScreen()),
                          );
                          setState(() {
                            eSearchInfo = result;
                            _eLoc.text = result.address.toString();
                          });
                        },
                        child: TextField(
                          enabled: false,
                          controller: _eLoc,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            labelText: "Where To?",
                            labelStyle: TextStyle(color: Colors.grey.shade800),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            prefixIcon: Icon(
                              Icons.not_listed_location,
                              size: 35.0,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      GestureDetector(
                        onTap: () => pickDate(context, _dateController),
                        child: TextField(
                          keyboardType: TextInputType.text,
                          controller: _dateController,
                          style: TextStyle(fontSize: 20),
                          enabled: false,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              hintText: "Starting Date",
                              hintStyle: TextStyle(color: Colors.grey.shade800),
                              fillColor: Colors.grey.shade200,
                              prefixIcon: Icon(
                                Icons.date_range,
                                size: 35.0,
                                color: Colors.blue.shade800,
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.event_seat,
                              size: 35,
                              color: Colors.blue.shade800,
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            CoolDropdown(
                              selectedItemTS:
                                  TextStyle(color: Colors.blue, fontSize: 14),
                              dropdownList: dropdownItemList,
                              onChange: (e) {
                                numSeats = e;
                              },
                              resultWidth: 250,
                              placeholder: "Number Of Seats",
                              resultBD: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              iconSize: 20,
                              placeholderTS: TextStyle(
                                  color: Colors.grey.shade800, fontSize: 20),
                              // placeholder: 'insert...',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        width: double.infinity,
                        child: RaisedButton(
                          onPressed: () {
                            handleSearch();
                          },
                          color: Colors.blue.shade600,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              "Search Trip",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future pickDate(BuildContext context, TextEditingController controller) async {
  final initialDate = DateTime.now();
  final newDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate:
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    lastDate: DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day + 30),
  );

  String value;

  if (newDate == null) {
    value = "Starting Date";
  } else {
    value = DateFormat("dd-MM-yyyy").format(newDate);
  }

  controller.text = value;
}

Future pickTime(BuildContext context, TextEditingController controller) async {
  final initialTime =
      TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute);
  final newTime = await showTimePicker(
    context: context,
    initialTime: initialTime,
  );

  String value;

  if (newTime == null) {
    value = "Starting Time";
  } else {
    final hour = newTime.hour.toString().padLeft(2, '0');
    final minutes = newTime.minute.toString().padLeft(2, '0');
    value = '${hour}:${minutes}';
  }

  controller.text = value;
}

class RequestTrip extends StatefulWidget {
  SearchInfo sSearchInfo;
  SearchInfo eSearchInfo;
  DateTime sDate;
  RequestTrip(
      {Key? key,
      required this.sSearchInfo,
      required this.eSearchInfo,
      required this.sDate})
      : super(key: key);

  @override
  State<RequestTrip> createState() => _RequestTripState();
}

class _RequestTripState extends State<RequestTrip> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _sLoc = TextEditingController();
  TextEditingController _eLoc = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  dynamic vType;
  SearchInfo sSearchInfo = SearchInfo();
  SearchInfo eSearchInfo = SearchInfo();
  MapController controller = MapController(
    initMapWithUserPosition: false,
    initPosition: osm.GeoPoint(latitude: 47.4358055, longitude: 8.4737324),
    areaLimit: BoundingBox(
      east: 10.4922941,
      north: 47.8084648,
      south: 45.817995,
      west: 5.9559113,
    ),
  );

  List dropdownItemList = [
    {'label': 'Car', 'value': 'Car'},
    {'label': 'Bike', 'value': 'Bike'},
    {'label': 'Micro-car', 'value': 'Micro-car'},
    {'label': 'Mini-bus', 'value': 'Mini-bus'},
  ];
  @override
  void initState() {
    LocalNotificationService.BFDNotification(context);
    setState(() {
      _sLoc.text = widget.sSearchInfo.address.toString();
      _eLoc.text = widget.eSearchInfo.address.toString();
      _dateController.text = DateFormat('dd-MM-yyyy').format(widget.sDate);
      sSearchInfo = widget.sSearchInfo;
      eSearchInfo = widget.eSearchInfo;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: Sidebar(
        menuOption: [
          MenuModel(
              menuIcon: Icons.tour_outlined,
              menuName: "Upcoming Trip",
              goToPage: RiderUpcomingPage()),
          MenuModel(
              menuIcon: Icons.taxi_alert,
              menuName: "Emergency",
              goToPage: EmergencyPage()),
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
        centerTitle: true,
        title: Text(
          "Go",
          style: GoogleFonts.dancingScript(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.blue.shade800),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black, size: 35),
      ),
      body: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height -
              AppBar().preferredSize.height,
          maxWidth: MediaQuery.of(context).size.width,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Request Trip",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w800),
                    )
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final SearchInfo result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MapScreen()),
                          );
                          setState(() {
                            sSearchInfo = result;
                            _sLoc.text = result.address.toString();
                          });
                        },
                        child: TextField(
                          enabled: false,
                          controller: _sLoc,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                              labelText: "PickUp  Location",
                              labelStyle:
                                  TextStyle(color: Colors.grey.shade800),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              prefixIcon: Icon(
                                Icons.not_listed_location,
                                size: 35.0,
                                color: Colors.blue.shade800,
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      GestureDetector(
                        onTap: () async {
                          final SearchInfo result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MapScreen()),
                          );
                          setState(() {
                            eSearchInfo = result;
                            _eLoc.text = result.address.toString();
                          });
                        },
                        child: TextField(
                          enabled: false,
                          controller: _eLoc,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            labelText: "Destination",
                            labelStyle: TextStyle(color: Colors.grey.shade800),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            prefixIcon: Icon(
                              Icons.not_listed_location,
                              size: 35.0,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      GestureDetector(
                        onTap: () => pickDate(context, _dateController),
                        child: TextField(
                          keyboardType: TextInputType.text,
                          controller: _dateController,
                          style: TextStyle(fontSize: 20),
                          enabled: false,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              hintText: "Starting Date",
                              hintStyle: TextStyle(color: Colors.grey.shade800),
                              fillColor: Colors.grey.shade200,
                              prefixIcon: Icon(
                                Icons.date_range,
                                size: 35.0,
                                color: Colors.blue.shade800,
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      GestureDetector(
                        onTap: () => pickTime(context, _timeController),
                        child: TextField(
                          keyboardType: TextInputType.text,
                          controller: _timeController,
                          style: TextStyle(fontSize: 20),
                          enabled: false,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            labelText: "Starting Time",
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            labelStyle: TextStyle(color: Colors.grey.shade800),
                            prefixIcon: Icon(
                              Icons.timer,
                              size: 35.0,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.directions_car,
                              size: 35,
                              color: Colors.blue.shade800,
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            CoolDropdown(
                              selectedItemTS:
                                  TextStyle(color: Colors.blue, fontSize: 14),
                              dropdownList: dropdownItemList,
                              onChange: (e) {
                                vType = e;
                              },
                              resultWidth: 250,
                              placeholder: "Vehicle Type",
                              resultBD: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              iconSize: 20,
                              placeholderTS: TextStyle(
                                  color: Colors.grey.shade800, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 55,
                        width: double.infinity,
                        child: RaisedButton(
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MapPage(
                                        sLatlng: sSearchInfo,
                                        eLatlng: eSearchInfo,
                                        nSeats: 1000,
                                        sDate: _dateController.text,
                                        sTime: _timeController.text,
                                        vType: vType["value"],
                                      )),
                            );
                          },
                          color: Colors.blue.shade600,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              "Request Trip",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
