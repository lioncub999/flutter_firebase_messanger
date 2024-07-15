import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modu_messenger_firebase/helper/my_date_util.dart';
import 'package:modu_messenger_firebase/screens/view_profile_screen.dart';
import 'package:modu_messenger_firebase/widgets/message_card.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../api/apis.dart';
import '../../api/chat_apis.dart';
import '../../helper/dialogs.dart';
import '../../main.dart';
import '../../models/chat_user.dart';
import '../../models/message.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({super.key, required this.user});

  final ChatUser user;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  bool _isUploading = false;
  List<Message> _list = [];
  final _textController = TextEditingController();

  final FocusNode _focusNode = FocusNode(); // 포커스 노드 추가

  XFile? _image; // 이미지를 담을 변수 선언
  final ImagePicker _picker = ImagePicker();

  setXfile(image) {
    setState(() {
      _image = image;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose(); // 포커스 노드 해제
    super.dispose();
  }

  // TODO: 사진 권한 허용
  Future<void> _requestPhotoPermission() async {
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
    }
    if (status.isGranted) {
      //사진첩 접근 권한 허용됨
      _pickImage(); // 권한이 허용된 경우 이미지 선택 함수 호출
    } else if (status.isDenied) {
      //사진첩 접근 권한 거부됨
    } else if (status.isPermanentlyDenied) {
      //사진첩 접근 권한 영구적으로 거부됨
      _showPermissionDialog();
    }
  }

  // TODO: 사진첩 에서 사진 선택
  Future<void> _pickImage() async {
    final List<XFile> multiImages = await _picker.pickMultiImage();

    if (multiImages.isNotEmpty) {
      setState(() {
        _isUploading = true;
      });
      for (var i in multiImages) {
        await ChatAPIs.sendChatImage(widget.user, File(i.path));
      }
      setState(() {
        _isUploading = false;
      });
    }
  }

  // TODO: 사진 접근 권한 허용 알림
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('권한 필요'),
        content: Text('권한이 필요합니다. 설정에서 권한을 허용해주세요.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
            child: Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }

  // TODO: 카메라 권한 허용
  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    print(status);
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    if (status.isGranted) {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        Dialogs.showProgressBar(context);
        // 파일을 선택한 경우
        setState(() {
          _image = pickedFile;
        });
        setState(() {
          _isUploading = true;
        });
        await ChatAPIs.sendChatImage(widget.user, File(_image!.path));
        setState(() {
          _isUploading = false;
        });
      }
    } else if (status.isDenied) {
    } else if (status.isPermanentlyDenied) {
      //사진첩 접근 권한 영구적으로 거부됨
      _showPermissionDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 234, 248, 255),
      appBar: AppBar(
        centerTitle: false,
        title: _appBar(),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _focusNode.unfocus(); // 제스처 감지 시 포커스 해제
        },
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                  stream: ChatAPIs.getAllMessages(widget.user),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const SizedBox();

                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;

                        _list = data
                                ?.map((e) => Message.fromJson(e.data()))
                                .toList() ??
                            [];

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                            reverse: true,
                            itemCount: _list.length,
                            padding: EdgeInsets.only(top: mq.height * 0.01),
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return MessageCard(
                                message: _list[index],
                              );
                            },
                          );
                        } else {
                          return const Center(
                            child: Text(
                              "Say Hi!👋",
                              style: TextStyle(fontSize: 28),
                            ),
                          );
                        }
                    }
                  }),
            ),
            if (_isUploading)
              const Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  child: CircularProgressIndicator(),
                ),
              ),
            _chatInput()
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ViewProfileScreen(user: widget.user)));
      },
      child: StreamBuilder(
        stream: APIs.getUserInfo(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final list =
              data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

          return Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(mq.width * .3),
              child: CachedNetworkImage(
                width: mq.height * .05,
                height: mq.height * .05,
                fit: BoxFit.cover,
                imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  list.isNotEmpty ? list[0].name : widget.user.name,
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  list.isNotEmpty
                      ? list[0].isOnline
                          ? 'Online'
                          : MyDateUtil.getLastActiveTime(
                              context: context, lastActivce: list[0].lastActive)
                      : MyDateUtil.getLastMessageTime(
                          context: context, time: widget.user.lastActive),
                  style: TextStyle(fontSize: 13, color: Colors.black38),
                )
              ],
            ),
          ]);
        },
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .02, horizontal: mq.width * .025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.emoji_emotions),
                  color: Colors.blueAccent,
                ),
                Expanded(
                    child: TextField(
                  focusNode: _focusNode,
                  // 포커스 노드 연결
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 6,
                  decoration: InputDecoration(
                      hintText: 'Type Someting...',
                      hintStyle: TextStyle(color: Colors.blueAccent),
                      border: InputBorder.none),
                )),
                IconButton(
                  onPressed: () {
                    _requestPhotoPermission();
                  },
                  icon: Icon(Icons.image),
                  color: Colors.blueAccent,
                ),
                IconButton(
                  onPressed: () {
                    _requestCameraPermission();
                  },
                  icon: Icon(Icons.camera_alt_rounded),
                  color: Colors.blueAccent,
                )
              ]),
            ),
          ),
          MaterialButton(
            minWidth: 0,
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: CircleBorder(),
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                ChatAPIs.sendMessage(widget.user, _textController.text, Type.text);
                _textController.text = '';
              }
            },
            color: Colors.green,
            child: Icon(
              Icons.send,
              color: Colors.white,
              size: 28,
            ),
          )
        ],
      ),
    );
  }
}
