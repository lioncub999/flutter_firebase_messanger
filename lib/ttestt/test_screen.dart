import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:modu_messenger_firebase/api/chat_apis.dart';
import 'package:modu_messenger_firebase/api/user_apis.dart';
import 'package:modu_messenger_firebase/screens/chat/chat_search_screen.dart';
import 'package:modu_messenger_firebase/screens/profile/profile_screen.dart';
import 'package:modu_messenger_firebase/widgets/chat_user_card.dart';

import '../../api/apis.dart';
import '../../main.dart';
import '../../models/chat_user_model.dart';
import '../../models/message_model.dart';

// ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
// ┃                                    ChatScreen                                    ┃
// ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
class testttt extends StatefulWidget {
  const testttt({super.key});

  @override
  State<testttt> createState() => _testtttState();
}

class _testtttState extends State<testttt> {
  // _ChatList <채팅방 리스트 데이터> 초기화
  late List<String> chatRoomList;
  late List<dynamic> chatMemberList;
  late List<String> chatMemberIdList = [];
  late List<ChatUser> myChatUserList = [];

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
      appBar: AppBar(title : Text("테스트용")),
      body: Text("테스트"),
    );
  }
}
