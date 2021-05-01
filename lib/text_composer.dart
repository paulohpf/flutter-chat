import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  const TextComposer(this.sendMessage);

  final Function({String text, PickedFile imgFile}) sendMessage;

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  final TextEditingController _controller = TextEditingController();

  bool _isComposing = false;

  void _reset() {
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          IconButton(
              icon: const Icon(Icons.photo_camera),
              onPressed: () async {
                final PickedFile imgFile = await ImagePicker().getImage(
                    source: ImageSource.camera,
                    maxHeight: 480,
                    maxWidth: 640,
                    imageQuality: 50);

                if (imgFile != null) {
                  widget.sendMessage(imgFile: imgFile);
                }
              }),
          Expanded(
              child: TextField(
            controller: _controller,
            decoration: const InputDecoration.collapsed(
                hintText: 'Enviar uma mensagem'),
            onChanged: (String text) {
              setState(() {
                _isComposing = text.isNotEmpty;
              });
            },
            onSubmitted: (String text) {
              widget.sendMessage(text: text);
              _reset();
            },
          )),
          IconButton(
              icon: const Icon(Icons.send),
              onPressed: _isComposing
                  ? () {
                      widget.sendMessage(text: _controller.text);
                      _reset();
                    }
                  : null),
        ],
      ),
    );
  }
}
