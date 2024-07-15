import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:modu_messenger_firebase/api/apis.dart';
import 'package:modu_messenger_firebase/api/chat_apis.dart';
import 'package:modu_messenger_firebase/helper/custom_date_util.dart';
import 'package:modu_messenger_firebase/models/message_model.dart';
import 'package:modu_messenger_firebase/widgets/dialogs/profile_dialog.dart';

import '../main.dart';
import '../models/chat_user_model.dart';
import '../screens/chat/chat_room_screen.dart';

// ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
// ┃                                  ChatUserCard                                    ┃
// ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key, required this.user});

  final ChatUser user;

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  // 마지막 대화 내용 (null 이면 대화 기록 없음)
  Message? _lastMessage;

  @override
  Widget build(BuildContext context) {
    // ┏━━━━━━━━━━┓
    // ┃   Card   ┃
    // ┗━━━━━━━━━━┛
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: 4),
      child: InkWell(
          onTap: () {
            // Card 클릭 시 유저 채팅방 으로 이동
            Navigator.push(context, MaterialPageRoute(builder: (_) => ChatRoomScreen(user: widget.user)));
          },
          child: StreamBuilder(
              // 채팅방 마지막 대화 가져와서 _lastMessage 에 담기
              stream: ChatAPIs.getLastMessage(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
                if (list.isNotEmpty) {
                  _lastMessage = list[0];
                }
                return ListTile(
                  // ┏━━━━━━━━━━━━━━━━━┓
                  // ┃   프로필 사진   ┃
                  // ┗━━━━━━━━━━━━━━━━━┛
                  leading: InkWell(
                    // 프로필 사진 선택시 유저 정보 Dialog
                    onTap: () {
                      showDialog(context: context, builder: (_) => ProfileDialog(user: widget.user));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.width * .3),
                      child: CachedNetworkImage(
                        width: mq.width * .15,
                        height: mq.width * .15,
                        fit: BoxFit.cover,
                        imageUrl: widget.user.image,
                        // 프로필 사진 로딩
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        // 프로필 사진 가져오기 실패
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                  ),
                  // ┏━━━━━━━━━━━━━━━━━┓
                  // ┃   대화방 정보   ┃
                  // ┗━━━━━━━━━━━━━━━━━┛
                  title: Text(widget.user.name),
                  subtitle: Text(
                    _lastMessage != null
                        ? _lastMessage!.type == Type.image
                            ? '사진'
                            : _lastMessage!.msg
                        : "",
                    maxLines: 1,
                  ),
                  // ┏━━━━━━━━━━━━━━━━━━━━━━┓
                  // ┃   마지막 대화 시간   ┃
                  // ┗━━━━━━━━━━━━━━━━━━━━━━┛
                  trailing: _lastMessage == null
                      ? const Text('')
                      // 마지막 메시지 안읽었고, 보낸사람이 내가 아니면
                      : _lastMessage!.read.isEmpty && _lastMessage!.fromId != APIs.user.uid
                          ? Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(color: Colors.greenAccent.shade400, borderRadius: BorderRadius.circular(10)),
                            )
                          : Text(
                              CustomDateUtil.getLastMessageTime(context: context, time: _lastMessage!.sent),
                              style: TextStyle(color: Colors.black54),
                            ),
                );
              })),
    );
  }
}
