import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modu_messanger/screens/home_screen.dart';

import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimated = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(microseconds: 500), (){
      setState(() {
        _isAnimated = true;
      });
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
          AnimatedPositioned(
              duration: Duration(milliseconds: 500),
              top: mq.height * .15,
              right: _isAnimated ? mq.width * .25 : -mq.width * 1,
              width: mq.width * .5,
              child: Image.asset('images/icon.png')),
          Positioned(
              bottom: mq.height * .15,
              left: mq.width * .05,
              width: mq.width * .9,
              height: mq.height * .06,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 223, 255, 187),
                    shape: StadiumBorder(),
                    elevation: 1,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(
                        builder: (_) => const HomeScreen()));
                  },
                  icon: Image.asset(
                    'images/google.png',
                    height: mq.height * 0.03,
                  ),
                  label: RichText(
                    text: const TextSpan(
                        style: TextStyle(color: Colors.black, fontSize: 16),
                        children: [
                          TextSpan(text: 'Signin with '),
                          TextSpan(
                              text: 'Google',
                              style: TextStyle(fontWeight: FontWeight.w700))
                        ]),
                  ))),
        ],
      ),
    );
  }
}
