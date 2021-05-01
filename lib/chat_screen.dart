import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  User _currentUser;

  @override
  void initState() {
    super.initState();

    firebaseAuth.userChanges().listen((User user) {
      _currentUser = user;
    });
  }

  Future<User> _getUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }

    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      final UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);

      return userCredential.user;
    } catch (err) {
      print(err);
    }
  }

  void _sendMessage({String text, PickedFile imgFile}) async {
    final User user = await _getUser();

    if (user == null) {
      setState(() {
        _scaffoldKey.currentState.showBottomSheet<void>(
            (BuildContext context) => const SnackBar(
                content:
                    Text('Não foi possivel fazer o login, tente novamente')));
      });
    }

    final Map<String, dynamic> data = <String, dynamic>{
      'uid': user.uid,
      'senderName': user.displayName,
      'senderPhotoURL': user.photoURL,
    };

    if (imgFile != null) {
      final File file = File(imgFile.path);

      final UploadTask task = FirebaseStorage.instance
          .ref()
          .child(DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(file);

      final String url = await task.then((TaskSnapshot taskSnapshot) async {
        final String url = await taskSnapshot.ref.getDownloadURL();

        return url;
      });

      data['imgURL'] = url;
    }

    if (text != null) {
      data['text'] = text;
    }

    // ignore: always_specify_types
    firestore.collection('messages').add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Olá'),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('messages').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const Center(child: CircularProgressIndicator());

                  default:
                    final List<DocumentSnapshot> documents = snapshot.data.docs;

                    return ListView.builder(
                        itemCount: documents.length,
                        reverse: true,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title:
                                Text(documents[index].data()['text'] as String),
                          );
                        });
                }
              },
            ),
          ),
          TextComposer(_sendMessage),
        ],
      ),
    );
  }
}
