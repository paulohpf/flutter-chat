import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void _sendMessage({String text, PickedFile imgFile}) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final Map<String, dynamic> data = <String, dynamic>{};

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
      appBar: AppBar(
        title: const Text('Olá'),
        elevation: 0,
      ),
      body: TextComposer(_sendMessage),
    );
  }
}
