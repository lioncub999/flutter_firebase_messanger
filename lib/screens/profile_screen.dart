import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modu_messenger_firebase/helper/dialogs.dart';
import 'package:modu_messenger_firebase/screens/auth/login_screen.dart';
import 'package:modu_messenger_firebase/widgets/chat_user_card.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/chat_user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});

  final ChatUser user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Screen"),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
            onPressed: () async {
              await APIs.auth.signOut();
              await GoogleSignIn().signOut();
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => LoginScreen()));
            },
            icon: const Icon(
              Icons.add_comment,
              color: Colors.white,
            ),
            label: const Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            )),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
        child: Column(
          children: [
            SizedBox(
              width: mq.width,
              height: mq.height * 0.03,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(mq.width * .3),
              child: CachedNetworkImage(
                width: mq.height * .2,
                height: mq.height * .2,
                fit: BoxFit.fill,
                imageUrl: widget.user.image,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
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
            TextFormField(
              initialValue: widget.user.name,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.blue),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  hintText: 'NAME',
                  label: const Text("Name")),
            ),
            SizedBox(
              width: mq.width,
              height: mq.height * 0.03,
            ),
            TextFormField(
              initialValue: widget.user.about,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.blue),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  hintText: 'about',
                  label: const Text("About")),
            ),
            SizedBox(
              width: mq.width,
              height: mq.height * 0.03,
            ),
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: StadiumBorder(),
                    minimumSize: Size(mq.width * .4, mq.height * .06)),
                onPressed: () {},
                icon: Icon(
                  Icons.edit,
                  size: 28,
                  color: Colors.white,
                ),
                label: Text(
                  "UPDATE",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ))
          ],
        ),
      ),
    );
  }
}
