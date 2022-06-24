import 'package:chatifay/Screens/SearchScreen.dart';
import 'package:chatifay/Screens/ResgisterScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import 'UsersListScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final key = GlobalKey<FormState>();
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late String email, password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Chatifay!"),
        ),
        body: Container(
          padding: EdgeInsets.only(left: 40, right: 40, bottom: 20),
          child: Form(
            key: key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 50,
                ),
                Text(
                  "  Welcome To ",
                  style: GoogleFonts.lato(fontSize: 25),
                ),
                Text(
                  "Chatifay",
                  style: GoogleFonts.lato(fontSize: 80, color: Colors.green),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "  Register Yourself! ",
                  style: GoogleFonts.lato(fontSize: 18),
                ),
                SizedBox(
                  height: 100,
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  onChanged: (value) {
                    email = value;
                  },
                  validator: (value) {
                    if (value.toString().isEmpty) {
                      return "Enter somthing!";
                    }
                    if (!value.toString().contains("@gmail.com")) {
                      return "Invalid Emial";
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    label: Text("Email"),
                    fillColor: Colors.green,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  onChanged: (value) {
                    password = value;
                  },
                  validator: (value) {
                    if (value.toString().isEmpty) {
                      return "Enter somthing!";
                    }
                    if (value!.length < 5) {
                      return "weak password";
                    } else {
                      return null;
                    }
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    label: Text("Password"),
                    focusColor: Colors.green,
                    border: OutlineInputBorder(),
                  ),
                ),
                Expanded(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        if (key.currentState!.validate()) {
                          LogInUser(email.trim(), password.toString());
                          ScaffoldMessenger.of(context)
                              .showSnackBar(new SnackBar(
                                  content: Text(
                            "Succuss!",
                            style: GoogleFonts.lato(fontSize: 25),
                          )));
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UsresListScreen(_firebaseAuth.currentUser!.uid,)));
                        }
                      },
                      child: Text("GO"),
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>RegisterScreen()));
                      },
                        child: Text(
                      "CreateAccount",
                      style: GoogleFonts.lato(
                          fontSize: 20,
                          color: Colors.green,
                          fontWeight: FontWeight.w600),
                    ))
                  ],
                )),
              ],
            ),
          ),
        ));
  }

  void LogInUser(String Email, password) async {
    final user = await _firebaseAuth.signInWithEmailAndPassword(
        email: Email, password: password);
    if (user != null) {
      Fluttertoast.showToast(msg: "LoggedIn!");
    }
  }
}
