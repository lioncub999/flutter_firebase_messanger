import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modu_messenger_firebase/api/apis.dart';
import 'package:modu_messenger_firebase/helper/my_date_util.dart';
import 'package:modu_messenger_firebase/models/message.dart';
import 'package:modu_messenger_firebase/widgets/dialogs/profile_dialog.dart';

import '../main.dart';
import '../models/chat_user.dart';
import '../screens/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key, required this.user});

  final ChatUser user;

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  // last message info (if null --> no message)
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * 0.04, vertical: 4),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(user: widget.user)));
          },
          child: StreamBuilder(
              stream: APIs.getLastMessage(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list =
                    data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
                if (list.isNotEmpty) {
                  _message = list[0];
                }

                return ListTile(
                  leading: InkWell(
                    onTap: (){
                      showDialog(context: context, builder: (_) => ProfileDialog(user:widget.user));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.width * .3),
                      child: CachedNetworkImage(
                        width: mq.width * .15,
                        height: mq.width * .15,
                        fit: BoxFit.cover,
                        imageUrl: widget.user.image,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                  // leading: Image.network(widget.user.image),
                  title: Text(widget.user.name),
                  subtitle: Text(
                    _message != null
                        ? _message!.type == Type.image
                            ? '사진'
                            : _message!.msg
                        : widget.user.about,
                    maxLines: 1,
                  ),
                  trailing: _message == null
                      ? null
                      : _message!.read.isEmpty &&
                              _message!.fromId != APIs.user.uid
                          ? Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                  color: Colors.greenAccent.shade400,
                                  borderRadius: BorderRadius.circular(10)),
                            )
                          : Text(
                              MyDateUtil.getLastMessageTime(
                                  context: context, time: _message!.sent),
                              style: TextStyle(color: Colors.black54),
                            ),
                );
              })),
    );
  }
}
