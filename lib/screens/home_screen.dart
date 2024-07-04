import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "CHAT",
        ),
        leading: Icon(CupertinoIcons.home),
        actions: [
          // SearchButton
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          // MoreButton
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          onPressed: () {},
          // addCommetButton
          child: Icon(Icons.add_comment_outlined),
        ),
      ),
    );
  }
}
