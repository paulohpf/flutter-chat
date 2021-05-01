import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  User _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    firebaseAuth.userChanges().listen((User user) {
      setState(() {
        _currentUser = user;
      });
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
      const SnackBar snackBar = SnackBar(
        content: Text('Não foi possivel fazer o login, tente novamente'),
        backgroundColor: Colors.red,
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    final Map<String, dynamic> data = <String, dynamic>{
      'uid': user.uid,
      'senderName': user.displayName,
      'senderPhotoURL': user.photoURL,
      'time': Timestamp.now()
    };

    if (imgFile != null) {
      final File file = File(imgFile.path);

      final UploadTask task = FirebaseStorage.instance
          .ref()
          .child(_currentUser.uid)
          .child(DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(file);

      setState(() {
        _isLoading = true;
      });

      final String url = await task.then((TaskSnapshot taskSnapshot) async {
        final String url = await taskSnapshot.ref.getDownloadURL();

        return url;
      });

      data['imgURL'] = url;

      setState(() {
        _isLoading = false;
      });
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
      // key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_currentUser != null
            ? 'Olá, ${_currentUser.displayName}'
            : 'Chat App'),
        centerTitle: true,
        elevation: 0,
        actions: <Widget>[
          if (_currentUser != null)
            IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () {
                  firebaseAuth.signOut();
                  googleSignIn.signOut();

                  const SnackBar snackBar = SnackBar(
                    content: Text('Você saiu com sucesso'),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                })
          else
            Container()
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  firestore.collection('messages').orderBy('time').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const Center(child: CircularProgressIndicator());

                  default:
                    final List<DocumentSnapshot> documents =
                        snapshot.data.docs.reversed.toList();

                    return ListView.builder(
                        itemCount: documents.length,
                        reverse: true,
                        itemBuilder: (BuildContext context, int index) {
                          return ChatMessage(
                              documents[index].data(),
                              documents[index].data()['uid'] ==
                                  _currentUser?.uid);
                        });
                }
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator() else Container(),
          TextComposer(_sendMessage),
        ],
      ),
    );
  }
}
