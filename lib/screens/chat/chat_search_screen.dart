import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:modu_messenger_firebase/screens/chat/chat_screen.dart';

class ChatSearchScreen extends StatefulWidget {
  const ChatSearchScreen({super.key});

  @override
  State<ChatSearchScreen> createState() => _ChatSearchScreenState();
}

class _ChatSearchScreenState extends State<ChatSearchScreen> with TickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _controller;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.requestFocus();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 5000), // 애니메이션 지속 시간 설정
    );

    _blurAnimation = Tween<double>(begin: 0.0, end: 50.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
    _controller.forward(); // 애니메이션 시작
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(.05),
      appBar: AppBar(
        leading: Icon(null),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => ChatScreen()),
              );
            },
            icon: Icon(Icons.close),
          ),

        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // 이전 화면을 블러 처리
          AnimatedBuilder(
            animation: _blurAnimation,
            builder: (context, child) {
              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: _blurAnimation.value, sigmaY: _blurAnimation.value),
                child: Container(
                  color: Colors.black.withOpacity(0.5), // 블러 효과를 조절할 수 있습니다.
                ),
              );
            },
          ),
          // 새 화면의 내용
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Blurred Background Page',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
