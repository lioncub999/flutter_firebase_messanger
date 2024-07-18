import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modu_messenger_firebase/api/chat_apis.dart';

import '../models/message_model.dart';

class TtestTScreen extends StatefulWidget {
  const TtestTScreen({super.key});

  @override
  State<TtestTScreen> createState() => _TtestTScreenState();
}

class _TtestTScreenState extends State<TtestTScreen> {
  List<String> chatRoomList = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: ChatAPIs.getMyChatRoomId(),
      builder: (context, chatRoomsSnapshot) {
        switch (chatRoomsSnapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return const Center(child: CircularProgressIndicator());
          case ConnectionState.active:
          case ConnectionState.done:
            final data = chatRoomsSnapshot.data?.docs;
            List<Message> list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

            if (list.isNotEmpty) {
              // chatRoomList를 초기화하고 다시 채웁니다.
              chatRoomList.clear();
              chatRoomList.addAll(chatRoomsSnapshot.data!.docs.map((e) => e.id));

              return ListView.builder(
                itemCount: chatRoomList.length,
                itemBuilder: (context, index) {
                  var chatRoomId = chatRoomList[index];
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

                          // 메시지를 시간 순서대로 정렬합니다.
                          list.sort((a, b) => b.sent.compareTo(a.sent));

                          if (list.isNotEmpty) {
                            return ListTile(
                              title: Text('Chat Room: $chatRoomId'),
                              subtitle: Text(list[0].msg),
                            );
                          } else {
                            return ListTile(
                              title: Text('Chat Room: $chatRoomId'),
                              subtitle: const Text("채팅이 없습니다."),
                            );
                          }
                      }
                    },
                  );
                },
              );
            } else {
              return const Center(
                child: Text("채팅이 없습니다."),
              );
            }
        }
      },
    );
  }
}
