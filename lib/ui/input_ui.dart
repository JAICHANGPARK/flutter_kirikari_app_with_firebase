import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share/share.dart';

class _FormData {
  String borrowOrLend = "borrow";
  String user;
  String stuff;
  DateTime date = DateTime.now();
}

class InputForm extends StatefulWidget {
  final DocumentSnapshot document;
  final FirebaseUser firebaseUser;

  InputForm({this.document, this.firebaseUser});

  @override
  _InputFormState createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _FormData _data = _FormData();

  void _setLendOrRent(String value) {
    setState(() {
      _data.borrowOrLend = value;
    });
  }

  Future<DateTime> _selectTime(BuildContext context) {
    return showDatePicker(
        context: context,
        initialDate: _data.date,
        firstDate: DateTime(_data.date.year - 2),
        lastDate: DateTime(_data.date.year + 2));
  }

  @override
  Widget build(BuildContext context) {
    bool deleteFlag = false;
    DocumentReference _mainReference;
    _mainReference = Firestore.instance
        .collection('users')
        .document(widget.firebaseUser.uid)
        .collection("transaction")
        .document();
//    _mainReference = Firestore.instance.collection("kasikari-memo").document();
    if (widget.document != null) {
      if (_data.user == null && _data.stuff == null) {
        _data.borrowOrLend = widget.document['borrowOrLend'];
        _data.user = widget.document['user'];
        _data.stuff = widget.document['stuff'];
        _data.date = widget.document['date'];
      }
//      _mainReference = Firestore.instance
//          .collection('kasikari-memo')
//          .document(widget.document.documentID);
      _mainReference = Firestore.instance
          .collection('users')
          .document(widget.firebaseUser.uid)
          .collection("transaction")
          .document(widget.document.documentID);
      deleteFlag = true;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("かしかり入力"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
//              Scaffold.of(context)
//                  .showSnackBar(new SnackBar(content: Text("保存ボタンを押しました")));
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                _mainReference.setData({
                  'borrowOrLend': _data.borrowOrLend,
                  'user': _data.user,
                  'stuff': _data.stuff,
                  'date': _data.date
                });
                Navigator.pop(context);
              }
            },
          ),
          IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.white,
              ),
              onPressed: !deleteFlag
                  ? null
                  : () {
                _mainReference.delete();
                Navigator.pop(context);
              }),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                Share.share(
                    "【 " +
                        (_data.borrowOrLend == "lend" ? "貸" : "借") +
                        " 】" + _data.stuff +
                        "\n期限 : " + _data.date.toString().substring(0, 10) +
                        "\n相手 : " +  _data.user +
                        "\n#かしかりメモ"


                );
              }
            },
          )
        ],
      ),
      body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: 16.0,
                ),
                RadioListTile(
                    value: "borrow",
                    title: Text("借りた"),
                    groupValue: _data.borrowOrLend,
                    onChanged: (String value) {
                      print("借りたを");
                      _setLendOrRent(value);
                    }),
                RadioListTile(
                    value: "lend",
                    title: Text("貸した"),
                    groupValue: _data.borrowOrLend,
                    onChanged: (String value) {
                      print("貸したを");
                      _setLendOrRent(value);
                    }),
                TextFormField(
                  decoration: new InputDecoration(
                      icon: const Icon(Icons.person),
                      hintText: '相手の名前',
                      labelText: 'Name'),
                  onSaved: (String value) {
                    _data.user = value;
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return "名前は必修入力項目";
                    }
                  },
                  initialValue: _data.user,
                ),
                TextFormField(
                  decoration: new InputDecoration(
                      icon: const Icon(Icons.business_center),
                      hintText: '借りたもの、貸したもの',
                      labelText: 'loan'),
                  onSaved: (String value) {
                    _data.stuff = value;
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return "必修入力項目";
                    }
                  },
                  initialValue: _data.stuff,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                      "締め切り日:${_data.date.toString().substring(0, 10)}"),
                ),
                RaisedButton(
                  child: const Text("締め切り日変更"),
                  onPressed: () {
                    print("sima kiri ");
                    _selectTime(context).then((time) {
                      if (time != null && time != _data.date) {
                        setState(() {
                          _data.date = time;
                        });
                      }
//                      showTimePicker(context: context, initialTime:
//                      );
                    });
                  },
                )
              ],
            ),
          )),
    );
  }
}
