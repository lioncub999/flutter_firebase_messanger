import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modu_messanger/screens/auth/login_screen.dart';

import '../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 1500), (){
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => const LoginScreen()));
    });
  }


  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      // AppBar
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "WELCOME CHAT",
        ),
      ),
      // Body
      body: Stack(
        children: [
          Positioned(
              top: mq.height * .15,
              right: mq.width * .25,
              width: mq.width * .5,
              child: Image.asset('images/icon.png')),
          Positioned(
              bottom: mq.height * .15,
              width: mq.width,
              child: const Text('MADE IN KOREA WITH SMURF',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color : Colors.black87,
                letterSpacing: .7
              ),)),
        ],
      ),
    );
  }
}
