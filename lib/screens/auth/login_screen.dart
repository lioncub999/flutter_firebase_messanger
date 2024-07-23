import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modu_messenger_firebase/helper/custom_dialogs.dart';
import 'package:modu_messenger_firebase/screens/home_screen.dart';

import '../../api/apis.dart';
import '../../main.dart';
import 'info_insert_screen.dart';

// ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
// ┃                                로그인 화면                                 ┃
// ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 로그인 애니메이션 관리
  bool _isAnimate = false;

  // ┏━━━━━━━━━━━━━━━┓
  // ┃   initState   ┃
  // ┗━━━━━━━━━━━━━━━┛
  @override
  void initState() {
    super.initState();
    // 0.5 초 Duration 으로 애니메이션
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
    // 로딩 시작
    CustomDialogs.showProgressBar(context);

    _signInWithGoogle().then((user) async {
      Navigator.pop(context); // 로딩 끝
      if (user != null) {
        // DB에 로그인 정보 확인
        if ((await APIs.userExists())) {
          if(APIs.me.isDefaultInfoSetting) {
            Navigator.pushAndRemoveUntil(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false);
            CustomDialogs.showSnackbar(context, '로그인 되었습니다');
          } else {
            Navigator.pushAndRemoveUntil(
                context, MaterialPageRoute(builder: (_) => const InfoInsertScreen()), (route) => false);
          }
          // DB에 정보 있으면 홈 화면으로 이동

        }
        // db에 로그인 정보 없으면 데이터 create
        else {
          APIs.createUser().then((value) {
            Navigator.pushAndRemoveUntil(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false);
            CustomDialogs.showSnackbar(context, '로그인 되었습니다');
          });
        }
      }
    });
  }

  // ┏━━━━━━━━━━━━━━━━━┓
  // ┃   구글 로그인   ┃
  // ┗━━━━━━━━━━━━━━━━━┛
  Future<UserCredential?> _signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(56, 56, 60, 1), // LoginScreen backgroundColor
        // ┏━━━━━━━━┓
        // ┃  Body  ┃
        // ┗━━━━━━━━┛
        body: SizedBox(
          width: mq.width,
          height: mq.height,
          // 화면 요소
          child: Column(
            children: [
              // 타이틀 위쪽 여백
              SizedBox(
                width: mq.width,
                height: mq.height * .25,
              ),
              // ┏━━━━━━━━━━━━━━━━━━━━━┓
              // ┃  Body - LoginTitle  ┃
              // ┗━━━━━━━━━━━━━━━━━━━━━┛
              SizedBox(
                width: mq.width,
                height: mq.height * .2,
                child: Stack(
                  children: [
                    // Title 애니메이션
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 500),
                      left: _isAnimate ? mq.width * .1 : mq.width * 1,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // LoginTitle - Text - "로그인 후"
                            const Row(
                              children: [
                                Text('로그인',
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                        fontWeight: FontWeight.w800)),
                                Text(' 후',
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    )),
                              ],
                            ),
                            // 공백 박스
                            SizedBox(
                              height: mq.height * .005,
                            ),
                            // LoginTitle - Text - "이용이"
                            const Text('이용이',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                )),
                            // 공백 박스
                            SizedBox(
                              height: mq.height * .005,
                            ),
                            // LoginTitle - Text - "가능합니다."
                            const Text('가능합니다.',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 공백 박스
              SizedBox(
                height: mq.height * .3,
              ),
              // ┏━━━━━━━━━━━━━━━━━━━━━┓
              // ┃  Body - LoginBtn    ┃
              // ┗━━━━━━━━━━━━━━━━━━━━━┛
              SizedBox(
                  width: mq.width * 0.9,
                  height: mq.height * 0.06,
                  child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Btn-BackgroundColor
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15))), // Btn-Shape
                      ),
                      onPressed: () {
                        _handleLoginBtnClick(); // LoginBtn-ClickEvent
                      },
                      // LoginBtn-Element
                      icon: Image.asset('assets/images/google.png'),
                      label: RichText(
                        text: const TextSpan(
                            style: TextStyle(color: Colors.black, fontSize: 16),
                            children: [
                              TextSpan(text: '구글 아이디로 '),
                              TextSpan(text: '로그인', style: TextStyle(fontWeight: FontWeight.w500))
                            ]),
                      )))
            ],
          ),
        ));
  }
}
