import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modu_messenger_firebase/api/chat_apis.dart';
import 'package:modu_messenger_firebase/screens/chat/chat_search_screen.dart';
import 'package:modu_messenger_firebase/screens/profile/profile_screen.dart';
import 'package:modu_messenger_firebase/widgets/chat_user_card.dart';

import '../../api/apis.dart';
import '../../api/user_apis.dart';
import '../../main.dart';
import '../../models/chat_model.dart';
import '../../models/user_model.dart';

// ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
// ┃                               채팅 메인 화면                               ┃
// ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // <내가 id가 포함된 채팅방 리스트> 초기화
  late List<ChatRoom> _chatRoomList = [];

  // 편집 status
  bool _isEditing = false;

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
        // Appbar - title
        title: const Text("쪽지"),
        // Appbar - leading
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
          // Appbar - actions - 검색 버튼 ( 개발 예정 )
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
          // Appbar - actions - 더보기 버튼 ( 개발 예정 )
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

        // ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
        // ┃   Body - StreamBuilder - 1. 내가 포함된 채팅방만 가져와서 _chatRoomList 에 저장 후 시간 순으로 정렬  ┃
        // ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: ChatAPIs.getMyChatRooms(),
            builder: (context, chatRoomsSnapshot) {
              switch (chatRoomsSnapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());
                case ConnectionState.active:
                case ConnectionState.done:
                  final data = chatRoomsSnapshot.data?.docs;
                  _chatRoomList = data?.map((e) => ChatRoom.fromJson(e.data())).toList() ?? [];
                  _chatRoomList.sort((a, b) => b.lastMsgDtm.compareTo(a.lastMsgDtm));

                  // ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
                  // ┃   Body - ListView.builder - 2. 받아온 채팅방 리스트의 member 리스트에서 내가 아닌 상대방 ID 가져와서 유저 정보 조회를 위한 ChatUser 생성 ┃
                  // ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
                  return ListView.builder(
                      padding: EdgeInsets.only(top: mq.height * .005),
                      itemCount: _chatRoomList.length,
                      itemBuilder: (context, index) {
                        // 채팅방은 무조건 나를 포함 하여 두명인 것으로 고정
                        ModuUser chatUser = ModuUser(
                            image: '', about: '', name: '', createdAt: '', isOnline: false, id: '', lastActive: '', email: '', pushToken: '');
                        // chatRoomList 의 member 리스트의 첫번째 ID가 나면 두번째 ID를 조회 parameter 저장
                        if (_chatRoomList[index].member[0] == APIs.me.id) {
                          chatUser.id = _chatRoomList[index].member[1];
                        }
                        // chatRoomList 의 member 리스트의 두번째 ID가 나면 첫번째 ID를 조회 parameter 저장
                        else {
                          chatUser.id = _chatRoomList[index].member[0];
                        }
                        // ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
                        // ┃   Body - StreamBuilder - 3. 위에서 넣은 chatUser.id 로 유저 정보 조회 하여 ChatUserCard 생성   ┃
                        // ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
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
                                  List<ModuUser> users = data?.map((e) => ModuUser.fromJson(e.data())).toList() ?? [];
                                  if (users.isNotEmpty) {
                                    return ChatUserCard(user: users[0]);
                                  } else {
                                    return const Center(
                                        child: Text(
                                      "유저가 존재 하지 않습니다.",
                                      style: TextStyle(color: Colors.white),
                                    ));
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
