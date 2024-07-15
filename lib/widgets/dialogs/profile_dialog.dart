import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:modu_messenger_firebase/screens/view_profile_screen.dart';

import '../../main.dart';
import '../../models/chat_user_model.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});

  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: mq.width * .6,
        height: mq.height * .35,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.width * .25),
                child: CachedNetworkImage(
                  width: mq.width * .5,
                  height: mq.width * .5,
                  fit: BoxFit.cover,
                  imageUrl: user.image,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            Positioned(
              left: mq.width * .04,
              top: mq.height * .02,
              width: mq.width * .55,
              child: Text(
                user.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 6 ,
              child: Align(
                  alignment: Alignment.topRight,
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ViewProfileScreen(user: user)));
                    },
                    minWidth: 0,
                    padding: EdgeInsets.all(0),
                    shape: CircleBorder(),
                    child: Icon(Icons.info_outline, color: Colors.blue, size: 30),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
