import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_phone_auth/homepage.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Firebase PhoneAuth'),
        routes: <String, WidgetBuilder>{
          '/homepage': (BuildContext context) => DashboardPage(),
          '/landingpage': (BuildContext context) => MyHomePage()
        });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String phoneNo;
  String uid;
  String smsCode;
  String verificationId;
  FirebaseAuth _auth = FirebaseAuth.instance;


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
            padding: EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(hintText: 'Enter Phone number'),
                  onChanged: (value) {
                    this.phoneNo = value;
                  },
                ),
                SizedBox(height: 10.0),
                RaisedButton(
                    onPressed: () => verifyPhone(),
                    child: Text('Verify'),
                    textColor: Colors.white,
                    elevation: 7.0,
                    color: Colors.blue)
              ],
            )),
      ),
    );
  }

  Future<void> verifyPhone() async {

    _auth.currentUser().then((user) async {
      if (user != null) {
        print("User is not null");
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage(uid: user.uid,)),
        );
      } else {

        final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
          this.verificationId = verId;
        }; // this will auto click the verification button

        final PhoneCodeSent smsCodeSent =
            (String verId, [int forceCodeResend]) {
          this.verificationId = verId;
          smsCodeDialog(context).then((value) {
            print("Signed In");
          });
        };

        final PhoneVerificationCompleted verificationCompleted =
            (AuthCredential user) {
          print('verified');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DashboardPage()),
          );
        };

        final PhoneVerificationFailed verificationFailed =
            (AuthException expection) {
          print(expection.message);
        };

        await FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: this.phoneNo,
            timeout: const Duration(seconds: 5),
            verificationCompleted: verificationCompleted,
            verificationFailed: verificationFailed,
            codeSent: smsCodeSent,
            codeAutoRetrievalTimeout: autoRetrieve);
      }
    });
  }

  Future<bool> smsCodeDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Enter sms Code'),
            content: TextField(
              onChanged: (value) {
                this.smsCode = value;
              },
            ),
            contentPadding: EdgeInsets.all(10.0),
            actions: <Widget>[
              new FlatButton(
                child: Text('Done'),
                onPressed: () {
                  _auth.currentUser().then((user) {
                    if (user != null) {
                      print("User is not null");
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DashboardPage(uid: user.uid)),
                      );
                    } else {
                      print("User is null");
                      Navigator.of(context).pop();
                      signIn(smsCode);
// Find the Scaffold in the widget tree and use it to show a SnackBar.

                    }
                  });
                },
              )
            ],
          );
        });
  }

  signIn(String smsCode) async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    FirebaseAuth.instance.currentUser().then((val) {
      setState(() {
        this.uid = val.uid;
      });
    }).catchError((e) {
      print(e);
    });

    FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseUser user =
        await _auth.signInWithCredential(credential).then((user) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DashboardPage(uid: user.user.uid)),
      );
    }).catchError((e) {
      print(e);
    });


  }



}
