import 'package:flutter/material.dart';
import 'package:modu_messenger_firebase/api/apis.dart';
import 'package:modu_messenger_firebase/screens/home_screen.dart';

import '../../../main.dart';
import '../auth/login_screen.dart';

// ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
// ┃                              스플레시 화면                                 ┃
// ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // ┏━━━━━━━━━━━━━━━┓
  // ┃   initState   ┃
  // ┗━━━━━━━━━━━━━━━┛
  @override
  void initState() {
    super.initState();
    // "milliseconds : x초" 후 로그인 화면 이동
    Future.delayed(const Duration(milliseconds: 1500), () {
      // 로그인된 유저 있으면 HomeScreen 이동
      if (APIs.auth.currentUser != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
      // 로그인 안되어있으면 LoginScreen 이동
      else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ┏━━━━━━━━┓
      // ┃  Body  ┃
      // ┗━━━━━━━━┛
      body: Stack(
        children: [
          Positioned(
              top: mq.height * 0.25,
              right: mq.width * 0.25,
              width: mq.width * 0.5,
              child: Image.asset('assets/images/icon.png')),
        ],
      ),
    );
  }
}
