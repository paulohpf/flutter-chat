import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/chat_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
                primarySwatch: Colors.blue,
                iconTheme: const IconThemeData(color: Colors.blue)),
            home: home(snapshot),
          );
        });
  }

  Widget home(AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      return ChatScreen();
    }

    return Column(
      children: const <Widget>[
        Expanded(child: Center(child: CircularProgressIndicator()))
      ],
    );
  }
}
