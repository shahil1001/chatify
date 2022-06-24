import 'package:chatifay/Screens/ChatRoomPage.dart';
import 'package:chatifay/Screens/SearchScreen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class UsresListScreen extends StatefulWidget {
  String ID;

  UsresListScreen(this.ID);

  @override
  State<UsresListScreen> createState() => _UsresListScreenState();
}

class _UsresListScreenState extends State<UsresListScreen> {
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final f = new DateFormat('h:mm a');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff5A61B6).withOpacity(0.8),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Chatifay!",
                      style: GoogleFonts.lato(
                          fontSize: 50,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  Text(" Let's chat...",
                      style:
                          GoogleFonts.lato(fontSize: 25, color: Colors.white)),
                ],
              ),
            ),
            Container(
              height: 65,
              margin: EdgeInsets.only(top: 20),
              child: StreamBuilder<QuerySnapshot>(
                stream: _firebaseFirestore
                    .collection("users")
                    .where("email",
                        isNotEqualTo: _firebaseAuth.currentUser!.email)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      return Container(
                        height: 80,
                        child: ListView.separated(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final Map<String, dynamic> usermap =
                                  snapshot.data!.docs[index].data()
                                      as Map<String, dynamic>; //Imp line

                              String image = usermap["Profileimage"];

                              return CircleAvatar(
                                  radius: 40,
                                  backgroundImage: image == ""
                                      ? AssetImage("images/profile.png")
                                      : NetworkImage(image) as ImageProvider);
                            },
                            separatorBuilder: (context, index) {
                              return SizedBox(
                                width: 10,
                              );
                            },
                            itemCount: snapshot.data!.docs.length),
                      );
                    }
                  }

                  return Container();
                },
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 20),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: Column(
                  children: [
                    Text(
                      "Recent chats!",
                      style: GoogleFonts.lato(
                          fontSize: 22, fontWeight: FontWeight.w300),
                    ),
                    Divider(
                      color: Colors.grey,
                      thickness: 0.5,
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                          stream: _firebaseFirestore
                              .collection("chatrooms")
                              .orderBy("timestamp", descending: true)
                              .where("particepents.${widget.ID}",
                                  isEqualTo: true)
                              .snapshots(),
                          builder: (context, msnapshot) {
                            if (msnapshot.connectionState ==
                                ConnectionState.active) {
                              if (msnapshot.hasData) {
                                print("yes1  ${msnapshot.data!.docs.length}");
                                QuerySnapshot chatRoomSnapshot =
                                    msnapshot.data as QuerySnapshot;

                                return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: chatRoomSnapshot.docs.length,
                                    itemBuilder: (context, index) {
                                      Map<String, dynamic> participants =
                                          chatRoomSnapshot.docs[index]
                                                  .get("particepents")
                                              as Map<String, dynamic>;
                                      participants.keys.toList();
                                      participants.remove("time");
                                      participants.remove(
                                          _firebaseAuth.currentUser!.uid);
                                      String lm = chatRoomSnapshot.docs[index]
                                          .get("lastmessage");
                                      bool online = chatRoomSnapshot.docs[index]
                                          .get("online");

                                      return FutureBuilder(
                                          future: _firebaseFirestore
                                              .collection("users")
                                              .doc(
                                                  participants.keys.toList()[0])
                                              .get(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.done) {
                                              if (snapshot.hasData) {
                                                //Imp line
                                                DocumentSnapshot data = snapshot
                                                    .data as DocumentSnapshot;

                                                String name = data.get("name");
                                                Timestamp time =
                                                    data.get("time");
                                                String image =
                                                    data.get("Profileimage");
                                                //String fullname = usermap["fullname"];
                                                return ListTile(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ChatRoomPage(
                                                                    name,
                                                                    image,
                                                                    chatRoomSnapshot
                                                                        .docs[
                                                                            index]
                                                                        .get(
                                                                            "chatroomID"),
                                                                    widget
                                                                        .ID)));
                                                  },
                                                  leading: CircleAvatar(
                                                    radius: 25,
                                                    backgroundImage: image == ""
                                                        ? AssetImage(
                                                            "images/profile.png")
                                                        : NetworkImage(image)
                                                            as ImageProvider,
                                                    child:online? Stack(children: [
                                                      Align(
                                                          alignment: Alignment
                                                              .bottomRight,
                                                          child: CircleAvatar(
                                                              radius: 8,
                                                              backgroundColor:
                                                                  Colors.white,
                                                              child: CircleAvatar(
                                                                  radius: 5,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .green)))
                                                    ]):Container(),
                                                  ),
                                                  title: Text(
                                                    name,
                                                    style: GoogleFonts.lato(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                  subtitle: lm != ""
                                                      ? Text(
                                                          lm,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              GoogleFonts.lato(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                        )
                                                      : Text(
                                                          "Say Hi to your new friend",
                                                          style: GoogleFonts.lato(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .blueAccent),
                                                        ),
                                                  trailing: Text(
                                                      f.format(time.toDate())),
                                                );
                                              } else {
                                                //NO data
                                                print("nodata");
                                              }
                                            } else {
                                              //Not connected
                                              print("Not even connetcted");
                                            }
                                            return Container();
                                          });
                                    });
                              }
                            } else {
                              return Expanded(
                                  child: Center(
                                      child: Text(
                                          "NO recent Chats here.. starting chatting !")));
                            }
                            return Container(
                              color: Colors.white,
                            );
                          }),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => OnBoardScreen()));
        },
        child: Icon(Icons.search),
      ),
    );
  }
}
