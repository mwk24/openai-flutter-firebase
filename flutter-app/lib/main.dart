import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(body: MyHomePage()),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  bool firebaseInitialized = false;
  String currentConversationPath;
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    _initializeFirebase();
    super.initState();
  }

  void _initializeFirebase() async {
    await Firebase.initializeApp();
    //FirebaseFirestore.instance.settings = Settings(host: 'localhost:8080', sslEnabled: false);
    await _createNewConversation();

    setState(() {
      firebaseInitialized = true;
    });
  }

  Future _createNewConversation() async {
    DocumentReference ref = await FirebaseFirestore.instance.collection('conversations').add({
    });
    currentConversationPath = ref.path;
  }

  @override
  Widget build(BuildContext context) {
    if (!firebaseInitialized || currentConversationPath == null) {
      return Container();
    }

    CollectionReference messages = FirebaseFirestore.instance.collection(currentConversationPath +'/messages');
    return Stack(children: [
      StreamBuilder<QuerySnapshot>(
        stream: messages.orderBy('created', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Container();
          }

          if (snapshot.data.docs.length == 0) {
            addIntroMessage();
          }

          return Column(
            children: [
              Expanded(
                  child: Container(
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(gradient: 
                    LinearGradient(colors: [Colors.pink, Colors.purple])),
                  child: ListView(
                    reverse: true,
                    children: snapshot.data.docs.map((DocumentSnapshot document) {
                      return Container(
                        child: Text(document.data()['msg'].toString().trim(), style: TextStyle(height: 1.4, color: Colors.grey[900])),
                        padding: EdgeInsets.all(14),
                        margin: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: document.data()['author'] == 'AI' ? Colors.white : Colors.white70,
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        )
                      );
                    }).toList()
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 40),
                height: 100,
                child: Center(
                  child: TextField(
                    controller: textEditingController,
                    decoration: InputDecoration(
                      hintText: 'Message...',
                    ),
                    minLines: null,
                    maxLines: null,
                    onChanged: (value) { 
                      if (value.contains("\n")) {
                        sendMessage(value);
                      }
                    }
                  ),
                )
              )
            ],
          );    
        }),
        Align(
          alignment: Alignment.topCenter,
          child: ButtonBar(children: [
            RaisedButton(
              padding: EdgeInsets.all(6),
              color: Colors.white,
              onPressed: () async { await _createNewConversation(); setState(() {}); },
              child: Text('New conversation')
            )
          ],))
    ]);
  }

  void sendMessage(String message) {
    setState(() {
      textEditingController.clear();
    });
    FirebaseFirestore.instance.collection(currentConversationPath + "/messages").add({
      'author' : 'Human',
      'created' : FieldValue.serverTimestamp(),
      'msg' : message.trim(),
    });
  }

  void addIntroMessage() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.doc("settings/openai_config").get();

    FirebaseFirestore.instance.collection(currentConversationPath + "/messages").add({
      'author' : 'AI',
      'created' : FieldValue.serverTimestamp(),
      'msg' : doc.data()['first_question'],
    });
  }
}

