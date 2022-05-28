import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ridetripper/main.dart';
import 'package:ridetripper/model/User.dart' as user;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ridetripper/pages/NewTrip.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  bool emailValidate = false;
  bool passwordValidate = false;
  String emailError = "";
  String passError = "";
  String? token;
  final _auth = FirebaseAuth.instance;
  final _storage = FlutterSecureStorage();

  void _handleValidation() {
    if (emailController.text.isEmpty) {
      setState(() {
        emailError = "Please Enter Your Email or Phone";
        emailValidate = true;
      });
    } else if (!emailController.text.contains("@")) {
      if (!RegExp(r"^(?:(?:\+|00)88|01)?\d{11}\r?$")
          .hasMatch(emailController.text)) {
        setState(() {
          emailError = "Phone Number Must Have 11 Digits";
          emailValidate = true;
        });
      }
    } else {
      if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
          .hasMatch(emailController.text)) {
        setState(() {
          emailError = "Please Enter Your Emailid or Phone";
          emailValidate = true;
        });
      }
    }
    if (passwordController.text.isEmpty) {
      setState(() {
        passError = "Please Enter Your Password";
        passwordValidate = true;
      });
    } else if (!RegExp(r"^.{6,}$").hasMatch(passwordController.text)) {
      setState(() {
        passError = "Please Enter Valid Password(Min 6 Character)";
        passwordValidate = true;
      });
    }
  }

  void phoneLogin() async {
    String? role = await _storage.read(key: "role");
    FirebaseFirestore.instance
        .collection(role == 'driver' ? 'driver' : 'rider')
        .where("phoneno",
            isEqualTo: int.parse(
              emailController.text,
            ))
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.length > 0) {
        querySnapshot.docs.forEach((element) async {
          if (element["password"] == passwordController.text) {
            await _storage.write(key: "userID", value: element.id);
            FirebaseMessaging.instance.getToken().then((value) {
              setState(() {
                token = value;
              });
            }).then((value) {
              FirebaseFirestore.instance
                  .collection(role == "driver" ? "driver" : "rider")
                  .doc(element.id)
                  .update({"token": token}).then((value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => role == "driver"
                          ? DriverNewTrip()
                          : RiderSearchTrip()),
                );
              });
            });
          } else {
            _showToast("Phone number or password is invalid");
          }
        });
      } else {
        _showToast("There is no account using the phone no");
      }
    });
  }

  _showToast(message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void emailLogin() async {
    String? role = await _storage.read(key: "role");
    FirebaseFirestore.instance
        .collection(role == "driver" ? 'driver' : 'rider')
        .where("email", isEqualTo: emailController.text)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.length > 0) {
        querySnapshot.docs.forEach((element) async {
          if (element["password"] == passwordController.text) {
            FirebaseMessaging.instance.getToken().then((value) {
              setState(() {
                token = value;
              });
            }).then((value) async {
              await _storage.write(key: "userID", value: element.id);
              FirebaseFirestore.instance
                  .collection(role == "driver" ? "driver" : "rider")
                  .doc(element.id)
                  .update({"token": token}).then((value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => role == "driver"
                          ? DriverNewTrip()
                          : RiderSearchTrip()),
                );
              });
            });
          } else {
            _showToast("Email or password is invalid");
          }
        });
      } else {
        _showToast("There is no account using the email id");
      }
    });
  }

  void _handleLogin() async {
    setState(() {
      emailError = "";
      emailValidate = false;
      passError = "";
      passwordValidate = false;
    });
    _handleValidation();
    if (!emailValidate && !passwordValidate) {
      if (!emailController.text.contains("@")) {
        phoneLogin();
      } else {
        emailLogin();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height -
                AppBar().preferredSize.height * 2,
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
                flex: 2,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Sign In",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 46,
                            fontWeight: FontWeight.w800),
                      )
                    ],
                  ),
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
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(fontSize: 22),
                          decoration: InputDecoration(
                            labelText: "Email/Phone Number",
                            labelStyle: TextStyle(color: Colors.grey.shade800),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            errorText: emailValidate ? emailError : null,
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        TextField(
                          keyboardType: TextInputType.text,
                          controller: passwordController,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          style: TextStyle(fontSize: 22),
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: TextStyle(color: Colors.grey.shade800),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            errorText: passwordValidate ? passError : null,
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Container(
                          width: double.infinity,
                          child: RaisedButton(
                            shape: StadiumBorder(),
                            onPressed: _handleLogin,
                            color: Colors.blue.shade600,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                "Login",
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
}
