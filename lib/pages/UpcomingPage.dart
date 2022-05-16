import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ridetripper/components/Drawer.dart';
import 'package:ridetripper/components/Skeleton.dart';
import 'package:ridetripper/main.dart';
import 'package:ridetripper/model/RiderTrip.dart';
import 'package:ridetripper/model/TripModel.dart';
import 'package:ridetripper/model/User.dart';
import 'package:ridetripper/model/menu.dart';
import 'package:ridetripper/pages/ContactUs.dart';
import 'package:ridetripper/pages/Emergency.dart';
import 'package:ridetripper/pages/RequestTrip.dart';
import 'package:ridetripper/pages/SignOut.dart';
import 'package:ridetripper/service/notificationservice.dart';
import 'package:url_launcher/url_launcher.dart';

class RiderUpcomingPage extends StatefulWidget {
  const RiderUpcomingPage({Key? key}) : super(key: key);

  @override
  State<RiderUpcomingPage> createState() => _RiderUpcomingPageState();
}

class _RiderUpcomingPageState extends State<RiderUpcomingPage> {
  List<TripModel> TripList = [];
  late User user;

  final _storage = FlutterSecureStorage();

  void getUpcomingTrip() async {
    List<TripModel> collectTrip = [];
    String? userID = await _storage.read(key: "userID");
    FirebaseFirestore.instance
        .collection('rider_trip')
        .where("riderId", isEqualTo: userID)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((element) {
        RiderTrip riderTrip =
            RiderTrip.fromJson(element.data() as Map<String, dynamic>);
        riderTrip.docId = element.id;
        FirebaseFirestore.instance
            .collection('trip_info')
            .where("id", isEqualTo: element["id"])
            .get()
            .then((value) {
          var data = value.docs[0].data();
          if (data["date"].toDate().isAfter(DateTime.now())) {
            TripModel tripModel = TripModel.fromJson(data);
            tripModel.docId = value.docs[0].id;
            tripModel.riderList = [];
            tripModel.riderList!.add(riderTrip);
            FirebaseFirestore.instance
                .collection("driver_trip")
                .where("id", isEqualTo: element["id"])
                .get()
                .then((value) {
              FirebaseFirestore.instance
                  .collection("driver")
                  .doc(value.docs[0].data()["driverId"])
                  .get()
                  .then((value) {
                tripModel.driver = User.fromJsonDriverInfo(
                    value.data() as Map<String, dynamic>);
                collectTrip.add(tripModel);
                setState(() {
                  TripList = collectTrip;
                });
              });
            });
          }
        });
      });
    });
  }

  void _handleCancelTrip(
      String docId, String riderDocId, String tripId, int seats) {
    if (seats == 1000) {
      FirebaseFirestore.instance
          .collection("trip_info")
          .doc(docId)
          .delete()
          .then((value) {
        FirebaseFirestore.instance
            .collection("rider_trip")
            .doc(riderDocId)
            .delete()
            .then((value) {
          setState(() {
            TripList.removeWhere((element) => element.id == tripId);
          });
        });
      });
    } else {
      FirebaseFirestore.instance
          .collection("trip_info")
          .doc(docId)
          .update({"number_seats": FieldValue.increment(seats)}).then((value) {
        FirebaseFirestore.instance
            .collection("rider_trip")
            .doc(riderDocId)
            .delete()
            .then((value) {
          setState(() {
            TripList.removeWhere((element) => element.id == tripId);
          });
        });
      });
    }
  }

  late bool _isLoading;
  @override
  void initState() {
    _isLoading = true;
    getUpcomingTrip();
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
      body: _isLoading
          ? Skeleton2()
          : TripList.length == 0
              ? Center(
                  child: Text(
                  "No Trip",
                  style: TextStyle(fontSize: 35),
                ))
              : ListView.builder(
                  itemCount: TripList.length,
                  itemBuilder: (context, index) {
                    return TripContainer(TripList[index]);
                  }),
    );
  }

  Widget TripContainer(TripModel tripModel) {
    return Container(
        margin: EdgeInsets.fromLTRB(5, 1, 5, 4),
        padding: EdgeInsets.all(5),
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
            Expanded(
                flex: 4,
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
                            height: 15,
                          ),
                          Text(
                            DateFormat('hh:mm a').format(tripModel.date),
                            style: TextStyle(fontSize: 18),
                          ),
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
                                height: 42,
                                child: Text(
                                  tripModel.starting_point,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.clip,
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
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.clip,
                                style: TextStyle(fontSize: 18),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                )),
            Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 15),
                child: DataTable(
                  columnSpacing: 20,
                  dividerThickness: 5,
                  dataRowHeight: 50,
                  columns: [
                    DataColumn(
                      label: Text(
                        "Seats",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Fare",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    DataColumn(
                        label: Text(
                      tripModel.vehicle_type! + " Number",
                      style: TextStyle(fontSize: 18),
                    )),
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Center(
                          child: Text(
                        tripModel.riderList![0].seats == 1000
                            ? "All"
                            : tripModel.riderList![0].seats.toString(),
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ))),
                      DataCell(Center(
                          child: Text(
                        tripModel.riderList![0].fare.toString() + " Tk",
                        style: TextStyle(fontSize: 18),
                      ))),
                      DataCell(Center(
                          child: Text(
                        tripModel.vehicle_number!,
                        style: TextStyle(fontSize: 18),
                      ))),
                    ])
                  ],
                )),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 120,
                    height: 45,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                      ),
                      onPressed: () {
                        _handleCancelTrip(
                            tripModel.docId!,
                            tripModel.riderList![0].docId!,
                            tripModel.id,
                            tripModel.riderList![0].seats);
                      },
                      icon: Icon(Icons.dangerous),
                      label: Text(
                        "Cancel",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  Container(
                    width: 120,
                    height: 45,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return DriverDetails(tripModel.driver!);
                            });
                      },
                      icon: Icon(Icons.person),
                      label: Text(
                        "Driver Details",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }

  Widget DriverDetails(User user) {
    return Container(
      height: 210,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.all(15),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 65,
                  child: ClipOval(
                    child: Image.network(
                      user.user_img,
                      width: 300,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Center(
                  child: Container(
                      width: 190,
                      child: Text(user.name,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w600))),
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            width: double.infinity,
            child: ElevatedButton.icon(
                onPressed: () {
                  launch('tel://+880' + user.phoneno.toString());
                },
                icon: Icon(
                  Icons.phone,
                  size: 40,
                ),
                label: Text("")),
          )
        ],
      ),
    );
  }
}

