import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController? controllerNickname;
  TextEditingController? controllerAboutMe;

  SharedPreferences? prefs;

  String id = '';
  String nickname = '';
  String aboutMe = '';
  String photoUrl = '';
  bool isLoading = false;

  File? avatarImageFile;

  final FocusNode focusNodeNickname = FocusNode();
  final FocusNode focusNodeAboutMe = FocusNode();

  @override
  void initState() {
    readLocal();
    super.initState();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs!.getString('id') ?? '';
    nickname = prefs!.getString('nickname') ?? '';
    aboutMe = prefs!.getString('aboutMe') ?? '';
    photoUrl = prefs!.getString('photoUrl') ?? '';

    controllerNickname = TextEditingController(text: nickname);
    controllerAboutMe = TextEditingController(text: aboutMe);

    setState(() {});
  }

  Future getImage() async {
    var imagePicker = ImagePicker();

    var pickedFile;

    pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    File image = File(pickedFile.path);

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }
    uploadFile();
  }

  Future uploadFile() async {
    String fileName = id;
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(avatarImageFile!);
    TaskSnapshot storageTaskSnapshot;

    uploadTask.whenComplete(() => null).then((value) {
      if (value != null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          photoUrl = downloadUrl;
          FirebaseFirestore.instance.collection('users').doc(id).update({
            'nickname': nickname,
            'aboutMe': aboutMe,
            'photoUrl': photoUrl,
          }).then((data) async {
            await prefs!.setString('photoUrl', photoUrl);
            setState(() {
              isLoading = false;
            });
            var snackBar = SnackBar(content: Text('Upload Success'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }).catchError((err) {
            setState(() {
              isLoading = false;
            });
            var snackBar = SnackBar(content: Text('Upload Failed'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          });
        });
      } else {
        setState(() {
          isLoading = false;
        });
        var snackBar = SnackBar(content: Text('Upload Failed'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  void handleUpdateData() {
    focusNodeAboutMe.unfocus();
    focusNodeNickname.unfocus();
    setState(() {
      isLoading = true;
    });

    FirebaseFirestore.instance.collection('users').doc(id).update({
      'nickname': nickname,
      'aboutMe': aboutMe,
      'photoUrl': photoUrl,
    }).then((data) async {
      await prefs!.setString('nickname', nickname);
      await prefs!.setString('aboutMe', aboutMe);
      await prefs!.setString('photoUrl', photoUrl);

      setState(() {
        isLoading = false;
      });

      var snackBar = SnackBar(content: Text('Upload Success'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }).catchError((err) {
      setState(() {
        isLoading = false;

        var snackBar = SnackBar(content: Text('Upload Failed'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Profile')),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  child: Center(
                    child: Stack(
                      children: [
                        (avatarImageFile == null)
                            ? (photoUrl != ''
                                ? Material(
                                    child: CachedNetworkImage(
                                      placeholder: (context, url) => Container(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                        width: 90,
                                        height: 90,
                                        padding: EdgeInsets.all(20),
                                      ),
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                      imageUrl: photoUrl,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(45)),
                                    clipBehavior: Clip.hardEdge,
                                  )
                                : Icon(
                                    Icons.account_circle,
                                    size: 90,
                                    color: Colors.grey,
                                  ))
                            : Material(
                                child: Image.file(
                                  avatarImageFile!,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(45)),
                                clipBehavior: Clip.hardEdge,
                              ),
                        IconButton(
                          onPressed: getImage,
                          icon: Icon(Icons.camera_alt),
                          padding: EdgeInsets.all(30),
                          splashColor: Colors.transparent,
                          iconSize: 30,
                        ),
                      ],
                    ),
                  ),
                  width: double.infinity,
                  margin: EdgeInsets.all(20),
                ),

                // Input
                Column(
                  children: <Widget>[
                    // Username
                    Container(
                      child: Text(
                        'Nickname',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      margin:
                          EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                    ),
                    Container(
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(primaryColor: Colors.red),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Sweetie',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          controller: controllerNickname,
                          onChanged: (value) {
                            nickname = value;
                          },
                          focusNode: focusNodeNickname,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),

                    // About me
                    Container(
                      child: Text(
                        'About me',
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                      margin:
                          EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
                    ),
                    Container(
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(primaryColor: Colors.red),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Fun, like travel and play PES...',
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          controller: controllerAboutMe,
                          onChanged: (value) {
                            aboutMe = value;
                          },
                          focusNode: focusNodeAboutMe,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),

                // Button
                Container(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                      onSurface: Color(0xff8d93a0),
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                    ),
                    onPressed: handleUpdateData,
                    child: Text(
                      'UPDATE',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  margin: EdgeInsets.only(top: 50.0, bottom: 50.0),
                ),
              ],
            ),
            padding: EdgeInsets.only(left: 15.0, right: 15.0),
          ),

          // Loading
          Positioned(
            child: isLoading
                ? Container(
                    child: Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue)),
                    ),
                    color: Colors.white.withOpacity(0.8),
                  )
                : Container(),
          ),
        ],
      ),
    );
  }
}
