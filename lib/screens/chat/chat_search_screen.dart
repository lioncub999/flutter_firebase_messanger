import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ChatSearchScreen extends StatefulWidget {
  const ChatSearchScreen({super.key});

  @override
  State<ChatSearchScreen> createState() => _ChatSearchScreenState();
}

class _ChatSearchScreenState extends State<ChatSearchScreen> {
  late FocusNode _focusNode;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNode = FocusNode();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'h1',
      child: Scaffold(
        appBar: AppBar(
          leading: Icon(null),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "취소",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
        body: Container(
          child: TextField(
            focusNode: _focusNode,
          ),
        ),
      ),
    );
  }
}