class DriverUpcoming extends StatefulWidget {
  const DriverUpcoming({Key? key}) : super(key: key);

  @override
  State<DriverUpcoming> createState() => _DriverUpcomingState();
}

class _DriverUpcomingState extends State<DriverUpcoming> {
  List<TripModel> TripList = [];
  late User user;
  final _storage = FlutterSecureStorage();
  bool _isLoading = true;
  List dropdownItemList = [
    {'label': "Sort By Date", 'value': "Date"},
    {'label': "Sort By Seats", 'value': "Seats"},
  ];

  @override
  void initState() {
    // TODO: implement initState
    _isLoading = true;
    getUpcomingTrip();
    LocalNotificationService.BFDNotification(context);
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  void _handleCancelTrip(List<RiderTrip> riderList, String docId, String tripId,
      DateTime dateTime, String driverTripDocId) {
    final dif = dateTime.difference(DateTime.now()).inHours;
    final riderTripRef = FirebaseFirestore.instance.collection("rider_trip");
    for (int i = 0; i < riderList.length; i++) {
      riderTripRef.doc(riderList[i].docId).delete();
      FirebaseFirestore.instance
          .collection("rider")
          .doc(riderList[i].riderId)
          .get()
          .then((value) {
        LocalNotificationService.sendPushMessage(
            value.data()!["token"], "Driver has cancelled trip", "Trip Cancel");
      });
    }

    FirebaseFirestore.instance
        .collection("driver_trip")
        .doc(driverTripDocId)
        .delete()
        .then((value) {
      FirebaseFirestore.instance
          .collection("trip_info")
          .doc(docId)
          .delete()
          .then((value) {
        setState(() {
          TripList.removeWhere((element) => element.id == tripId);
        });
      });
    });
  }

  void getUpcomingTrip() async {
    List<TripModel> collectTrip = [];
    FirebaseFirestore.instance
        .collection('driver_trip')
        .where("driverId", isEqualTo: await _storage.read(key: "userID"))
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((element) {
        FirebaseFirestore.instance
            .collection('trip_info')
            .where("id", isEqualTo: element["id"])
            .get()
            .then((value) {
          var data = value.docs[0].data();
          if (data["date"].toDate().isAfter(DateTime.now())) {
            TripModel tripModel = TripModel.fromJson(data);
            tripModel.docId = value.docs[0].id;
            tripModel.driver =
                User(name: "", phoneno: 12345, docId: element.id);
            tripModel.riderList = [];

            FirebaseFirestore.instance
                .collection("rider_trip")
                .where("id", isEqualTo: element["id"])
                .get()
                .then((value) {
              for (int i = 0; i < value.docs.length; i++) {
                RiderTrip riderTrip = RiderTrip.fromJson(value.docs[i].data());
                riderTrip.docId = value.docs[i].id;
                FirebaseFirestore.instance
                    .collection("rider")
                    .doc(riderTrip.riderId)
                    .get()
                    .then((value) {
                  User user = User.fromJsonRiderInfo(
                      value.data() as Map<String, dynamic>);
                  riderTrip.rider = user;
                  tripModel.riderList!.add(riderTrip);
                });
              }
              collectTrip.add(tripModel);
              setState(() {
                TripList = collectTrip;
                TripList.sort(
                  (a, b) => a.date.compareTo(b.date),
                );
              });
            });
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Sidebar(
        menuOption: [
          MenuModel(menuIcon: Icons.home, menuName: "Home", goToPage: MyApp()),
          MenuModel(
              menuIcon: Icons.request_page,
              menuName: "Requested Trip",
              goToPage: DriverRequestTrip()),
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
          : TripList.length == 0
              ? Center(
                  child: Text(
                  "No Trip",
                  style: TextStyle(fontSize: 35),
                ))
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
                              TripList.sort(
                                (a, b) => a.date.compareTo(b.date),
                              );
                            });
                          } else if (e["value"] == "Seats") {
                            setState(() {
                              TripList.sort(
                                (a, b) =>
                                    a.number_seats!.compareTo(b.number_seats!),
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
                          itemCount: TripList.length,
                          itemBuilder: (context, index) {
                            return TripContainer(TripList[index]);
                          }),
                    ),
                  ],
                ),
    );
  }

  Widget TripContainer(TripModel tripModel) {
    return Container(
      margin: EdgeInsets.fromLTRB(5, 1, 5, 4),
      padding: EdgeInsets.fromLTRB(5, 3, 5, 1),
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
          Expanded(
              flex: 4,
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
                          height: 8,
                        ),
                        Text(
                          DateFormat('hh:mm a').format(tripModel.date),
                          style: TextStyle(fontSize: 18),
                        ),
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
                              height: 40,
                              child: Text(
                                tripModel.starting_point,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.clip,
                                style: TextStyle(fontSize: 18),
                              )),
                          Icon(
                            Icons.arrow_downward,
                            size: 40,
                          ),
                          Container(
                            height: 40,
                            child: Text(
                              tripModel.ending_point,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.clip,
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              )),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 15),
            child: DataTable(
              columnSpacing: 0,
              dividerThickness: 5,
              dataRowHeight: 50,
              columns: [
                DataColumn(
                  label: Text(
                    "Seats Remmaining",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                DataColumn(
                    label: Text(
                  tripModel.vehicle_type! + " Number",
                  style: TextStyle(fontSize: 18),
                )),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(Center(
                      child: Text(
                    tripModel.number_seats.toString(),
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ))),
                  DataCell(Center(
                      child: Text(
                    tripModel.vehicle_number!,
                    style: TextStyle(fontSize: 18),
                  )))
                ])
              ],
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                  ),
                  onPressed: () {
                    _handleCancelTrip(tripModel.riderList!, tripModel.docId!,
                        tripModel.id, tripModel.date, tripModel.driver!.docId);
                  },
                  icon: Icon(Icons.dangerous),
                  label: Text(
                    "Cancel",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return RiderDetails(tripModel.riderList!);
                        });
                  },
                  icon: Icon(Icons.list),
                  label: Text(
                    "Rider List",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget RiderDetails(List<RiderTrip> riderList) {
    return Scaffold(
      body: Container(
        child: riderList.length == 0
            ? Center(
                child: Text(
                "There is no Rider",
                style: TextStyle(fontSize: 35),
              ))
            : ListView.builder(
                itemCount: riderList.length,
                itemBuilder: (context, index) {
                  return DataTable(
                    horizontalMargin: 10,
                    columnSpacing: 12,
                    dividerThickness: 3,
                    dataRowHeight: 80,
                    columns: const [
                      DataColumn(
                        label: Text(
                          "Name",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Pickup At",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Fare",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Seats",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "",
                        ),
                      ),
                    ],
                    rows: [
                      DataRow(cells: [
                        DataCell(Container(
                            width: 50,
                            child: Text(riderList[index].rider!.name))),
                        DataCell(Container(
                            width: 110,
                            child: Text(riderList[index].pickup_point))),
                        DataCell(
                            Text(riderList[index].fare.toString() + " Tk")),
                        DataCell(Center(
                            child: Text(riderList[index].seats == 1000
                                ? "All"
                                : riderList[index].seats.toString()))),
                        DataCell(GestureDetector(
                          onTap: () {
                            launch('tel://+880' +
                                riderList[index].rider!.phoneno.toString());
                          },
                          child: const Icon(
                            Icons.call,
                            size: 40,
                            color: Colors.blue,
                          ),
                        ))
                      ]),
                    ],
                  );
                }),
      ),
    );
  }
}
