import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:modu_messenger_firebase/api/chat_apis.dart';
import 'package:modu_messenger_firebase/screens/chat/chat_search_screen.dart';
import 'package:modu_messenger_firebase/screens/profile/profile_screen.dart';
import 'package:modu_messenger_firebase/widgets/chat_user_card.dart';

import '../../api/apis.dart';
import '../../main.dart';
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
  List<ChatUser> _chatUserList = [];

  // _searchCatList 초기화
  final List<ChatUser> _searchChatList = [];

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
        child: StreamBuilder(
            // 전체 유저 가져오기 (내가 포함된 채팅방만 가져오도록 수정 필요)
            stream: ChatAPIs.getAllUsers(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());
                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data?.docs;

                  // API로 받아온 데이터 ChatUserList 에 저장
                  _chatUserList = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
                  if (_chatUserList.isNotEmpty) {
                    return ListView.builder(
                      // 전체 대화 리스트
                      itemCount: _chatUserList.length,
                      padding: EdgeInsets.only(top: mq.height * 0.01),
                      itemBuilder: (context, index) {
                        return ChatUserCard(user: _chatUserList[index]);
                      },
                    );
                  } else {
                    return const Center(
                      child: Text("채팅이 없습니다."),
                    );
                  }
              }
            }
            ),
      ),
    );
  }
}
