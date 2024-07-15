import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modu_messenger_firebase/helper/dialogs.dart';
import 'package:modu_messenger_firebase/screens/home_screen.dart';

import '../../api/apis.dart';
import '../../main.dart';

// ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
// ┃                                   LoginScreen                                    ┃
// ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

  // ┏━━━━━━━━━━━━━━━┓
  // ┃   initState   ┃
  // ┗━━━━━━━━━━━━━━━┛
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  // ┏━━━━━━━━━━━━━━━━━━━━━━┓
  // ┃   로그인 버튼 클릭   ┃
  // ┗━━━━━━━━━━━━━━━━━━━━━━┛
  _handleLoginBtnClick() {
    Dialogs.showProgressBar(context); // 로딩 중 화면 표시

    _signInWithGoogle().then((user) async {
      Navigator.pop(context); // 백그라운드 로딩 닫기
      if (user != null) {
        // db에 로그인 정보 있으면 그냥 로그인
        if ((await APIs.userExists())) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          Dialogs.showSnackbar(context, '로그인 되었습니다');
        }
        // db에 로그인 정보 없으면 데이터 create
        else {
          APIs.createUser().then((value) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
            Dialogs.showSnackbar(context, '로그인 되었습니다');
          });
        }
      }
    });
  }

  // ┏━━━━━━━━━━━━━━━━━┓
  // ┃   구글 로그인   ┃
  // ┗━━━━━━━━━━━━━━━━━┛
  Future<UserCredential?> _signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    try {
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      // 로그인 취소
      if (googleAuth?.accessToken == null) {
        Dialogs.showSnackbar(context, "로그인 취소됨");
      }
      // 기타 오류
      else {
        Dialogs.showSnackbar(context, "네트워크 확인후 관리자 문의");
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          textTheme: const TextTheme(
              bodyMedium: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        letterSpacing: -0.5,
      ))),
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(56, 56, 60, 1), // LoginScreen backgroundColor
        // ┏━━━━━━━━┓
        // ┃  Body  ┃
        // ┗━━━━━━━━┛
        body: Stack(
          children: [
            // ┏━━━━━━━━━━━━━━━━━━━━━┓
            // ┃  Body - LoginTitle  ┃
            // ┗━━━━━━━━━━━━━━━━━━━━━┛
            AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                top: mq.height * 0.2,
                right: _isAnimate ? mq.width * 0 : mq.width * 1,
                width: mq.width,
                // LoginTitle - TEXT
                child: Container(
                  padding: const EdgeInsets.only(left: 50, right: 50),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LoginTitle - Text - 로그인 후
                      Row(
                        children: [
                          Text('로그인', style: TextStyle(fontWeight: FontWeight.w800)),
                          Text(' 후'),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      // LoginTitle - Text - 이용이
                      Text('이용이'),
                      SizedBox(
                        height: 5,
                      ),
                      // LoginTitle - Text - 가능합니다.
                      Text('가능합니다.'),
                    ],
                  ),
                )),
            // ┏━━━━━━━━━━━━━━━━━━━━━┓
            // ┃  Body - LoginBtn    ┃
            // ┗━━━━━━━━━━━━━━━━━━━━━┛
            Positioned(
                left: mq.width * 0.05,
                bottom: mq.height * 0.15,
                width: mq.width * 0.9,
                height: mq.height * 0.06,
                child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Btn-BackgroundColor
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))), // Btn-Shape
                    ),
                    onPressed: () {
                      _handleLoginBtnClick(); // LoginBtn-ClickEvent
                    },
                    // LoginBtn-Element
                    icon: Image.asset('images/google.png'),
                    label: RichText(
                      text: const TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 16),
                          children: [TextSpan(text: '구글 아이디로 '), TextSpan(text: '로그인', style: TextStyle(fontWeight: FontWeight.w500))]),
                    )))
          ],
        ),
      ),
    );
  }
}
