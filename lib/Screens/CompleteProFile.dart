import 'dart:developer';
import 'dart:io';


import 'package:chatifay/Screens/SearchScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfile extends StatefulWidget {
  final String userID;

  CompleteProfile(this.userID);

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  File? finalimage;
  late String Url;
  TextEditingController Userfullname = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  void PickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source,imageQuality: 20);
      if (image != null) {
        CropImage(File(image.path));
      } else {
        return;
      }
    } catch (e) {
      print("error happned$e");
    }
  }

  void CropImage(File pickedImage) async {
    // Converting the Xfile inti File(io) type,
    CroppedFile? croppedFile =
    await ImageCropper().cropImage(
        sourcePath: pickedImage.path, compressQuality: 20);

    setState(() {
      finalimage = File(croppedFile!.path);
    });
  }

  void uploadData() async {
    String F_name = Userfullname.text.trim();
    if (F_name.isEmpty || finalimage == null) {
      print("please enter somthing");
    }else{

      // || is used when we need two condtions

    //......................................//

      TaskSnapshot snapshot = await _firebaseStorage.ref("profilePictures")
          .child(
          widget.userID)
          .putFile(finalimage!);
      Url = await snapshot.ref.getDownloadURL();
      print("this much time!!!!!!!!!!~~~~~~~~~~~~~~~~~~~");
      await _firestore.collection("users").doc(widget.userID).update({
        "Profileimage": Url,
        "fullname": F_name
      }).then((value) => Navigator.push(context, MaterialPageRoute(builder: (context)=>OnBoardScreen())));
    }



}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("Complete Profile!"),
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 10,
        ),
        CupertinoButton(
            child: CircleAvatar(
              radius: 60,
              backgroundImage: (finalimage != null)
                  ? FileImage(finalimage!) as ImageProvider
                  : AssetImage("images/profile.png"),
            ),
            onPressed: () {
              showPhotoptions();
            }),
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20, left: 20),
          child: TextField(
            controller: Userfullname,
            decoration: InputDecoration(
              hintText: "Full Name",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        ElevatedButton(
            onPressed: () {
              //print(finalimage);
              uploadData();
              //TODO: do on submit somthing
            },
            child: Text("Submit"))
      ],
    ),
  );
}

void showPhotoptions() {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Upload Your Photo",
            style: GoogleFonts.lato(fontSize: 25),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  PickImage(ImageSource.gallery);
                },
                leading: Icon(Icons.photo),
                title: Text(
                  "Select from Galary",
                  style: GoogleFonts.lato(fontSize: 20),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  //Fluttertoast.showToast(msg: "UnderConstruction");
                  PickImage(ImageSource.camera);
                },
                leading: Icon(Icons.camera),
                title: Text(
                  "Click from Camera",
                  style: GoogleFonts.lato(fontSize: 20),
                ),
              ),
            ],
          ),
        );
      });
}}
