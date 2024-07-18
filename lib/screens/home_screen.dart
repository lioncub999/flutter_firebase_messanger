import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modu_messenger_firebase/helper/custom_dialogs.dart';
import 'package:modu_messenger_firebase/screens/auth/login_screen.dart';
import 'package:modu_messenger_firebase/screens/chat/chat_screen.dart';
import 'package:modu_messenger_firebase/ttestt/test_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../api/apis.dart';
import '../api/chat_apis.dart';
import '../main.dart';
import 'common/bottom_navbar.dart';

// ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
// ┃                                    HomeScreen                                    ┃
// ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ┏━━━━━━━━━━━━━━━┓
  // ┃   initState   ┃
  // ┗━━━━━━━━━━━━━━━┛
  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo(); // 로그인 정보 가져오기
    _requestNotificationPermission(); // 푸시알림 허용
    // 앱 실행 및 최소화시 isOnline = true or false
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('paused')) APIs.updateActiveStatus(false);
        if (message.toString().contains('resume')) APIs.updateActiveStatus(true);
      }
      return Future.value(message);
    });
  }

  // 알림 권한 허용
  Future<void> _requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      status = await Permission.notification.request();
    }
    if (status.isGranted) {
    } else if (status.isDenied) {
    } else if (status.isPermanentlyDenied) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // ┏━━━━━━━━━━━┓
        // ┃   Body    ┃
        // ┗━━━━━━━━━━━┛
        body: [
          // 토크 화면 (tapState = 0)
          testttt(),
          // 내주변 화면 (tapState = 1)
          Center(child: SvgPicture.asset('assets/icons/locationIcon.svg')),
          // 채팅 화면 (tapState = 2)
          const ChatScreen(),
          // 더보기 화면 (tapState = 3)
          Center(
              child: Scaffold(
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton(
                onPressed: () async {
                  await APIs.auth.signOut();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                  CustomDialogs.showSnackbar(context, '로그아웃 되었습니다(임시)');
                },
                child: const Text("로그아웃 임시"),
              ),
            ),
          )),
        ][context.watch<MainStore>().tapState], // tapState 에 따라 화면 변경
        // ┏━━━━━━━━━━━━━━━━━━┓
        // ┃   BottomNavBar   ┃
        // ┗━━━━━━━━━━━━━━━━━━┛
        bottomNavigationBar: const BottomNavbar());
  }
}
