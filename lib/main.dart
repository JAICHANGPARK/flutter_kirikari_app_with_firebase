import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'かしかりメモ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("リスト画面"),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection("kasikari-memo").snapshots(),
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
                    itemBuilder: (context, index){
                      return _buildListItem(context, snapshot.data.documents[index]);
                    });
              }
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document){
    return Card(
      child:Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.memory),
            title: Text("【 " + (document['borrowOrLend'] == "lend"?"貸":"借") +
            " 】" + document['stuff']),
            subtitle: Text(" 期限 : " + document['date'].toString().substring(0, 10)
            + "\n 相手 : " + document['user']),
          ),

          ButtonTheme.bar(
            child: ButtonBar(
              children: <Widget>[
                FlatButton(
                  child: const Text("へんしゅう"),
                  onPressed: (){
                    Scaffold.of(context).showSnackBar(SnackBar(content: Text("編集"
                        "ボタンを押しました")));
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
