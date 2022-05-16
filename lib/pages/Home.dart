// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ridetripper/components/Drawer.dart';
import 'package:ridetripper/components/HomeBanner.dart';
import 'package:ridetripper/model/menu.dart';
import 'package:ridetripper/pages/Emergency.dart';
import 'package:ridetripper/pages/LoginPage.dart';
import 'package:ridetripper/pages/Registration.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              child: Column(
                children: [
                  Text(
                    "Go",
                    style: GoogleFonts.dancingScript(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Colors.white),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    "A Different Approach for Ride Sharing.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            HomeBanner(),
            Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 60,
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: RaisedButton(
                    shape: StadiumBorder(),
                    child: Text(
                      "Log In Your Account",
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 14,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Registration()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    child: const Text("Create Your Account",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
