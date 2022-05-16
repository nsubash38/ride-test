// ignore_for_file: unnecessary_new

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:ridetripper/pages/Home.dart';
import '../model/Preference.dart';

class RiderDriver extends StatefulWidget {
  const RiderDriver({Key? key}) : super(key: key);

  @override
  State<RiderDriver> createState() => _RiderDriverState();
}

class _RiderDriverState extends State<RiderDriver> {
  final _storage = FlutterSecureStorage();
  bool _isLoading = true;
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 5), () {
      if(mounted)
      {
        setState(() {
        _isLoading = false;
      });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Lottie.asset("assets/animation/goAnimation.json",
                  fit: BoxFit.cover),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Lottie.asset(
                    "assets/animation/carAnimation.zip",
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Container(
                  width: double.infinity,
                  height: 30,
                  child: Text("Continue as",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 24,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                      )),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: 300,
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: RaisedButton(
                    shape: StadiumBorder(),
                    child: Text(
                      "Rider",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    color: Colors.blue.shade800,
                    onPressed: () async {
                      await _storage.write(key: "role", value: "rider");
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Home()),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(children: <Widget>[
                  Expanded(
                    child: Container(
                        margin: const EdgeInsets.only(left: 10.0, right: 20.0),
                        child: Divider(
                          thickness: 5,
                          color: Colors.blue.shade800,
                          height: 36,
                        )),
                  ),
                  Text(
                    "OR",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  Expanded(
                    child: new Container(
                        margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                        child: Divider(
                          thickness: 5,
                          color: Colors.blue.shade800,
                          height: 36,
                        )),
                  ),
                ]),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  width: 300,
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: RaisedButton(
                    shape: StadiumBorder(),
                    child: Text(
                      "Driver",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    color: Colors.blue.shade800,
                    onPressed: () async {
                      await _storage.write(key: "role", value: 'driver');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Home()),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
