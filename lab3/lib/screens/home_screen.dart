import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_iti/screens/chat_screen.dart';
import 'package:chat_app_iti/screens/login_page.dart';
import 'package:chat_app_iti/screens/profile_screen.dart';
import 'package:chat_app_iti/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;
  const HomeScreen({required this.currentUserId, Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState(currentUserId: currentUserId);
}

class _HomeScreenState extends State<HomeScreen> {
  _HomeScreenState({Key? key, required this.currentUserId});
  final String currentUserId;
  Stream? mystream;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  int _limit = 20;
  int _limitIncrement = 20;
  bool isLoading = false;
  SharedPreferences? prefs;

  Future<bool> onBreakPress() {
    openDialog();
    return Future.value(false);
  }

  Future<Null> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: [
              Container(
                color: Colors.red,
                padding: EdgeInsets.only(top: 10, bottom: 10),
                height: 100,
                child: Column(
                  children: [
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10),
                    ),
                    Text(
                      'Exit App',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Are You Sure To Exit App ??',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: [
                    Container(
                      child: Icon(
                        Icons.cancel,
                        color: Colors.red,
                      ),
                      margin: EdgeInsets.only(right: 10),
                    ),
                    Text(
                      'CANCEL',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: [
                    Container(
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.red,
                      ),
                      margin: EdgeInsets.only(right: 10),
                    ),
                    Text(
                      'YES',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
    }
  }

  @override
  void initState() {
    getstream();
    super.initState();
  }

  getstream() async {
    prefs = await SharedPreferences.getInstance();
    var firebaseuser = await FirebaseAuth.instance.currentUser;
    print(firebaseuser!.email);
    setState(() {
      mystream = FirebaseFirestore.instance
          .collection('users')
          .limit(_limit)
          .snapshots();
    });
  }

  Future<Null> handleSignOut() async {
    setState(() {
      isLoading = true;
    });
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    prefs!.clear();
    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginPage()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => ProfileScreen()));
            },
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: onBreakPress,
        child: Stack(
          children: [
            StreamBuilder(
              stream: mystream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return ListView.builder(
                      itemBuilder: (context, index) => buildItem(context,
                          (snapshot.data as QuerySnapshot).docs[index]),
                      itemCount: (snapshot.data as QuerySnapshot).docs.length);
                }
              },
            ),
            Positioned(child: isLoading ? Loading() : Container())
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.logout),
        onPressed: () {
          handleSignOut();
        },
      ),
    );
  }

  Widget buildItem(BuildContext context, dynamic document) {
    if (document.get('id') == currentUserId) {
      return Container();
    } else {
      return Container(
        child: TextButton(
          style: TextButton.styleFrom(
            primary: Colors.grey,
            padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
          ),
          child: Row(
            children: <Widget>[
              Material(
                child: document.get('photoUrl') != null
                    ? CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            strokeWidth: 1.0,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                          width: 50.0,
                          height: 50.0,
                          padding: EdgeInsets.all(15.0),
                        ),
                        imageUrl: document.get('photoUrl'),
                        width: 50.0,
                        height: 50.0,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.account_circle,
                        size: 50.0,
                        color: Colors.grey,
                      ),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                clipBehavior: Clip.hardEdge,
              ),
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          'Nickname: ${document.data()['nickname']}',
                          style: TextStyle(color: Colors.red),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                      Container(
                        child: Text(
                          'About me: ${document.data()['aboutMe'] ?? 'Not available'}',
                          style: TextStyle(color: Colors.red),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                      )
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20.0),
                ),
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Chat(
                          peerId: document.id,
                          peerName: document.get('nickname'),
                          peerAvator: document.get('photoUrl'),
                        )));
          },
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
    }
  }
}
