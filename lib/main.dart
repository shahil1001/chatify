import 'package:chatifay/Screens/CompleteProFile.dart';
import 'package:chatifay/Screens/SearchScreen.dart';
import 'package:chatifay/Screens/ResgisterScreen.dart';
import 'package:chatifay/Screens/UsersListScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'Screens/LoginScreen.dart';
var key=Uuid();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyBHaeOQVnRwR0sEFM3RRpOhGiBE79c0VME",
          appId: "com.example.chatifay",
          messagingSenderId: "364846554384",
          projectId: "chatifay-795ef"));
  User? user=FirebaseAuth.instance.currentUser;
  if(user==null){
    runApp(const MyApp());
  }else{
    runApp( AlreadyLoggedInMyApp());
  }

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}
class AlreadyLoggedInMyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UsresListScreen(FirebaseAuth.instance.currentUser!.uid),
    );
  }
}

