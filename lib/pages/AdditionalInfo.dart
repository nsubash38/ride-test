import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:ridetripper/model/User.dart';
import 'package:ridetripper/model/Vehicle.dart';
import 'package:ridetripper/pages/NewTrip.dart';

class CarRegistration extends StatefulWidget {
  User user;
  CarRegistration({Key? key, required this.user}) : super(key: key);

  @override
  _CarRegistrationState createState() => _CarRegistrationState();
}

class _CarRegistrationState extends State<CarRegistration> {
  final _picker = ImagePicker();
  Map<String, File?> listOfImageFile = {};
  Map<String, String?> listOfImageFileName = {};
  Map<String, String> listOfImageUrl = {};
  TextEditingController addressController = new TextEditingController();
  TextEditingController vNumberController = new TextEditingController();
  TextEditingController userImageController = new TextEditingController();
  TextEditingController vehicleImageController = new TextEditingController();
  TextEditingController nidImageController = new TextEditingController();
  TextEditingController dLicenseImageController = new TextEditingController();
  final _storage = FlutterSecureStorage();
  List dropdownItemList = [
    {'label': 'Car', 'value': 'Car'},
    {'label': 'Bike', 'value': 'Bike'},
    {'label': 'Micro Car', 'value': 'Micro-car'},
    {'label': 'Mini Bus', 'value': 'Mini-bus'},
  ];
  dynamic vType;
  String? token;
  bool _isLoading = false;
  bool _isOk = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('The System Back Button is Deactivated')));
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
        ),
        body: _isLoading
            ? _isOk
                ? Center(
                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
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
                        height: 75,
                        width: MediaQuery.of(context).size.width - 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.done,
                              color: Colors.white,
                              size: 45,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text("Registration Complete",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white)),
                          ],
                        )),
                  )
                : Center(
                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
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
                        height: 75,
                        width: MediaQuery.of(context).size.width - 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 5,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text("Please Wait",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white)),
                          ],
                        )),
                  )
            : Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height,
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8.5, 0, 8.5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Additional Information",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w800),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 5,
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
                          padding: EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 55,
                                child: TextField(
                                  keyboardType: TextInputType.text,
                                  style: TextStyle(fontSize: 20),
                                  controller: addressController,
                                  decoration: InputDecoration(
                                      labelText: "Parmanent Address",
                                      labelStyle: TextStyle(
                                          color: Colors.grey.shade800),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade200,
                                      prefixIcon: Icon(
                                        Icons.location_city,
                                        color: Colors.blue.shade800,
                                      )),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                height: 55,
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
                                    CoolDropdown(
                                      selectedItemTS: TextStyle(
                                          color: Colors.blue, fontSize: 14),
                                      dropdownList: dropdownItemList,
                                      dropdownHeight: 250,
                                      onChange: (e) {
                                        setState(() {
                                          vType = e;
                                        });
                                      },
                                      resultHeight: 55,
                                      resultWidth: 293,
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
                                          color: Colors.grey.shade800,
                                          fontSize: 20),
                                      // placeholder: 'insert...',
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              TextField(
                                keyboardType: TextInputType.text,
                                style: TextStyle(fontSize: 20),
                                controller: vNumberController,
                                decoration: InputDecoration(
                                    labelText: "Vehicle Number",
                                    labelStyle:
                                        TextStyle(color: Colors.grey.shade800),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade200,
                                    prefixIcon: Icon(
                                      Icons.add_card,
                                      color: Colors.blue.shade800,
                                    )),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              imageField(
                                  "user", "Your Image", userImageController),
                              SizedBox(
                                height: 8,
                              ),
                              imageField("vehicle", "Vehicle Image",
                                  vehicleImageController),
                              SizedBox(
                                height: 8,
                              ),
                              imageField(
                                  "nid", "Nation Id Image", nidImageController),
                              SizedBox(
                                height: 8,
                              ),
                              imageField(
                                  "drivingLicense",
                                  "Driving License Image",
                                  dLicenseImageController),
                              SizedBox(
                                height: 15,
                              ),
                              Container(
                                width: double.infinity,
                                child: RaisedButton(
                                  shape: StadiumBorder(),
                                  onPressed: () {
                                    handleSubmit();
                                  },
                                  color: Colors.blue.shade600,
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Text(
                                      "Submit",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600),
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
      ),
    );
  }

  Widget imageField(String uploadFieldName, String labelText,
      TextEditingController controller) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => buildSheet(uploadFieldName, controller),
        );
      },
      child: TextField(
        keyboardType: TextInputType.text,
        enableSuggestions: false,
        autocorrect: false,
        enabled: false,
        controller: controller,
        style: TextStyle(fontSize: 20),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.grey.shade800),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade200,
          prefixIcon: Icon(
            Icons.image,
            color: Colors.blue.shade800,
          ),
        ),
      ),
    );
  }

  Widget buildSheet(String uploadFieldName, TextEditingController controller) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.camera),
            title: Text('Camera'),
            onTap: () {
              Navigator.of(context).pop();
              _pickImage(ImageSource.camera, uploadFieldName, controller);
            },
          ),
          ListTile(
            leading: Icon(Icons.filter),
            title: Text('From Gallery'),
            onTap: () {
              Navigator.of(context).pop();
              _pickImage(ImageSource.gallery, uploadFieldName, controller);
            },
          ),
        ],
      ),
    );
  }

  void handleSubmit() async {
    setState(() {
      _isLoading = true;
    });
    for (var key in listOfImageFile.keys) {
      Reference ref =
          FirebaseStorage.instance.ref().child(listOfImageFileName[key]!);
      UploadTask uploadTask = ref.putFile(listOfImageFile[key]!);
      var imageUrl = await (await uploadTask).ref.getDownloadURL();
      var url = imageUrl.toString();
      listOfImageUrl[key] = url;
    }
    Vehicle vehicleList = Vehicle(
      vehicle_type: vType["value"],
      vehicle_number: vNumberController.text,
      vehicle_image: listOfImageUrl["vehicle"],
    );
    FirebaseMessaging.instance.getToken().then((value) {
      setState(() {
        token = value;
      });
    }).then((value) async {
      final user1 = User(
          email: widget.user.email,
          name: widget.user.name,
          phoneno: widget.user.phoneno,
          password: widget.user.password,
          address: addressController.text,
          vehicleList: [vehicleList.toJson()],
          user_img: listOfImageUrl["user"]!,
          nid_img: listOfImageUrl["nid"]!,
          drivingLicense_img: listOfImageUrl["drivingLicense"]!,
          deviceToken: token);

      final docDriver = FirebaseFirestore.instance.collection("driver").doc();

      final userJson = user1.toJsonDriver();
      await docDriver.set(userJson).then((value) async {
        setState(() {
          _isOk = true;
        });
        await _storage
            .write(key: "userID", value: docDriver.id)
            .then((value) {});

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DriverNewTrip()),
        );
      });
    });
  }

  Future _pickImage(ImageSource source, String uploadFieldName,
      TextEditingController controller) async {
    final pickedFile =
        await _picker.pickImage(source: source, imageQuality: 50);

    if (pickedFile == null) {
      return;
    }
    var file = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: CropAspectRatio(ratioX: 2, ratioY: 1));

    if (file == null) {
      return;
    }
    controller.text = "Image Uploaded";
    listOfImageFile[uploadFieldName] = file;
    listOfImageFileName[uploadFieldName] = path.basename(file.path);
  }
}
