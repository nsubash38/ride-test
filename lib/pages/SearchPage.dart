import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ridetripper/components/Drawer.dart';
import 'package:ridetripper/components/Skeleton.dart';
import 'package:ridetripper/model/RiderTrip.dart';
import 'package:ridetripper/model/TripModel.dart';
import 'package:ridetripper/model/User.dart';
import 'package:ridetripper/model/menu.dart';
import 'package:ridetripper/pages/ContactUs.dart';
import 'package:ridetripper/pages/Emergency.dart';
import 'package:ridetripper/pages/NewTrip.dart';
import 'package:ridetripper/pages/SignOut.dart';
import 'package:ridetripper/pages/UpcomingPage.dart';
import 'package:ridetripper/service/notificationservice.dart';

class SearchPage extends StatefulWidget {
  SearchInfo sLatlng;
  SearchInfo eLatlng;
  DateTime sDate;
  int nSeats;
  SearchPage(
      {Key? key,
      required this.sLatlng,
      required this.eLatlng,
      required this.nSeats,
      required this.sDate})
      : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<TripModel> TripList = [];
  final _storage = FlutterSecureStorage();
  bool _isLoading = true;

  void findAvailableTrip() async {
    final tripRef = FirebaseFirestore.instance.collection("trip_info");
    final startingLatQuery = tripRef.where("starting_lat",
        isGreaterThanOrEqualTo: widget.sLatlng.point!.latitude - 0.01);
    final startingLatQuery1 = startingLatQuery.where("starting_lat",
        isLessThanOrEqualTo: widget.sLatlng.point!.latitude + 0.03);
    startingLatQuery1.get().then((QuerySnapshot querySnapshot) {
      List<TripModel> collectAvailableTrip = [];
      print(querySnapshot.docs.length);

      querySnapshot.docs.forEach((element) {
        if (element["number_seats"] >= widget.nSeats &&
            element["date"].toDate().isAfter(widget.sDate)) {
          print("Yes");
          double endingDistance = Geolocator.distanceBetween(
                  element["ending_lat"],
                  element["ending_lng"],
                  widget.eLatlng.point!.latitude,
                  widget.eLatlng.point!.longitude) /
              1000;
          double startingDistance = Geolocator.distanceBetween(
                  element["starting_lat"],
                  element["starting_lng"],
                  widget.sLatlng.point!.latitude,
                  widget.sLatlng.point!.longitude) /
              1000;
          if (startingDistance <= 1 && endingDistance <= 1) {
            TripModel trip =
                TripModel.fromJson(element.data() as Map<String, dynamic>);
            trip.docId = element.id;
            FirebaseFirestore.instance
                .collection("driver_trip")
                .where("id", isEqualTo: trip.id)
                .get()
                .then((value) {
              FirebaseFirestore.instance
                  .collection("driver")
                  .doc(value.docs[0].data()["driverId"])
                  .get()
                  .then((value) {
                trip.driver = User.fromJsonRiderInfo(value.data()!);
                collectAvailableTrip.add(trip);
                setState(() {
                  TripList = collectAvailableTrip;
                  TripList.sort(
                    (a, b) => a.date.compareTo(b.date),
                  );
                });
              });
            });
          }
        }
      });
    });
  }

  Future<void> confirmRiderTrip(
      String tripDocId, String selectedTripID, int costPerSeat) async {
    FirebaseFirestore.instance
        .collection("trip_info")
        .doc(tripDocId)
        .update({"number_seats": FieldValue.increment(-widget.nSeats)}).then(
            (value) async {
      String? userId = await _storage.read(key: "userID");
      RiderTrip newRider = RiderTrip(
          id: selectedTripID,
          riderId: userId!,
          pickup_point: widget.sLatlng.address.toString(),
          fare: widget.nSeats * costPerSeat,
          seats: widget.nSeats);
      final riderTripRef = FirebaseFirestore.instance.collection("rider_trip");
      final idQuery = riderTripRef.where("id", isEqualTo: selectedTripID);
      final riderQuery = idQuery.where("riderId", isEqualTo: userId);

      riderQuery.get().then((value) async {
        if (value.docs.length > 0) {
          riderTripRef.doc(value.docs[0].id).update({
            "seats": FieldValue.increment(widget.nSeats),
            "fare": FieldValue.increment(widget.nSeats * costPerSeat)
          });
        } else {
          final riderTrip =
              FirebaseFirestore.instance.collection("rider_trip").doc();
          await riderTrip.set(newRider.toJsonTrip());
        }
        FirebaseFirestore.instance
            .collection("driver_trip")
            .where("id", isEqualTo: selectedTripID)
            .get()
            .then((value) {
          FirebaseFirestore.instance
              .collection("driver")
              .doc(value.docs[0].data()["driverId"])
              .get()
              .then((value) {
            LocalNotificationService.sendPushMessage(value.data()!["token"],
                "A rider has booked for your trip.", "Trip Booked");
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RiderSearchTrip()),
            );
          });
        });
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _isLoading = true;
    super.initState();
    findAvailableTrip();
    LocalNotificationService.BFDNotification(context);
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RiderSearchTrip()),
        );
        return true;
      },
      child: Scaffold(
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
        body: _isLoading
            ? Skeleton()
            : TripList.length == 0
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          "No Trip Available",
                          style: TextStyle(fontSize: 33),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RequestTrip(
                                      sSearchInfo: widget.sLatlng,
                                      eSearchInfo: widget.eLatlng,
                                      sDate: widget.sDate)),
                            );
                          },
                          child: Text(
                            "REQUEST FOR A TRIP",
                            style: TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: TripList.length,
                    itemBuilder: (context, index) {
                      return TripContainer(TripList[index]);
                    }),
      ),
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
          UserDetails(tripModel),
          Container(
            height: 45,
            width: double.infinity,
            padding: EdgeInsets.all(1),
            child: ElevatedButton(
              onPressed: () {
                confirmRiderTrip(
                    tripModel.docId!, tripModel.id, tripModel.cost_seat!);
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

  Widget UserDetails(TripModel tripModel) {
    return Container(
      height: 140,
      padding: EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Column(
                  children: [
                    const Divider(
                      thickness: 2,
                      color: Colors.black,
                    ),
                    const Text(
                      "Driver Name :",
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      tripModel.driver!.name,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      height: 0,
                    ),
                    Divider(
                      thickness: 2,
                      color: Colors.black,
                    ),
                    SizedBox(
                      height: 0,
                    ),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Text(
                                  "Vehicle Type :",
                                  style: TextStyle(fontSize: 15),
                                ),
                                Text(
                                  tripModel.vehicle_type!,
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          const VerticalDivider(
                            thickness: 2,
                            color: Colors.black,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Text(
                                  "Total Fare:",
                                  style: TextStyle(fontSize: 15),
                                ),
                                Text(
                                  (tripModel.cost_seat! * widget.nSeats)
                                          .toString() +
                                      "Tk",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
