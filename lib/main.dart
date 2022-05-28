import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridetripper/pages/NewTrip.dart';
import 'package:ridetripper/pages/RiderDriver.dart';
import 'package:ridetripper/service/notificationservice.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  print(message.notification!.body);
	}
Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  LocalNotificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _storage = FlutterSecureStorage();
  Widget currentPage = RiderDriver();

  void checkLogin() async {
    
    String? userid = await _storage.read(key: "userID");
    String? role = await _storage.read(key: "role");

    if (userid != null) {
      setState(() {
       currentPage= role=="driver"? DriverNewTrip():RiderSearchTrip();
      });
    }
  }

  @override
  void initState() {
    checkLogin();
    super.initState();
  }

  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        SystemNavigator.pop();
        return true;},
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.lightBlue[800],
        ),
        home: currentPage
      ),
    );
  }
}

