import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modu_messenger_firebase/api/apis.dart';
import 'package:modu_messenger_firebase/helper/custom_date_util.dart';
import 'package:modu_messenger_firebase/models/chat_user_model.dart';

import '../api/chat_apis.dart';
import '../main.dart';
import '../models/message_model.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message, required this.user});

  final Message message;
  final ChatUser user;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    // widget.message.fromId 와 로그인된 아이디 비교
    return APIs.user.uid == widget.message.fromId
        // ┏━━━━━━━━━━━━━━━━━━━━━━━━━━┓
        // ┃    같으면 내가 보낸거    ┃
        // ┗━━━━━━━━━━━━━━━━━━━━━━━━━━┛
        ? _sendMessage()
        // ┏━━━━━━━━━━━━━━━━━━━━━━━━━━┓
        // ┃   다르면 상대가 보낸거   ┃
        // ┗━━━━━━━━━━━━━━━━━━━━━━━━━━┛
        : _receiveMessage();
  }

  // ┏━━━━━━━━━━━━━━━━━━━━━━━━┓
  // ┃    내가 보낸 말풍선    ┃
  // ┗━━━━━━━━━━━━━━━━━━━━━━━━┛
  Widget _sendMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 좌측 공백
        SizedBox(
          width: mq.width * .2,
        ),
        // 말풍선
        Flexible(
          child: Stack(
            children: [
              Positioned(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      constraints: BoxConstraints(minWidth: mq.width * .2),
                      padding: EdgeInsets.symmetric(
                          horizontal: widget.message.type == Type.image ? mq.width * 0 : mq.width * .05,
                          vertical: widget.message.type == Type.image ? mq.width * 0 : mq.width * .03),
                      margin: EdgeInsets.only(
                        top: mq.height * .01,
                        bottom: mq.height * .03,
                        right: mq.width * .04,
                      ),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: widget.message.type == Type.image
                              ? const BorderRadius.all(Radius.circular(30))
                              : const BorderRadius.only(
                                  topLeft: Radius.circular(15), topRight: Radius.circular(15), bottomLeft: Radius.circular(15))),
                      // Type 에 따라 말풍선 지정
                      child: widget.message.type == Type.text
                          ? Text(
                              widget.message.msg,
                              style: const TextStyle(fontSize: 14, color: Color.fromRGBO(77, 77, 77, 1), letterSpacing: -0.2),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: CachedNetworkImage(
                                imageUrl: widget.message.msg,
                                placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
                                errorWidget: (context, url, error) => const Icon(
                                  Icons.image,
                                  size: 70,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              // 메시지 read 확인
              widget.message.read.isNotEmpty
                  ? Positioned(left: mq.width * -.016, bottom: 0, child: SvgPicture.asset('assets/icons/readOnIcon.svg', width: 18, height: 18))
                  : Positioned(left: mq.width * -.016, bottom: 0, child: SvgPicture.asset('assets/icons/readIcon.svg', width: 18, height: 18)),
              Positioned(
                  bottom: mq.height * .0035,
                  left: mq.width * .042,
                  child: Text(
                    CustomDateUtil.getFormattedTime(context: context, time: widget.message.sent),
                    style: TextStyle(fontSize: 11, color: Colors.white),
                  ))
            ],
          ),
        ),
      ],
    );
  }

  // ┏━━━━━━━━━━━━━━━━━━━┓
  // ┃    받은 말풍선    ┃
  // ┗━━━━━━━━━━━━━━━━━━━┛
  Widget _receiveMessage() {
    if (widget.message.read.isEmpty) {
      ChatAPIs.updateMessageReadStatus(widget.message);
    }
    return Padding(
      padding: EdgeInsets.only(top: mq.height * .01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 말풍선
          Flexible(
            child: Stack(
              children: [
                Positioned(
                    left: mq.width * .02,
                    top: 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.width * .5),
                      child: CachedNetworkImage(
                        width: mq.width * .11,
                        height: mq.width * .11,
                        fit: BoxFit.cover,
                        imageUrl: widget.user.image,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    )),
                Positioned(
                    left: mq.width * .15,
                    child: Text(
                      widget.user.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                    )),
                Positioned(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: BoxConstraints(minWidth: mq.width * .2),
                        padding: EdgeInsets.symmetric(
                            horizontal: widget.message.type == Type.image ? mq.width * 0 : mq.width * .05,
                            vertical: widget.message.type == Type.image ? mq.width * 0 : mq.width * .03),
                        margin: EdgeInsets.only(
                          top: mq.height * .03,
                          bottom: mq.height * .03,
                          left: mq.width * .15,
                        ),
                        decoration: BoxDecoration(
                            color: const Color.fromRGBO(0, 174, 255, 1),
                            borderRadius: widget.message.type == Type.image
                                ? const BorderRadius.all(Radius.circular(30))
                                : const BorderRadius.only(
                                    topRight: Radius.circular(15), bottomRight: Radius.circular(15), bottomLeft: Radius.circular(15))),
                        // Type 에 따라 말풍선 지정
                        child: widget.message.type == Type.text
                            ? Text(
                                widget.message.msg,
                                style: const TextStyle(fontSize: 14, color: Colors.white, letterSpacing: -0.2),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: CachedNetworkImage(
                                  imageUrl: widget.message.msg,
                                  placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
                                  errorWidget: (context, url, error) => const Icon(
                                    Icons.image,
                                    size: 70,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                // 메시지 read 확인
                widget.message.read.isNotEmpty
                    ? Positioned(right: mq.width * -.016, bottom: 0, child: SvgPicture.asset('assets/icons/readOnIcon.svg', width: 18, height: 18))
                    : Positioned(right: mq.width * -.016, bottom: 0, child: SvgPicture.asset('assets/icons/readIcon.svg', width: 18, height: 18)),
                Positioned(
                    bottom: mq.height * .004,
                    right: mq.width * .05,
                    child: Text(
                      CustomDateUtil.getFormattedTime(context: context, time: widget.message.sent),
                      style: const TextStyle(fontSize: 11, color: Colors.white),
                    ))
              ],
            ),
          ),
          // 우측 공백
          SizedBox(
            width: mq.width * .15,
          ),
        ],
      ),
    );
  }
}
