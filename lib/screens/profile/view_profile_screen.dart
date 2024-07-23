import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modu_messenger_firebase/helper/custom_dialogs.dart';
import 'package:modu_messenger_firebase/helper/custom_date_util.dart';
import 'package:modu_messenger_firebase/screens/auth/login_screen.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../api/apis.dart';
import '../../main.dart';
import '../../models/chat_model.dart';
import '../../models/user_model.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key, required this.user});

  final ModuUser user;

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.name),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Joined ON :',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 16),
          ),
          Text(
            CustomDateUtil.getOrgTime(context: context, date: widget.user.createdAt),
            style: TextStyle(color: Colors.black54, fontSize: 16),
          )
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.03,
                  ),
                  Stack(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(mq.width * .3),
                      child: CachedNetworkImage(
                        width: mq.height * .2,
                        height: mq.height * .2,
                        fit: BoxFit.cover,
                        imageUrl: widget.user.image,
                        placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ]),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.03,
                  ),
                  Text(
                    widget.user.email,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.03,
                  ),
                  Text(
                    widget.user.name,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.03,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'About :',
                        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 16),
                      ),
                      Text(
                        "ㅎㅐ윙",
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      )
                    ],
                  ),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.03,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
