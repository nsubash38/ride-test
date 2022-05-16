import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:ridetripper/components/Drawer.dart';
import 'package:ridetripper/model/User.dart';
import 'package:ridetripper/model/menu.dart';
import 'package:ridetripper/pages/AdditionalInfo.dart';
import 'package:ridetripper/pages/NewTrip.dart';

class Registration extends StatefulWidget {
  const Registration({Key? key}) : super(key: key);

  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repasswordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  String initialCountry = 'BD';
  PhoneNumber number = PhoneNumber(isoCode: 'BD');
  bool usingPhone = false;
  String inputNumber = "";
  final _storage = FlutterSecureStorage();
  String? role;
  String? token;

  Map<String, String> errorList = {
    "name": "",
    "email": "",
    "phoneno": "",
    "password": "",
    "confirmPassword": ""
  };

  auth.FirebaseAuth authen = auth.FirebaseAuth.instance;

  void _handleValidate() {
    if (nameController.text.isEmpty) {
      setState(() {
        errorList["name"] = "Enter your name";
      });
    } else {
      setState(() {
        errorList["name"] = "";
      });
    }
    if (!usingPhone) {
      if (emailController.text.isEmpty) {
        setState(() {
          errorList["email"] = "Enter your email";
        });
      } else if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
          .hasMatch(emailController.text)) {
        setState(() {
          errorList["email"] = "Enter a valid email ";
        });
      } else {
        setState(() {
          errorList["email"] = "";
        });
      }
    }

    if (phoneController.text.isEmpty) {
      setState(() {
        errorList["phoneno"] = "Enter your phone number";
      });
    } else if (!RegExp(r"^(?:(?:\+|00)88|01)?\d{10,11}\r?$")
        .hasMatch(phoneController.text)) {
      setState(() {
        errorList["phoneno"] = "Enter a valid phone number";
      });
    } else {
      setState(() {
        errorList["phoneno"] = "";
      });
    }

    if (passwordController.text.isEmpty) {
      setState(() {
        errorList["password"] = "Enter your password";
      });
    } else if (!RegExp(r"^.{6,}$").hasMatch(passwordController.text)) {
      setState(() {
        errorList["password"] = "Enter password(Min 6 Character)";
      });
    } else {
      setState(() {
        errorList["password"] = "";
      });
    }

