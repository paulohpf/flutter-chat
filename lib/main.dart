import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/chat_screen.dart';

void main() async {
  runApp(MyApp());

  await Firebase.initializeApp();

  final FirebaseAuth auth = FirebaseAuth.instance;

  // auth.signInAnonymously();

  // auth.authStateChanges().listen((User user) {
  //   if (user == null) {
  //     print('User is currently signed out!');
  //   } else {
  //     print('User is signed in!');
  //   }
  // });

  // final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // firestore.collection('messages').snapshots().listen((QuerySnapshot event) {
  //   // ignore: avoid_function_literals_in_foreach_calls
  //   event.docChanges.forEach((DocumentChange event) {
  //     print(event.doc.id);
  //     print(event.doc.data());
  //   });
  // });

  // QuerySnapshot snapshot = await firestore.collection('messages').get();

  // snapshot.docs.forEach((QueryDocumentSnapshot doc) {
  //   print(doc.id);
  //   print(doc.data());
  //   print(doc.reference.update({'read': true}));
  // });

  // firestore.collection('messages').doc()
  //     // ignore: always_specify_types
  //     .set({'text': 'Hello World 2', 'from': 'Felipe Franco', 'read': false});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          iconTheme: const IconThemeData(color: Colors.blue)),
      home: ChatScreen(),
    );
  }
}
