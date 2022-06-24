import 'package:chatifay/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ChatRoomPage extends StatefulWidget {
  String name, imageofuser, myID;
  String ChatroomID;

  ChatRoomPage(this.name, this.imageofuser, this.ChatroomID, this.myID);

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage>
    with WidgetsBindingObserver {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController msg = TextEditingController();
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late String MYID;
   bool online=false;
   Timestamp time=Timestamp.now();
  final f = new DateFormat('h:mm a');

  SendMessage() {
    print(widget.myID);
    String message = msg.text.toString();
    msg.clear();
    if (message != "") {
      _firestore
          .collection("chatrooms")
          .doc(widget.ChatroomID)
          .collection("messages")
          .add({
        "seen": false,
        "sender": widget.myID,
        "messageID": key.v1(),
        "timestamp": Timestamp.now(),
        "text": message
      });

      _firestore.collection("chatrooms").doc(widget.ChatroomID).update({
        "lastmessage": message,
        "timestamp": Timestamp.now(),
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    getCurrentUse();
    getOnlineStatus();
  }

  void getCurrentUse() async {
    MYID = await _firebaseAuth.currentUser!.uid;
  }

  void getOnlineStatus() async {
    await for (var snapshot in _firestore
        .collection("chatrooms")
        .doc(widget.ChatroomID)
        .snapshots()) {
      setState(() {
        online = snapshot.get("online");
        time = snapshot.get("timestamp");
        print("time is here $time");
      });
    }

  }
  Future<void> seenMethod() async{

    final query = await _firestore
        .collection('chatrooms')
        .doc(widget.ChatroomID)
        .collection('messages')
        .where('sender', isEqualTo: widget.myID)
        .where('seen', isEqualTo: false)
        .get();

    query.docs.forEach((doc) {
      doc.reference.update({'seen': true}).then((value) => print("yeeeeeeeeeeeeeeeeeee!"));
    });

  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      //TODO set status online in firestore
      _firestore.collection("chatrooms").doc(widget.ChatroomID).update({
        "online": true,
        // "seen": false,
      });




    } else {
      //TODO set status offline in firestore
      _firestore.collection("chatrooms").doc(widget.ChatroomID).update({
        "online": false,
        // "seen": false,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    seenMethod();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.imageofuser.isEmpty
                  ? AssetImage("images/profile.png")
                  : NetworkImage(widget.imageofuser) as ImageProvider,
            ),
            SizedBox(
              width: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: GoogleFonts.lato(
                      fontSize: 25, fontWeight: FontWeight.bold),
                ),
                online
                    ? Text(
                        "online",
                        style: GoogleFonts.lato(
                          fontSize: 15,
                        ),
                      )
                    : Text(
                        "last seen at ${f.format(time.toDate())}",
                        style: GoogleFonts.lato(
                          fontSize: 15,
                        ),
                      ),
              ],
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection("chatrooms")
                      .doc(widget.ChatroomID)
                      .collection("messages")
                      .orderBy("timestamp", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    List<Widget> messagesWidget = [];

                    if (snapshot.hasData) {
                      final messages = snapshot.data?.docs;

                      //print("comming here ${snapshot.data!.docs.length}");
                      if (snapshot.connectionState == ConnectionState.active) {
                        for (var msg in messages!) {
                          String msgID = msg.get("sender");
                          String usermsg = msg.get("text");
                          String SenderID = msg.get("sender");
                          bool seen = msg.get("seen");
                          var timestamp = msg.get("timestamp");
                          final messageWidget = // this is a new variable
                              MessagesBubble(
                                  usermsg,
                                  SenderID == MYID ? "you" : "other",
                                  SenderID == MYID ? true : false,
                                  timestamp,
                                  seen,widget.imageofuser);
                          // Text("$message by $messagSender" )
                          messagesWidget.add(messageWidget);
                        }
                      }
                    } else {
                      print("commig here!");
                      return CircularProgressIndicator();
                    }
                    return Expanded(
                      child: ListView(reverse: true, children: messagesWidget),
                    );
                  })
            ],
          )),

          // Container for messageTextEditing.
          Container(
            color: Colors.grey[200],
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: TextField(
                        controller: msg,
                        maxLines: null,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter Message"),
                      )),
                ),
                IconButton(
                    onPressed: () {
                      SendMessage();
                    },
                    icon: Icon(Icons.send))
              ],
            ),
          )
        ],
      ),
    );
  }


}

class MessagesBubble extends StatelessWidget {
  String Meessage, sendby;
  bool Isme, seen;
  Timestamp time;
String imageofUser;
  MessagesBubble(this.Meessage, this.sendby, this.Isme, this.time, this.seen,this.imageofUser);

  final f = new DateFormat('h:mm a');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
        Isme ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            "  $sendby",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          Row(
            mainAxisAlignment:
            Isme ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Isme? Container(): CircleAvatar(
                radius: 20,
                backgroundImage:imageofUser.isEmpty
                    ? AssetImage("images/profile.png")
                    : NetworkImage(imageofUser) as ImageProvider,
              ),
              Material(
                borderRadius: Isme
                    ? BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                )
                    : BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                elevation: 16,
                color: Isme ? Colors.blueAccent : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Text(
                    '${Meessage.trim()}',
                    style: GoogleFonts.lato(
                        fontSize: 18, color: Isme ? Colors.white : Colors.black),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: Isme?MainAxisAlignment.end:MainAxisAlignment.start,
            children: [
              Text(
                "  ${f.format(time.toDate())}",
                style: GoogleFonts.lato(fontSize: 12),
              ),
              SizedBox(
                width: 10,
              ),
              Isme? seen
                  ? Icon(
                Icons.done_all,
                color: Colors.green,
              )
                  : Icon(
                Icons.done_all,
              ):Container(),
            ],
          )
        ],
      ),
    );
  }
}

