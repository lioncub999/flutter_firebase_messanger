import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modu_messenger_firebase/api/talk_apis.dart';
import 'package:modu_messenger_firebase/widgets/talk_card.dart';

import '../../api/user_apis.dart';
import '../../main.dart';
import '../../models/talk_model.dart';
import '../../models/user_model.dart';

// ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
// ┃                               토크 메인 화면                               ┃
// ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
class TalkScreen extends StatefulWidget {
  const TalkScreen({super.key});

  @override
  State<TalkScreen> createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  // <토크 리스트> 초기화
  late List<Talk> _talkList = [];

  // 키워드 검색 필터
  late bool _filterFriend = false;

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
              IconButton(onPressed: () {}, icon: const Icon(Icons.message))
            ],
          ),
          // Appbar - actions
          actions: const [
            // Appbar - actions - 검색 버튼
          ]),
      // ┏━━━━━━━━━━┓
      // ┃   Body   ┃
      // ┗━━━━━━━━━━┛
      body: Container(
        width: mq.width,
        height: mq.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 내가 즐겨찾기 한 유저 스토리 보여주기 ( 구현 예정 )
            Container(
                color: const Color.fromRGBO(56, 56, 60, 1),
                width: mq.width,
                height: mq.height * .1,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 20,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.all(mq.width * .02),
                      child: Container(
                        padding: EdgeInsets.all(mq.height * .005),
                          width: mq.height * .08,
                          height: mq.height * .08,
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(mq.height * .04),
                            gradient: const LinearGradient(
                              colors: [Colors.blue, Colors.purple],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        child: Container(
                          width: mq.height * .08,
                          height: mq.height * .08,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(mq.height * .04),
                          ),
                        ),
                      ),
                    );
                  },
                )),
            // 키워드 필터 ( 구현 예정 )
            Container(
              color: const Color.fromRGBO(56, 56, 60, 1),
              padding: EdgeInsets.symmetric(horizontal: 20),
              width: mq.width,
              height: 60,
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _filterFriend = !_filterFriend;
                        });
                      },
                      child: Container(
                        height: 35,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: _filterFriend
                                ? Color.fromRGBO(232, 232, 232, 1)
                                : Color.fromRGBO(92, 97, 103, 1),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                                bottomRight: Radius.circular(15))),
                        child: Text("#친구",
                            style: TextStyle(
                                color: _filterFriend
                                    ? const Color.fromRGBO(92, 97, 103, 1)
                                    : Colors.white,
                                fontSize: 12)),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      height: 35,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(92, 97, 103, 1),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                              bottomRight: Radius.circular(15))),
                      child: Text(
                        "#가까운",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  )
                ],
              ),
            ),
            // 토크 리스트
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
                                      name: '',
                                      createdAt: '',
                                      isOnline: false,
                                      id: _talkList[index].creUserId,
                                      lastActive: '',
                                      email: '',
                                      gender: '',
                                      birthDay: '',
                                      theme: '',
                                      emotionMsg: '',
                                      introduce: '',
                                      isDefaultInfoSet: false,
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
                                            List<ModuUser> users = data
                                                    ?.map((e) => ModuUser.fromJson(e.data()))
                                                    .toList() ??
                                                [];
                                            if (_talkList.isNotEmpty) {
                                              if (users.isNotEmpty) {
                                                return TalkCard(
                                                    user: users[0], talk: _talkList[index]);
                                              } else {
                                                print(_talkList[index].creUserId);
                                                return const SizedBox();
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
      ),
    );
  }
}
