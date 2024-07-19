import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modu_messenger_firebase/api/chat_apis.dart';
import 'package:modu_messenger_firebase/api/talk_apis.dart';
import 'package:modu_messenger_firebase/screens/chat/chat_search_screen.dart';
import 'package:modu_messenger_firebase/screens/profile/profile_screen.dart';
import 'package:modu_messenger_firebase/widgets/chat_user_card.dart';

import '../../api/apis.dart';
import '../../api/user_apis.dart';
import '../../main.dart';
import '../../models/chat_model.dart';
import '../../models/talk_model.dart';
import '../../models/user_model.dart';

// ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
// ┃                                    TalkScreen                                    ┃
// ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
class TalkScreen extends StatefulWidget {
  const TalkScreen({super.key});

  @override
  State<TalkScreen> createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  // <토크 리스트> 초기화
  late List<Talk> _talkList = [];

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
          title: const Text("토크"),
          // Appbar - leading
          leading: Row(
            children: [
              // 단체 쪽지 전송
              IconButton(onPressed: () {}, icon: Icon(Icons.message))
            ],
          ),
          // Appbar - actions
          actions: [
            // Appbar - actions - 검색 버튼
          ]),
      // ┏━━━━━━━━━━┓
      // ┃   Body   ┃
      // ┗━━━━━━━━━━┛
      body: Container(
        child: Column(
          children: [
            // 내가 즐겨찾기 한 유저 스토리 보여주기 ( 구현 예정 )
            Container(
                color: Colors.black,
                width: mq.width,
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 50,
                  itemBuilder: (context, index) {
                    return Text("asd  ", style: TextStyle(color: Colors.red),);
                  },
                )),
            Expanded(
                child: Container(
                    color: const Color.fromRGBO(56, 56, 60, 1),
                    child: FutureBuilder(
                      future: TalkAPIs.getAllTalks(),
                      builder: (context, talkSnapshot) {
                        switch (talkSnapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const Center(child: CircularProgressIndicator());
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = talkSnapshot.data?.docs;
                            _talkList = data?.map((e) => Talk.fromJson(e.data())).toList() ?? [];
                            return ListView.builder(
                                itemCount: _talkList.length,
                                itemBuilder: (context, index) {
                                  ModuUser talkUser = ModuUser(
                                      image: '',
                                      about: '',
                                      name: '',
                                      createdAt: '',
                                      isOnline: false,
                                      id: _talkList[index].creUserId,
                                      lastActive: '',
                                      email: '',
                                      pushToken: '');
                                  return StreamBuilder(
                                      stream: UserAPIs.getUserInfo(talkUser),
                                      builder: (context, talkUserSnapshot) {
                                        switch (talkSnapshot.connectionState) {
                                          case ConnectionState.waiting:
                                          case ConnectionState.none:
                                            return const Center(child: CircularProgressIndicator());
                                          case ConnectionState.active:
                                          case ConnectionState.done:
                                            final data = talkUserSnapshot.data?.docs;
                                            List<ModuUser> users = data?.map((e) => ModuUser.fromJson(e.data())).toList() ?? [];
                                            if (_talkList.isNotEmpty) {
                                              if (users.isNotEmpty) {
                                                return Text(
                                                  "${users[0].name} + ${_talkList[index].cont}",
                                                  style: TextStyle(color: Colors.white),
                                                );
                                              } else {
                                                print(_talkList[index].creUserId);
                                                return const Center(
                                                    child: Text(
                                                      "유저가 존재 하지 않습니다.",
                                                      style: TextStyle(color: Colors.white),
                                                    ));
                                              }
                                            } else {
                                              return const Center(
                                                  child: Text(
                                                    "토크가 존재 하지 않습니다.",
                                                    style: TextStyle(color: Colors.white),
                                                  ));
                                            }
                                        }
                                      });
                                });
                        }
                      },
                    )))
          ],
        ),
      ),
    );
  }
}
