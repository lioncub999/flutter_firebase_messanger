import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modu_messenger_firebase/helper/custom_dialogs.dart';
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
  // _ChatList 초기화
  List<ChatUser> _chatList = [];

  // _searchCatList 초기화
  final List<ChatUser> _searchChatList = [];

  // 검색 status
  bool _isSearching = false;

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
        title: _isSearching
            // 검색 활성화 TextField show
            ? TextField(
                // 포커스 노드 연결
                focusNode: _searchFocusNode,
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '이름을 입력 해주세요.',
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(fontSize: 17, letterSpacing: 0.5, color: Colors.white),
                // 검색창 타이핑 시 받아온 처음 받아온 데이터 에서 검색어 찾음 (클라 에서만 처리)
                onChanged: (val) {
                  _searchChatList.clear();
                  for (var i in _chatList) {
                    if (i.name.toLowerCase().contains(val.toLowerCase())) {
                      _searchChatList.add(i);
                    }
                  }
                  setState(() {
                    _searchChatList;
                  });
                },
              )
            // 검색 비활성화 TextField none
            : const Text("쪽지"),
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
                setState(() {
                  _isSearching = !_isSearching;
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (_isSearching) {
                      // 검색 버튼을 누르면 포커스 설정
                      FocusScope.of(context).requestFocus(_searchFocusNode);
                    } else {
                      // 검색 해제 시 포커스 해제
                      _searchFocusNode.unfocus();
                    }
                  });
                });
              },
              icon: Icon(_isSearching ? CupertinoIcons.clear_circled_solid : Icons.search)),
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
      body: GestureDetector(
        onTap: () {
        },
        child: Container(
          color: const Color.fromRGBO(56, 56, 60, 1), // chat background
          child: StreamBuilder(
              // 전체 유저 가져오기 (내가 포함된 채팅방만 가져오도록 수정 필요)
              stream: APIs.getAllUsers(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(child: CircularProgressIndicator());
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data?.docs;

                    // API로 받아온 데이터 ChatList 에 저장
                    _chatList = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
                    if (_chatList.isNotEmpty) {
                      return ListView.builder(
                        // _isSearching 값에 따라 검색리스트 or 전체리스트 보임
                        itemCount: _isSearching ? _searchChatList.length : _chatList.length,
                        padding: EdgeInsets.only(top: mq.height * 0.01),
                        itemBuilder: (context, index) {
                          return ChatUserCard(user: _isSearching ? _searchChatList[index] : _chatList[index], isEditing: _isEditing);
                        },
                      );
                    } else {
                      return const Center(
                        child: Text("채팅이 없습니다."),
                      );
                    }
                }
              }),
        ),
      ),
    );
  }
}
