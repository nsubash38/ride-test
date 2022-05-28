import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cFireStore;
import 'package:intl/intl.dart';
import 'package:ridetripper/model/TripModel.dart';
import 'package:ridetripper/pages/NewTrip.dart';
import 'package:ridetripper/pages/SearchPage.dart';
import '../model/User.dart';

class MapPage extends StatefulWidget {
  SearchInfo sLatlng;
  SearchInfo eLatlng;
  String? sTime;
  String sDate;
  int nSeats;
  String? vType;
  User? user;

  MapPage(
      {Key? key,
      required this.sLatlng,
      required this.eLatlng,
      this.sTime,
      required this.sDate,
      required this.nSeats,
      this.vType,
      this.user})
      : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with OSMMixinObserver {
  MapController mapController = MapController(
    initMapWithUserPosition: false,
    initPosition: GeoPoint(latitude: 24.3652, longitude: 88.5956),
    areaLimit: BoundingBox(
      east: 10.4922941,
      north: 47.8084648,
      south: 45.817995,
      west: 5.9559113,
    ),
  );

  double distance = 0;
  double cost = 0;
  final _storage = FlutterSecureStorage();
  MarkerIcon markerIcon = MarkerIcon(
      icon: Icon(
    Icons.my_location,
    size: 100,
    color: Colors.blue,
  ));
  MarkerIcon markerIcon1 = MarkerIcon(
      icon: Icon(
    Icons.location_on,
    size: 100,
    color: Colors.red,
  ));

  int costCalculation() {
    if (distance <= 20) {
      if (widget.vType!.startsWith('Car')) {
        cost = distance * 42;
      } else if (widget.vType!.startsWith('Bike')) {
        cost = distance * 16;
      } else if (widget.vType!.startsWith('Micro-car')) {
        cost = distance * 60;
      } else if (widget.vType!.startsWith('Mini-bus')) {
        cost = distance * 75;
      }
    } else {
      if (widget.vType!.startsWith('Car')) {
        cost = distance * 36;
      } else if (widget.vType!.startsWith('Bike')) {
        cost = distance * 16;
      } else if (widget.vType!.startsWith('Micro-car')) {
        cost = distance * 45;
      } else if (widget.vType!.startsWith('Mini-bus')) {
        cost = distance * 68;
      }
    }

    cost = cost / widget.nSeats;
    int actualCost = cost.round();
    return actualCost;
  }

  int requestCostCalculation() {
    if (distance <= 20) {
      if (widget.vType!.startsWith('Car')) {
        cost = distance * 45;
      } else if (widget.vType!.startsWith('Bike')) {
        cost = distance * 16;
      } else if (widget.vType!.startsWith('Micro-car')) {
        cost = distance * 63;
      } else if (widget.vType!.startsWith('Mini-bus')) {
        cost = distance * 78;
      }
    } else {
      if (widget.vType!.startsWith('Car')) {
        cost = distance * 39;
      } else if (widget.vType!.startsWith('Bike')) {
        cost = distance * 16;
      } else if (widget.vType!.startsWith('Micro-car')) {
        cost = distance * 48;
      } else if (widget.vType!.startsWith('Mini-bus')) {
        cost = distance * 71;
      }
    }

    int actualCost = cost.round();
    return actualCost;
  }

  Future handleRequetTrip() async {
    int totalCosts = requestCostCalculation();
    final toUTC = DateTime(
        int.parse(widget.sDate.substring(6, 10)),
        int.parse(widget.sDate.substring(3, 5)),
        int.parse(widget.sDate.substring(0, 2)),
        int.parse(widget.sTime!.substring(0, 2)),
        int.parse(widget.sTime!.substring(3, 5)));
    var now = new DateTime.now();
    var formatter = new DateFormat('hhmm').format(now) + "_";
    String id = "trip" + formatter;
    cFireStore.FirebaseFirestore.instance
        .collection('trip_count')
        .doc('count')
        .get()
        .then((document) async {
      final tripModel = TripModel(
          id: id + document.data()!["counter"].toString(),
          date: toUTC,
          starting_point: widget.sLatlng.address.toString(),
          ending_point: widget.eLatlng.address.toString(),
          starting_lat: widget.sLatlng.point!.latitude,
          starting_lng: widget.sLatlng.point!.longitude,
          ending_lat: widget.eLatlng.point!.latitude,
          ending_lng: widget.eLatlng.point!.longitude,
          number_seats: 0,
          vehicle_number: "",
          vehicle_type: widget.vType,
          cost_seat: totalCosts,
          docId: await _storage.read(key: "userID"));
      cFireStore.FirebaseFirestore.instance
          .collection("trip_request")
          .doc()
          .set(tripModel.toJsonRequest())
          .then((value) {
        cFireStore.FirebaseFirestore.instance
            .collection('trip_count')
            .doc('count')
            .update({"counter": cFireStore.FieldValue.increment(1)}).then(
                (value) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RiderSearchTrip()),
          );
        });
      });
    });
  }

  Future handleConfirm() async {
    if (await _storage.read(key: "role") == "driver") {
      int costForTrip = costCalculation();
      final toUTC = DateTime(
          int.parse(widget.sDate.substring(6, 10)),
          int.parse(widget.sDate.substring(3, 5)),
          int.parse(widget.sDate.substring(0, 2)),
          int.parse(widget.sTime!.substring(0, 2)),
          int.parse(widget.sTime!.substring(3, 5)));
      var now = new DateTime.now();
      var formatter = new DateFormat('hhmm').format(now) + "_";
      String id = "trip" + formatter;
      cFireStore.FirebaseFirestore.instance
          .collection('trip_count')
          .doc('count')
          .get()
          .then((document) async {
        User user = new User(
            name: widget.user!.name,
            phoneno: widget.user!.phoneno,
            user_img: widget.user!.user_img);
        final vehicleInfo = widget.vType?.split(",");
        final docTripInfo =
            cFireStore.FirebaseFirestore.instance.collection("trip_info").doc();

        final tripModel = TripModel(
          id: id + document["counter"].toString(),
          date: toUTC,
          starting_point: widget.sLatlng.address.toString(),
          ending_point: widget.eLatlng.address.toString(),
          starting_lat: widget.sLatlng.point!.latitude,
          starting_lng: widget.sLatlng.point!.longitude,
          ending_lat: widget.eLatlng.point!.latitude,
          ending_lng: widget.eLatlng.point!.longitude,
          number_seats: widget.nSeats,
          vehicle_number: vehicleInfo![1],
          vehicle_type: vehicleInfo[0],
          cost_seat: costForTrip,
        );

        final tripInfoJson = tripModel.toJson();
        await docTripInfo.set(tripInfoJson);
        final docDriverTrip = cFireStore.FirebaseFirestore.instance
            .collection("driver_trip")
            .doc();
        docDriverTrip.set({
          'id': id + document["counter"].toString(),
          'driverId': await _storage.read(key: "userID"),
        });
      });

      await cFireStore.FirebaseFirestore.instance
          .collection('trip_count')
          .doc('count')
          .update({"counter": cFireStore.FieldValue.increment(1)}).then(
              (value) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DriverNewTrip()),
        );
      });
    } else {
      if (widget.nSeats == 1000) {
        handleRequetTrip();
      } else {
        final toUTC = DateTime(
            int.parse(widget.sDate.substring(6, 10)),
            int.parse(widget.sDate.substring(3, 5)),
            int.parse(widget.sDate.substring(0, 2)));
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SearchPage(
                  sLatlng: widget.sLatlng,
                  eLatlng: widget.eLatlng,
                  sDate: toUTC,
                  nSeats: widget.nSeats)),
        );
      }
    }
  }

  void _initialMap() async {
    RoadInfo roadInfo = await mapController.drawRoad(
      GeoPoint(
          latitude: widget.sLatlng.point!.latitude,
          longitude: widget.sLatlng.point!.longitude),
      GeoPoint(
          latitude: widget.eLatlng.point!.latitude,
          longitude: widget.eLatlng.point!.longitude),
      roadType: RoadType.car,
      intersectPoint: [
        GeoPoint(
            latitude: widget.sLatlng.point!.latitude,
            longitude: widget.sLatlng.point!.longitude),
        GeoPoint(
            latitude: widget.eLatlng.point!.latitude,
            longitude: widget.eLatlng.point!.longitude)
      ],
      roadOption: RoadOption(
        roadWidth: 10,
        roadColor: Colors.black,
        showMarkerOfPOI: false,
        zoomInto: true,
      ),
    );

    await mapController.addMarker(
        GeoPoint(
            latitude: widget.sLatlng.point!.latitude,
            longitude: widget.sLatlng.point!.longitude),
        markerIcon: markerIcon,
        angle: 0);

    await mapController.addMarker(
        GeoPoint(
            latitude: widget.eLatlng.point!.latitude,
            longitude: widget.eLatlng.point!.longitude),
        markerIcon: markerIcon1,
        angle: 0);
    distance = roadInfo.distance!;
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    if (isReady) {
      _initialMap();
    } else {
      print("Not Calling");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: OSMFlutter(
              controller: mapController,
              trackMyPosition: false,
              initZoom: 12,
              minZoomLevel: 8,
              maxZoomLevel: 14,
              stepZoom: 1,
              onMapIsReady: mapIsReady,
            ),
          ),
          Positioned(
              bottom: 20,
              height: 50,
              left: 25,
              width: MediaQuery.of(context).size.width - 50,
              child: ElevatedButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ))),
                onPressed: handleConfirm,
                child: Text(
                  "Confirm",
                  style: TextStyle(fontSize: 25),
                ),
              ))
        ],
      ),
    );
  }
}
