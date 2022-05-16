import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart' as geoCoding;
import 'package:geolocator/geolocator.dart' as geoLoc;
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:ridetripper/components/Skeleton.dart';
import 'package:ridetripper/model/RequestTripModel.dart';
import 'package:ridetripper/model/RiderTrip.dart';
import 'package:ridetripper/model/TripModel.dart';
import 'package:ridetripper/model/User.dart';
import 'package:ridetripper/pages/ContactUs.dart';
import 'package:ridetripper/pages/Emergency.dart';
import 'package:ridetripper/pages/SignOut.dart';
import 'package:ridetripper/pages/UpcomingPage.dart';
import 'package:ridetripper/service/notificationservice.dart';

import '../components/Drawer.dart';
import '../main.dart';
import '../model/menu.dart';

class RiderRequestTrip extends StatefulWidget {
  const RiderRequestTrip({Key? key}) : super(key: key);

  @override
  State<RiderRequestTrip> createState() => _RiderRequestTripState();
}

class _RiderRequestTripState extends State<RiderRequestTrip> {
  List<TripModel> requestTrip = [];
  final _storage = FlutterSecureStorage();
  bool _isLoading = true;

  Future getRiderRequestTrip() async {
    final requestTripRef =
        FirebaseFirestore.instance.collection("trip_request");
    final riderQuery = requestTripRef.where("requesterId",
        isEqualTo: await _storage.read(key: "userID"));

    riderQuery.get().then((value) {
      value.docs.forEach((element) {
        TripModel tripModel = TripModel.fromJsonRequestTrip(element.data());
        tripModel.docId = element.id;
        setState(() {
          requestTrip.add(tripModel);
          requestTrip.sort(
            (a, b) => a.date.compareTo(b.date),
          );
        });
      });
    });
  }

