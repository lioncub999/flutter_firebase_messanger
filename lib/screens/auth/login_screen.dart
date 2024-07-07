import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modu_messenger_firebase/helper/dialogs.dart';
import 'package:modu_messenger_firebase/screens/home_screen.dart';

import '../../api/apis.dart';
import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGoogleBtnClick() {
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) {
      Navigator.pop(context);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      Dialogs.showSnackbar(context, '로그인 되었습니다');
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      print('message : $e');
      Dialogs.showSnackbar(context, "네트워크 확인후 관리자 문의");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to MODU Chat"),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
              duration: const Duration(seconds: 1),
              top: mq.height * 0.15,
              right: _isAnimate ? mq.width * 0.25 : mq.width * -0.5,
              width: mq.width * 0.5,
              child: Image.asset('images/icon.png')),
          Positioned(
              left: mq.width * 0.05,
              bottom: mq.height * 0.15,
              width: mq.width * 0.9,
              height: mq.height * 0.07,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 219, 255, 178),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                    _handleGoogleBtnClick();
                  },
                  icon: Image.asset('images/google.png'),
                  label: RichText(
                    text: const TextSpan(
                        style: TextStyle(color: Colors.black, fontSize: 16),
                        children: [
                          TextSpan(text: 'Login With '),
                          TextSpan(
                              text: 'GOOGLE',
                              style: TextStyle(fontWeight: FontWeight.w500))
                        ]),
                  )))
        ],
      ),
    );
  }
}
