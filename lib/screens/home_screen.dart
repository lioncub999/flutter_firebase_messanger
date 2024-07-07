import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modu_messenger_firebase/helper/dialogs.dart';
import 'package:modu_messenger_firebase/screens/auth/login_screen.dart';
import 'package:modu_messenger_firebase/widgets/chat_user_card.dart';

import '../api/apis.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MODU Chat"),
        leading: Icon(CupertinoIcons.home),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          onPressed: () async {
            await APIs.auth.signOut();
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const LoginScreen()));
            Dialogs.showSnackbar(context, '로그아웃 되었습니다');
          },
          child: Icon(Icons.add_comment_rounded),
        ),
      ),
      body: StreamBuilder(
          stream: APIs.fireStore.collection('users').snapshots(),
          builder: (context, snapshot) {
            final list = [];

            if (snapshot.hasData) {
              final data = snapshot.data?.docs;
              for (var i in data!) {
                list.add(i.data()['name']);
                print(i.data());
              }
            }

            return ListView.builder(
              itemCount: list.length,
              padding: EdgeInsets.only(top: mq.height * 0.01),
              itemBuilder: (context, index) {
                return const ChatUserCard();
              },
            );
          }),
    );
  }
}