    if (repasswordController.text.isEmpty) {
      setState(() {
        errorList["confirmPassword"] = "Enter the password again";
      });
    } else {
      setState(() {
        errorList["confirmPassword"] = "";
      });
    }
  }

  void getOTP() {
    authen.verifyPhoneNumber(
      timeout: const Duration(seconds: 120),
      phoneNumber: inputNumber,
      verificationCompleted: (auth.PhoneAuthCredential credential) async {
        handleInsert();
      },
      verificationFailed: (auth.FirebaseAuthException e) {
        setState(() {
          errorList["phoneno"] = e.message!;
        });
      },
      codeSent: (String verificationId, int? resendToken) async {
        await showOTPDialog(context,verificationId);
        
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> verifyOTP(String otpRecipientId) async {
    if (otpRecipientId != null) {
      auth.PhoneAuthCredential credentials = auth.PhoneAuthProvider.credential(
          verificationId: otpRecipientId, smsCode: otpController.text);
      await authen.signInWithCredential(credentials).then((value) {
        handleInsert();
      }).catchError((e) {
        Fluttertoast.showToast(
            msg: e.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      });
    }
  }

  Future<void> handleRegistration() async {
    _handleValidate();

    if (errorList["name"] == "" &&
        errorList["email"] == "" &&
        errorList["phoneno"] == "" &&
        errorList["password"] == "" &&
        errorList["confirmPassword"] == "") {
      if (passwordController.text == repasswordController.text) {
        role = await _storage.read(key: "role");
        FirebaseFirestore.instance
            .collection(role == "driver" ? "driver" : "rider")
            .where("phoneno", isEqualTo: int.parse(phoneController.text))
            .get()
            .then((value) {
          if (value.docs.length > 0) {
            Fluttertoast.showToast(
                msg: "A user already registered using the same phone number",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          } else {
            getOTP();
          }
        });
      } else {
        setState(() {
          errorList["confirmPassword"] =
              "Password must match with confirm password";
        });
      }
    }
  }

  void handleInsert() {
    if (emailController.text.toString().isEmpty) {
      emailController.text = "";
    }
    FirebaseMessaging.instance.getToken().then((value) {
      setState(() {
        token = value;
      });
    }).then((value) async {
      final user = User(
          email: emailController.text,
          name: nameController.text,
          phoneno: int.parse(phoneController.text),
          password: passwordController.text,
          deviceToken: token);
      if (role == "rider") {
        final docRider = FirebaseFirestore.instance.collection("rider").doc();
        user.user_img =
            "https://firebasestorage.googleapis.com/v0/b/ridetrippermobile.appspot.com/o/blank-profile-picture-973460__340.webp?alt=media&token=cc10d674-f670-4a66-8104-6adc0250f664";
        final userJson = user.toJsonRider();
        await docRider.set(userJson);
        await _storage.write(key: "userID", value: docRider.id);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RiderSearchTrip()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CarRegistration(
                    user: user,
                  )),
        );
      }
    });
  }

  Future<void> showOTPDialog(BuildContext context,String verificationId) async {
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 18),
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: "OTP",
                    labelStyle: TextStyle(color: Colors.grey.shade800),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    prefixIcon: Icon(
                      Icons.verified,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      verifyOTP(verificationId);
                    },
                    child: Text("Verify"))
              ],
            ),
          );
        });
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
        iconTheme: const IconThemeData(color: Colors.black, size: 35),
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(0, 20, 0, 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Sign Up",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w800),
                    )
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextField(
                        controller: nameController,
                        keyboardType: TextInputType.text,
                        style: TextStyle(fontSize: 18),
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: "User Name",
                          errorText: errorList["name"] == ""
                              ? null
                              : errorList["name"],
                          labelStyle: TextStyle(color: Colors.grey.shade800),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          prefixIcon: Icon(
                            Icons.account_box,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: usingPhone ? false : true,
                        child: const SizedBox(
                          height: 8,
                        ),
                      ),
                      Visibility(
                        visible: usingPhone ? false : true,
                        child: TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(fontSize: 18),
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: "Email",
                            errorText: errorList["email"] == ""
                                ? null
                                : errorList["email"],
                            labelStyle: TextStyle(color: Colors.grey.shade800),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      InternationalPhoneNumberInput(
                        onInputChanged: (PhoneNumber number) {
                          setState(() {
                            inputNumber = number.phoneNumber.toString();
                          });
                        },
                        onSubmit: () {},
                        selectorConfig: SelectorConfig(
                          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                        ),
                        spaceBetweenSelectorAndTextField: 0,
                        ignoreBlank: false,
                        autoValidateMode: AutovalidateMode.disabled,
                        selectorTextStyle:
                            TextStyle(fontSize: 18, color: Colors.black),
                        initialValue: number,
                        textFieldController: phoneController,
                        formatInput: false,
                        keyboardType: TextInputType.numberWithOptions(
                            signed: true, decimal: true),
                        inputDecoration: InputDecoration(
                          labelText: "Phone Number",
                          errorText: errorList["phoneno"] == ""
                              ? null
                              : errorList["phoneno"],
                          labelStyle: TextStyle(color: Colors.grey.shade800),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                        ),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      TextField(
                        controller: passwordController,
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        style: TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                          labelText: "Password",
                          errorText: errorList["password"] == ""
                              ? null
                              : errorList["password"],
                          labelStyle: TextStyle(color: Colors.grey.shade800),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      TextField(
                        controller: repasswordController,
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        style: TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
                          errorText: errorList["confirmPassword"] == ""
                              ? null
                              : errorList["confirmPassword"],
                          labelStyle: TextStyle(color: Colors.grey.shade800),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
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
                      Container(
                        width: double.infinity,
                        child: RaisedButton(
                          shape: StadiumBorder(),
                          onPressed: () {
                            handleRegistration();
                          },
                          color: Colors.blue.shade600,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              "SIGN UP",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                      Row(children: <Widget>[
                        Expanded(
                          child: Container(
                              margin: const EdgeInsets.only(
                                  left: 10.0, right: 20.0),
                              child: const Divider(
                                color: Colors.black,
                                height: 36,
                                thickness: 5,
                              )),
                        ),
                        const Text(
                          "OR",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Container(
                              margin: const EdgeInsets.only(
                                  left: 20.0, right: 10.0),
                              child: const Divider(
                                color: Colors.black,
                                height: 36,
                                thickness: 5,
                              )),
                        ),
                      ]),
                      Container(
                        width: double.infinity,
                        child: RaisedButton(
                          shape: StadiumBorder(),
                          onPressed: () {
                            setState(() {
                              usingPhone = !usingPhone;
                            });
                          },
                          color: Colors.blue.shade600,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: usingPhone
                                ? const Text(
                                    "SIGN UP USING EMAIL",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600),
                                  )
                                : const Text(
                                    "SIGN UP USING PHONE ",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),
                      ),
                    ],
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
