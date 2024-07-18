import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modu_messenger_firebase/api/chat_apis.dart';

import '../main.dart';
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
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: ChatAPIs.getChatRooms(),
      builder: (context, chatRoomsSnapshot) {
        if (chatRoomsSnapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (chatRoomsSnapshot.hasError) {
          return Text('Error: ${chatRoomsSnapshot.error}');
        }

        if (!chatRoomsSnapshot.hasData || chatRoomsSnapshot.data!.docs.isEmpty) {
          return Text('No chat rooms found');
        }

        // Assuming you want to get the first chat room
        var chatRoomId = chatRoomsSnapshot.data!.docs[0].id;

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: ChatAPIs.getLatestMessage(chatRoomId),
          builder: (context, messagesSnapshot) {
            switch (messagesSnapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.none:
                return const Center(child: CircularProgressIndicator());
              case ConnectionState.active:
              case ConnectionState.done:
                final data = messagesSnapshot.data?.docs;
                List<Message> list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

                if (list.isNotEmpty) {
                  return Center(child: Text(list[0].));
                } else {
                  return const Center(
                    child: Text("채팅이 없습니다."),
                  );
                }
            }
          },
        );
      },
    );
  }
}
