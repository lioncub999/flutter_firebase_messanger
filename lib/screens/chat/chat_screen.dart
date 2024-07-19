import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modu_messenger_firebase/api/chat_apis.dart';
import 'package:modu_messenger_firebase/screens/chat/chat_search_screen.dart';
import 'package:modu_messenger_firebase/screens/profile/profile_screen.dart';
import 'package:modu_messenger_firebase/widgets/chat_user_card.dart';

import '../../api/apis.dart';
import '../../api/user_apis.dart';
import '../../main.dart';
import '../../models/chat_room_model.dart';
import '../../models/chat_user_model.dart';

// ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
// ┃                                    ChatScreen                                    ┃
// ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // _ChatList <채팅방 리스트 데이터> 초기화
  late List<ChatRoom> chatRoomList = [];

  // 편집 status
  bool _isEditing = false;

  // FocusNode 초기화
  final FocusNode _searchFocusNode = FocusNode();

  // ┏━━━━━━━━━━━━━┓
  // ┃   dispose   ┃
  // ┗━━━━━━━━━━━━━┛
  @override
  void dispose() {
    // FocusNode 해제
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ┏━━━━━━━━━━━━━━━┓
  // ┃   initState   ┃
  // ┗━━━━━━━━━━━━━━━┛
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ┏━━━━━━━━━━━━┓
      // ┃   AppBar   ┃
      // ┗━━━━━━━━━━━━┛
      appBar: AppBar(
        // Appbar - title 검색
        title: const Text("쪽지"),
        // Appbar - actions
        leading: TextButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            child: Text(
              _isEditing ? "완료" : "편집",
              style: TextStyle(color: _isEditing ? Colors.yellow : Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            )),
        // Appbar - actions
        actions: [
          // Appbar - actions - 검색 버튼
          IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const ChatSearchScreen(),
                    transitionDuration: const Duration(milliseconds: 1000),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      var begin = const Offset(1.0, 0.0);
                      var end = Offset.zero;
                      var curve = Curves.easeOut;

                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                );
              },
              icon: const Icon(Icons.search)),
          // Appbar - actions - 더보기 버튼
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(user: APIs.me)));
              },
              icon: const Icon(Icons.more_vert))
        ],
      ),
      // ┏━━━━━━━━━━┓
      // ┃   Body   ┃
      // ┗━━━━━━━━━━┛
      body: Container(
        width: mq.width,
        height: mq.height,
        color: const Color.fromRGBO(56, 56, 60, 1), // chat background
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            // 내가 포함된 채팅방만 가져오기
            stream: ChatAPIs.getMyChatRooms(),
            builder: (context, chatRoomsSnapshot) {
              switch (chatRoomsSnapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());
                case ConnectionState.active:
                case ConnectionState.done:
                  final data = chatRoomsSnapshot.data?.docs;
                  // chatRoom
                  chatRoomList = data?.map((e) => ChatRoom.fromJson(e.data())).toList() ?? [];
                  chatRoomList.sort((a, b) => b.lastMsgDtm.compareTo(a.lastMsgDtm));

                  return ListView.builder(
                      padding: EdgeInsets.only(top: mq.height * .005),
                      itemCount: chatRoomList.length,
                      itemBuilder: (context, index) {
                        ChatUser chatUser = ChatUser(
                            image: '', about: '', name: '', createdAt: '', isOnline: false, id: '', lastActive: '', email: '', pushToken: '');
                        if (chatRoomList[index].member[0] == APIs.me.id) {
                          chatUser.id = chatRoomList[index].member[1];
                        } else {
                          chatUser.id = chatRoomList[index].member[0];
                        }
                        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: UserAPIs.getUserInfo(chatUser),
                            builder: (context, userSnapshot) {
                              switch (userSnapshot.connectionState) {
                                case ConnectionState.waiting:
                                case ConnectionState.none:
                                  return const Center(child: CircularProgressIndicator());
                                case ConnectionState.active:
                                case ConnectionState.done:
                                  final data = userSnapshot.data?.docs;
                                  List<ChatUser> users = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
                                  if (users.isNotEmpty) {
                                    return ChatUserCard(user: users[0]);
                                  } else {
                                    return Text("값이 없음");
                                  }
                              }
                            });
                      });
              }
            }),
      ),
    );
  }
}
