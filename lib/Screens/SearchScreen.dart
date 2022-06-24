import 'dart:io';

import 'package:chatifay/Screens/ChatRoomPage.dart';
import 'package:chatifay/Screens/UsersListScreen.dart';
import 'package:chatifay/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnBoardScreen extends StatefulWidget {
  const OnBoardScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardScreen> createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends State<OnBoardScreen> {
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  late String searchUSer="", otheruserID;
  bool loading = false;
  TextEditingController controller = TextEditingController();
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String  lastMessage="";
  @override
  void CreateChatRoomID(var id, String name, imageofuser, myID,) async {
    var chatroomID;

    late String alreadyChatromid;

    String myID = await _firebaseAuth.currentUser!.uid;
    QuerySnapshot querySnapshot = await _firebaseFirestore
        .collection("chatrooms")
        .where("particepents.${myID}", isEqualTo: true)
        .where("particepents.${otheruserID}", isEqualTo: true)
        .get();

    if (querySnapshot.docs.length <= 0)
    {
      chatroomID = key.v1().toString();
      print("FreshCharomID $chatroomID");
      alreadyChatromid= chatroomID;
      //there is no data there now create one

      Map<String, dynamic> particepents = {
        myID: true,
        id: true,

      };

      await _firebaseFirestore.collection("chatrooms").doc(chatroomID).set({
        "chatroomID": chatroomID,
        "lastmessage": "",
        "particepents": particepents,
        "timestamp": Timestamp.now(),
        "online":true
      });



    } else {
      alreadyChatromid= await querySnapshot.docs[0].id;
      print("ID ia already existes! ID id $alreadyChatromid");

    }

    Navigator.push(context, MaterialPageRoute(builder: (context)=>
        ChatRoomPage(name,imageofuser,querySnapshot.docs.length <= 0? chatroomID:alreadyChatromid,_firebaseAuth.currentUser!.uid)));

  }
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OnBoard"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 20, top: 10),
            child: TextField(
              controller: controller,
              onSubmitted: (finalvalue) {
                setState(() {
                  searchUSer = finalvalue.trim();
                });
              },
              decoration: InputDecoration(
                  icon: Icon(Icons.search),
                  hintText: "Search User",
                  border: OutlineInputBorder()),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () {
                if (controller.text != "") {
                  setState(() {
                    searchUSer = controller.text.trim();
                    controller.clear();

                  });
                }
              },
              child: Text("Search!")),
          SizedBox(
            height: 10,
          ),
          StreamBuilder<QuerySnapshot>(
              stream: searchUSer==""
                  ? _firebaseFirestore
                      .collection("users")
                      .where("email",
                          isNotEqualTo: _firebaseAuth.currentUser!.email)
                      .snapshots()
                  : _firebaseFirestore
                      .collection("users")
                      .where("name", isEqualTo: searchUSer)
                      .where("email",
                          isNotEqualTo: _firebaseAuth.currentUser!.email)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  //print("comming here ${snapshot.data!.docs.length}");
                  if (snapshot.connectionState == ConnectionState.active) {
                    return Expanded(
                      child: snapshot.data!.docs.length > 0
                          ? ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                final Map<String, dynamic> usermap =
                                    snapshot.data!.docs[index].data()
                                        as Map<String, dynamic>; //Imp line

                                String title = usermap["name"];
                                String email = usermap["email"];
                                String image = usermap["Profileimage"];
                                String fullname = usermap["fullname"];

                                return ListTile(
                                  onTap: () async {
                                    //TODO: here i have to add my firebase locgic here ............
                                    otheruserID =
                                        await snapshot.data!.docs[index].id;
                                       CreateChatRoomID(otheruserID, title, image,
                                        _firebaseAuth.currentUser!.uid);
                                    print("indexis  $index");
                                  },
                                  leading: CircleAvatar(
                                      backgroundImage: image == ""
                                          ? AssetImage("images/profile.png")
                                          : NetworkImage(image)
                                              as ImageProvider),
                                  title: Text(

                                    fullname,
                                    style: GoogleFonts.lato(fontSize: 20),
                                  ),
                                  subtitle: Text(
                                   email,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.lato(fontSize: 15)),
                                  trailing: IconButton(
                                    onPressed: () async {
                                      //TODO: ON ICON PRESS HERE
                                    },
                                    icon: Icon(
                                      Icons.keyboard_arrow_right_outlined,
                                      size: 35,
                                    ),
                                  ),
                                );
                              })
                          : Center(
                              child: Text(
                              "No User Found!",
                              style: GoogleFonts.lato(fontSize: 40),
                            )),
                    );
                  }
                } else {
                  print("commig here!");
                  return CircularProgressIndicator();
                }
                return Container();
              }),
        ],
      ),
    );
  }
}
