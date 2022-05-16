import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ridetripper/main.dart';
import 'package:ridetripper/model/Vehicle.dart';
import 'package:ridetripper/service/notificationservice.dart';

class NewVehicleRegistration extends StatefulWidget {
  const NewVehicleRegistration({Key? key}) : super(key: key);

  @override
  State<NewVehicleRegistration> createState() => _NewVehicleRegistrationState();
}

class _NewVehicleRegistrationState extends State<NewVehicleRegistration> {
  final _picker = ImagePicker();
  File? imageFile;
  String? imageFileName;
  TextEditingController vNumberController = new TextEditingController();
  TextEditingController vehicleImageController = new TextEditingController();
  final _storage = FlutterSecureStorage();
  List dropdownItemList = [
    {'label': 'Car', 'value': 'Car'},
    {'label': 'Bike', 'value': 'Bike'},
    {'label': 'Micro Car', 'value': 'Micro-car'},
    {'label': 'Mini Bus', 'value': 'Mini-bus'},
  ];
  dynamic vType;
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
      body: Container(
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
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 0, 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Vehicle Information",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 42,
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
                  padding: EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                              selectedItemTS:
                                  TextStyle(color: Colors.blue, fontSize: 14),
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
                                  color: Colors.grey.shade800, fontSize: 20),
                              // placeholder: 'insert...',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextField(
                        keyboardType: TextInputType.text,
                        style: TextStyle(fontSize: 20),
                        controller: vNumberController,
                        decoration: InputDecoration(
                            labelText: "Vehicle Number",
                            labelStyle: TextStyle(color: Colors.grey.shade800),
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
                        height: 20,
                      ),
                      imageField(
                          "vehicle", "Vehicle Image", vehicleImageController),
                      SizedBox(
                        height: 100,
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
                              "Register Vehicle",
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
    final docTrip = FirebaseFirestore.instance
        .collection("driver")
        .doc(await _storage.read(key: "userID"));

    docTrip.get().then((value) async {
      List<Map<String, dynamic>> collectVehicle = [];
      List<Map<String, dynamic>> vehicleList = [];
      List<dynamic> arrayList = value.data()!["vehicleList"];
      arrayList.forEach((element) {
        collectVehicle.add(element);
      });
      Reference ref = FirebaseStorage.instance.ref().child(imageFileName!);
      UploadTask uploadTask = ref.putFile(imageFile!);
      var imageUrl = await (await uploadTask).ref.getDownloadURL();
      var url = imageUrl.toString();
      Vehicle vehicle = Vehicle(
          vehicle_type: vType["value"],
          vehicle_number: vNumberController.text,
          vehicle_image: url);
      collectVehicle.add(vehicle.toJson());
      setState(() {
        vehicleList = collectVehicle;
      });
      docTrip.update({"vehicleList": vehicleList}).then((value) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
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
    imageFile = file;
    imageFileName = path.basename(file.path);
  }
}
