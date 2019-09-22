import 'dart:async';

import 'package:firebase_phone_auth/main.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

class DashboardPage extends StatefulWidget {
  String uid;
  DashboardPage({this.uid});
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {


  getUid() {}

  @override
  void initState() {
    this.widget.uid = '';
    FirebaseAuth.instance.currentUser().then((val) {
      setState(() {
        this.widget.uid = val.uid;
      });
    }).catchError((e) {
      print(e);
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Dashboard'),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text('You are now logged in as ${widget.uid}'),
                SizedBox(
                  height: 15.0,
                ),
                new OutlineButton(
                  borderSide: BorderSide(
                      color: Colors.red, style: BorderStyle.solid, width: 3.0),
                  child: Text('Logout'),
                  onPressed: () {
                    FirebaseAuth.instance.signOut().then((action) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyApp()),
                      );
                    }).catchError((e) {
                      print(e);
                    });
                  },
                ),
              ],
            ),
          ),
        ));
  }
}