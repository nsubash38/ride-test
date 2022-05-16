import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridetripper/main.dart';

class SignOut extends StatefulWidget {
  const SignOut({ Key? key }) : super(key: key);

  @override
  State<SignOut> createState() => _SignOutState();
}

class _SignOutState extends State<SignOut> {

  final _storage = FlutterSecureStorage();


  void logOutFromSystem(){
    _storage.deleteAll()
    .then((value) {
        Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyApp()),
            );
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    logOutFromSystem();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}