  void handleCancel(TripModel tripModel) {
    FirebaseFirestore.instance
        .collection("trip_request")
        .doc(tripModel.docId)
        .delete()
        .then((value) {
      setState(() {
        requestTrip.remove(tripModel);
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _isLoading = true;
    getRiderRequestTrip();
    LocalNotificationService.BFDNotification(context);
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Sidebar(
        menuOption: [
          MenuModel(menuIcon: Icons.home, menuName: "Home", goToPage: MyApp()),
          MenuModel(
              menuIcon: Icons.tour,
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
      body: _isLoading
          ? Skeleton2()
          : requestTrip.length == 0
              ? Center(
                  child: Text(
                    "No Trip Available",
                    style: TextStyle(fontSize: 33),
                  ),
                )
              : ListView.builder(
                  itemCount: requestTrip.length,
                  itemBuilder: (context, index) {
                    return TripContainer(requestTrip[index]);
                  }),
    );
  }

  Widget TripContainer(TripModel tripModel) {
    return Container(
      margin: EdgeInsets.fromLTRB(5, 1, 5, 4),
      padding: EdgeInsets.all(1),
      height: 316,
      width: double.infinity,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('dd-MM-yyyy').format(tripModel.date),
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        DateFormat('hh:mm a').format(tripModel.date),
                        style: TextStyle(fontSize: 18),
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: EdgeInsets.all(1),
                    child: Column(
                      children: [
                        Container(
                            alignment: Alignment.center,
                            height: 42,
                            child: Text(
                              tripModel.starting_point,
                              overflow: TextOverflow.clip,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18),
                            )),
                        Icon(
                          Icons.arrow_downward,
                          size: 40,
                        ),
                        Container(
                          height: 42,
                          child: Text(
                            tripModel.ending_point,
                            overflow: TextOverflow.clip,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.fromLTRB(15, 10, 15, 10),
              width: 310,
              child: DataTable(
                columnSpacing: 60,
                dividerThickness: 3,
                dataRowHeight: 42,
                columns: [
                  DataColumn(
                    label: Text(
                      "Vehicle Type",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  DataColumn(
                      label: Text(
                    "Total Fare",
                    style: TextStyle(fontSize: 18),
                  )),
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(Center(
                        child: Text(
                      tripModel.vehicle_type!,
                      style: TextStyle(fontSize: 18),
                    ))),
                    DataCell(Center(
                        child: Text(
                      tripModel.cost_seat!.toString() + " Tk",
                      style: TextStyle(fontSize: 18),
                    )))
                  ])
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 45,
            margin: EdgeInsets.fromLTRB(15, 10, 15, 10),
            child: ElevatedButton(
              onPressed: () {
                handleCancel(tripModel);
              },
              child: Text(
                "Cancel Request",
                style: TextStyle(fontSize: 20),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class DriverRequestTrip extends StatefulWidget {
  const DriverRequestTrip({Key? key}) : super(key: key);

  @override
  State<DriverRequestTrip> createState() => _DriverRequestTripState();
}

class _DriverRequestTripState extends State<DriverRequestTrip> {
  geoLoc.Position? _currentLocation;
  final _storage = FlutterSecureStorage();
  late User user;
  List<String> vehicleType = [];
  List<String> vehicleList = [];
  List<RequestTripModel> requestTrip = [];
  bool _isLoading = true;

  Future<geoLoc.Position> _getLocationPermission() async {
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return Future.error("Service Disabled");
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return Future.error("Permission Denied");
      }
    }

    _locationData = await location.getLocation();

    return geoLoc.Geolocator.getCurrentPosition(
        desiredAccuracy: geoLoc.LocationAccuracy.high);
  }

  Future getList(geoLoc.Position _currentLocation) async{
    FirebaseFirestore.instance
        .collection("driver")
        .doc(await _storage.read(key: "userID"))
        .get()
        .then((value) {
      setState(() {
        user = User.fromJson(value.data()!);
        user.vehicleList!.forEach((element) {
          vehicleType.add(element["vehicle_type"]);
          vehicleList
              .add(element["vehicle_type"] + " | " + element["vehicle_number"]);
        });
      });
      final requestTripRef =
          FirebaseFirestore.instance.collection("trip_request");
      final latitudeQuery = requestTripRef.where("starting_lat",
          isGreaterThanOrEqualTo: _currentLocation.latitude);
      final latitudeQuery1 = latitudeQuery.where("starting_lat",
          isLessThanOrEqualTo: _currentLocation.latitude + .05);
      latitudeQuery1.get().then((value) {
        value.docs.forEach((element) {
          if (vehicleType.contains(element["vehicle_type"])) {
            double startingDistance = geoLoc.Geolocator.distanceBetween(
                    element.data()["starting_lat"],
                    element.data()["starting_lng"],
                    _currentLocation.latitude,
                    _currentLocation.longitude) /
                1000;
            if (startingDistance <= 3) {
              TripModel tripModel =
                  TripModel.fromJsonRequestTrip(element.data());
              tripModel.docId = element.id;
              String requesterId = element["requesterId"];
              List<String> driverAvailableVehicle = [];
              vehicleList.forEach((element1) {
                if (element1.startsWith(element["vehicle_type"])) {
                  driverAvailableVehicle.add(element1);
                }
              });
              setState(() {
                requestTrip.add(RequestTripModel(
                    tripModel: tripModel,
                    vehicleList: driverAvailableVehicle,
                    requesterId: requesterId));

                requestTrip.sort(
                  (a, b) => a.tripModel!.date.compareTo(b.tripModel!.date),
                );
              });
            }
          }
        });
      });
    });

  }

  Future getAvailableTrip() async {
     await _getLocationPermission().then((value) {
      getList(value);
    });
    
  }

  void handleConfirm(TripModel tripModel, String requesterId, dynamic vType) {
    if (vType != null) {
      setState(() {
        _isLoading = true;
      });
      final vehicle = vType["value"].toString().split(" | ");
      tripModel.vehicle_number = vehicle.last;
      FirebaseFirestore.instance
          .collection("trip_info")
          .doc()
          .set(tripModel.toJson())
          .then((value) {
        FirebaseFirestore.instance
            .collection("trip_request")
            .doc(tripModel.docId)
            .delete()
            .then((value) async {
          FirebaseFirestore.instance.collection("driver_trip").doc().set({
            'id': tripModel.id,
            'driverId': await _storage.read(key: "userID"),
          });

          FirebaseFirestore.instance
              .collection("rider_trip")
              .doc()
              .set(RiderTrip(
                      id: tripModel.id,
                      riderId: requesterId,
                      pickup_point: tripModel.starting_point,
                      fare: tripModel.cost_seat!,
                      seats: 1000)
                  .toJsonTrip())
              .then((value) {
            FirebaseFirestore.instance
                .collection("rider")
                .doc(requesterId)
                .get()
                .then((value) {
              LocalNotificationService.sendPushMessage(
                  value.data()!["token"],
                  "A driver has confirmed your requested trip.",
                  "Trip Confirmed");
            });
            setState(() {
              _isLoading = false;
              requestTrip
                  .removeWhere((element) => element.tripModel == tripModel);
            });
          });
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select vehicle for the trip')));
    }
  }

  List dropdownItemList = [
    {'label': "Sort By Date", 'value': "Date"},
    {'label': "Sort By Fare", 'value': "Fare"},
  ];
  @override
  void initState() {
    _isLoading = true;
    getAvailableTrip();
    LocalNotificationService.BFDNotification(context);
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Sidebar(
        menuOption: [
          MenuModel(menuIcon: Icons.home, menuName: "Home", goToPage: MyApp()),
          MenuModel(
              menuIcon: Icons.tour,
              menuName: "Upcoming Trip",
              goToPage: DriverUpcoming()),
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
      body: _isLoading
          ? Skeleton2()
          : requestTrip.length == 0
              ? Center(
                  child: Text(
                    "No Trip Available",
                    style: TextStyle(fontSize: 33),
                  ),
                )
              : Column(
                  children: [
                    Container(
                      alignment: Alignment.topRight,
                      margin: EdgeInsets.fromLTRB(0, 5, 10, 5),
                      height: 35,
                      child: CoolDropdown(
                        selectedItemTS:
                            TextStyle(color: Colors.blue, fontSize: 14),
                        dropdownList: dropdownItemList,
                        onChange: (e) {
                          if (e["value"] == "Date") {
                            setState(() {
                              requestTrip.sort(
                                (a, b) => a.tripModel!.date
                                    .compareTo(b.tripModel!.date),
                              );
                            });
                          } else if (e["value"] == "Fare") {
                            setState(() {
                              requestTrip.sort(
                                (a, b) => b.tripModel!.cost_seat!
                                    .compareTo(a.tripModel!.cost_seat!),
                              );
                            });
                          }
                        },
                        resultWidth: 150,
                        placeholder: "Sort By ....",
                        dropdownBD: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        resultBD: BoxDecoration(
                          color: Colors.grey.shade400,
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
                        dropdownHeight: 120,
                        iconSize: 20,
                        placeholderTS: TextStyle(
                            color: Colors.grey.shade800, fontSize: 20),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: requestTrip.length,
                          itemBuilder: (context, index) {
                            dynamic vType;
                            return TripContainer(
                                requestTrip[index].tripModel!,
                                requestTrip[index].vehicleList!,
                                requestTrip[index].requesterId!,
                                vType);
                          }),
                    ),
                  ],
                ),
    );
  }

  Widget TripContainer(TripModel tripModel, List<String> vehicleList,
      String requesterId, dynamic vType) {
    List dropdownItemList = [];
    vehicleList.forEach((element) {
      dropdownItemList.add({'label': element, 'value': element});
    });
    return Container(
      margin: EdgeInsets.fromLTRB(5, 1, 5, 4),
      padding: EdgeInsets.all(1),
      height: 295,
      width: double.infinity,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('dd-MM-yyyy').format(tripModel.date),
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        DateFormat('hh:mm a').format(tripModel.date),
                        style: TextStyle(fontSize: 18),
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: EdgeInsets.all(1),
                    child: Column(
                      children: [
                        Container(
                            alignment: Alignment.center,
                            height: 35,
                            child: Text(
                              tripModel.starting_point,
                              overflow: TextOverflow.clip,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15),
                            )),
                        Icon(
                          Icons.arrow_downward,
                          size: 35,
                        ),
                        Container(
                          height: 35,
                          child: Text(
                            tripModel.ending_point,
                            overflow: TextOverflow.clip,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Center(
            child: Container(
              width: 310,
              child: DataTable(
                columnSpacing: 60,
                dividerThickness: 3,
                dataRowHeight: 42,
                columns: [
                  DataColumn(
                    label: Text(
                      "Vehicle Type",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  DataColumn(
                      label: Text(
                    "Total Fare",
                    style: TextStyle(fontSize: 18),
                  )),
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(Center(
                        child: Text(
                      tripModel.vehicle_type!,
                      style: TextStyle(fontSize: 16),
                    ))),
                    DataCell(Center(
                        child: Text(
                      tripModel.cost_seat!.toString() + " Tk",
                      style: TextStyle(fontSize: 16),
                    )))
                  ])
                ],
              ),
            ),
          ),
          Container(
            height: 40,
            margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
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
                  selectedItemTS: TextStyle(color: Colors.blue, fontSize: 14),
                  dropdownList: dropdownItemList,
                  dropdownHeight: 250,
                  onChange: (e) {
                    vType = e;
                  },
                  resultWidth: 250,
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
                  iconSize: 18,
                  placeholderTS:
                      TextStyle(color: Colors.grey.shade800, fontSize: 20),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: ElevatedButton(
              onPressed: () {
                handleConfirm(tripModel, requesterId, vType);
              },
              child: Text(
                "Confirm Trip",
                style: TextStyle(fontSize: 20),
              ),
            ),
          )
        ],
      ),
    );
  }
}
