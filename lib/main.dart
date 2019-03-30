import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:flutter_kirikari_app/ui/input_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share/share.dart';


void main() => runApp(MyApp());

FirebaseUser firebaseUser;
final FirebaseAuth _auth = FirebaseAuth.instance;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: <String, WidgetBuilder>{
        '/': (_) => Splash(),
        '/list': (_) => MyHomePage()
      },
      title: 'かしかりメモ',
      theme: ThemeData.dark()
//      home: MyHomePage(),
    );
  }
}

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  void _getUser(BuildContext context) async {
    try {
      firebaseUser = await _auth.currentUser();
      if (firebaseUser == null) {
        await _auth.signInAnonymously();
        firebaseUser = await _auth.currentUser();
      }
      Navigator.pushReplacementNamed(context, "/list");
    } catch (e) {
      Fluttertoast.showToast(msg: "Firebaseとの接続に失敗しました。");
    }
  }

  @override
  Widget build(BuildContext context) {
    _getUser(context);
    return Scaffold(
      body: Center(
        child: const Text("Splash Page"),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void showBasicDialog(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    String email, password;
    if (firebaseUser.isAnonymous) {
      print("사용자 익명 로그인");
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Login/ Register"),
              content: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                            icon: const Icon(Icons.email), labelText: 'Email'),
                        onSaved: (String value) {
                          email = value;
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Email Needed';
                          }
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            icon: const Icon(Icons.vpn_key),
                            labelText: 'password'),
                        onSaved: (String value) {
                          password = value;
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'password Needed';
                          }
                          if (value.length < 6) {
                            return 'Password longer than 6 ';
                          }
                        },
                      )
                    ],
                  )),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancle"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("douroku"),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      _createUser(context, email, password);
                    }
                  },
                ),
                FlatButton(
                  child: Text("Login"),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      _signIn(context, email, password);
                    }
                  },
                ),
              ],
            );
          });
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("확인다이얼로그"),
              content: Text(firebaseUser.email + " 로그인 중이다"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancle"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("SignOut"),
                  onPressed: () {
                    _auth.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                        context, "/", (_) => false);
                  },
                ),
              ],
            );
          });
    }
  }

  void _signIn(BuildContext context, String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
    } catch (e) {
      Fluttertoast.showToast(msg: "Firebase Login Failed");
    }
  }

  void _createUser(BuildContext context, String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
    } catch (e) {
      Fluttertoast.showToast(msg: "Firebase Login Failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("リスト画面"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              print("login");
              showBasicDialog(context);
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
//            stream: Firestore.instance.collection("kasikari-memo").snapshots(),
            stream: Firestore.instance
                .collection('users')
                .document(firebaseUser.uid)
                .collection("transaction")
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(),
                      Text("Loding..."),
                    ],
                  ),
                );
              } else {
                return ListView.builder(
                    padding: EdgeInsets.only(top: 18.0),
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      return _buildListItem(
                          context, snapshot.data.documents[index]);
                    });
              }
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => InputForm(
                      document: null,
                      firebaseUser: firebaseUser,
                    ),
                settings: new RouteSettings(name: "/new")),
          );
        },
        child: new Icon(Icons.check),
      ),
//      floatingActionButton: FloatingActionButton(
//        onPressed: _incrementCounter,
//        tooltip: 'Increment',
//        child: Icon(Icons.add),
//      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.memory),
            title: Text("【 " +
                (document['borrowOrLend'] == "lend" ? "貸" : "借") +
                " 】" +
                document['stuff']),
            subtitle: Text(" 期限 : " +
                document['date'].toString().substring(0, 10) +
                "\n 相手 : " +
                document['user']),
          ),
          ButtonTheme.bar(
            child: ButtonBar(
              children: <Widget>[
                FlatButton(
                  child: const Text("へんしゅう"),
                  onPressed: () {
                    Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("編集"
                            "ボタンを押しました")));
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InputForm(
                                  document: document,
                                  firebaseUser: firebaseUser,
                                ),
                            settings: new RouteSettings(name: "/edit")));
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
