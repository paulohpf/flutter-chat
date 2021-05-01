import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/chat_screen.dart';

void main() async {
  runApp(MyApp());

  await Firebase.initializeApp();

  // final FirebaseAuth auth = FirebaseAuth.instance;
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
