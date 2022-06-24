
import 'package:chatifay/Screens/CompleteProFile.dart';
import 'package:chatifay/Screens/SearchScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late String USerID;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final formKey = GlobalKey<FormState>();
  late String name, email, password, Cpassword;
final bool IsLoading=true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Register YourSelf!"),
        ),
        body: Container(
          padding: EdgeInsets.only(left: 40, right: 40, bottom: 20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 50,
                ),
                Text(
                  " Welcome To ",
                  style: GoogleFonts.lato(fontSize: 25),
                ),
                Text(
                  "Chatifay",
                  style: GoogleFonts.lato(fontSize: 50, color: Colors.green),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "  Register Yourself! ",
                  style: GoogleFonts.lato(fontSize: 18),
                ),
                SizedBox(
                  height: 50,
                ),
                Flexible(
                  child: TextFormField(
                    onChanged: (value) {
                      name = value.toString();
                    },
                    validator: (value) {
                      if (value.toString().isEmpty) {
                        return "Please Enter Name";
                      } else if (value.toString().length > 25) {
                        return "Please keep it short";
                      } else {
                        return null;
                      }
                    },
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      hoverColor: Colors.green,
                      label: Text("Name"),
                      focusColor: Colors.green,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Flexible(
                  child: TextFormField(
                    onChanged: (value) {
                      email = value.toString();
                    },
                    validator: (value) {
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
                ),
                SizedBox(
                  height: 15,
                ),
                Flexible(
                  child: TextFormField(
                    onChanged: (value) {
                      password = value;
                    },
                    validator: (value) {
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
                ),
                SizedBox(
                  height: 15,
                ),
                Flexible(
                  child: TextFormField(
                    validator: (value) {
                      // to do later
                    },
                    decoration: InputDecoration(
                      label: Text("Confirm Password"),
                      focusColor: Colors.green,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                    child: FloatingActionButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      RegisterUSer(
                          email.trim(), password, name); //registering user
                      // storing user
                      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
                          content: Text(
                        "Succuss!",
                        style: GoogleFonts.lato(fontSize: 25),
                      )));
                    }
                  },
                  child: Text("GO"),
                )),
              ],
            ),
          ),
        ));
  }

  void RegisterUSer(String Email, Password, name) async {

    final user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: Email, password: Password);
    if (user != null) {
      USerID=await _firebaseAuth.currentUser!.uid;
      Fluttertoast.showToast(msg: "Congratulations!");
      StoreUser(name, email,USerID);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => CompleteProfile(USerID)));
    }else{
      print("User is null");
    }
  }

  void StoreUser(String name, email,id) async {
     // getting current user ID
    final Map<String, dynamic> usermap = {
      "name": name,
      "email": email,
      "Profileimage":"",// Will do it in COmpleteProfilesection
      "fullname":"",
      "time":Timestamp.now()// Will do it in COmpleteProfilesection
    };
    await _firebaseFirestore.collection("users").doc(id).set(usermap);

  }
}
