import 'package:flutter/material.dart';
import 'package:modu_messenger_firebase/api/chat_apis.dart';

import '../models/chat_user_model.dart';
import '../models/message_model.dart';

class TtestTScreen extends StatefulWidget {
  const TtestTScreen({super.key});

  @override
  State<TtestTScreen> createState() => _TtestTScreenState();
}

class _TtestTScreenState extends State<TtestTScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder(
        stream: ChatAPIs.getMyChatRoom(),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
          return ListTile(
            leading: InkWell(
              onTap: (){},
              child: Container(
                child: Text(list.length.toString()),
              ),
            ),
          );
        },
      ),
      // child: Text("asd"),
    );
  }
}
