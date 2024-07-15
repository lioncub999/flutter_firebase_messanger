import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modu_messenger_firebase/helper/custom_date_util.dart';
import 'package:modu_messenger_firebase/helper/permission_helper.dart';
import 'package:modu_messenger_firebase/screens/view_profile_screen.dart';
import 'package:modu_messenger_firebase/widgets/message_card.dart';

import '../../api/apis.dart';
import '../../api/chat_apis.dart';
import '../../main.dart';
import '../../models/chat_user_model.dart';
import '../../models/message_model.dart';

// ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
// ┃                                  ChatRoomScreen                                  ┃
// ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({super.key, required this.user});

  final ChatUser user;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final FocusNode _focusNode = FocusNode(); // 포커스 노드 추가

  bool _isUploading = false; // 사진 전송시 대화방 로딩중 표시
  List<Message> _messageList = []; // _messageList 초기화

  final _textController = TextEditingController(); // TextField 컨트롤러

  XFile? _image; // 이미지를 담을 변수 선언
  final ImagePicker _picker = ImagePicker(); // imagePicker

  setXfile(image) {
    setState(() {
      _image = image;
    });
  }

  // ┏━━━━━━━━━━━━━━━━━━━━━━┓
  // ┃   포커스 노드 해제   ┃
  // ┗━━━━━━━━━━━━━━━━━━━━━━┛
  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ┏━━━━━━━━━━━━━━━━━━━━━━┓
  // ┃   로컬 이미지 선택   ┃
  // ┗━━━━━━━━━━━━━━━━━━━━━━┛
  Future<void> _requestPhotoPermission() async {
    bool isGrant = await PermHelper.checkPhotoPermission(); // 사진 권한 확인
    if (isGrant) {
      _pickImage(); // 권한이 허용된 경우 이미지 선택 함수
    } else {
      PermHelper.showPermissionDialog(context, "사진"); // 권한 거부된 경우 수동 해제 유도
    }
  }

  // 사진 선택 (다중 선택 가능)
  Future<void> _pickImage() async {
    final List<XFile> multiImages = await _picker.pickMultiImage(); // 사진 선택창
    if (multiImages.isNotEmpty) {
      setState(() {
        _isUploading = true;
      });
      // 사진 선택 완료시 업로드
      for (var i in multiImages) {
        await ChatAPIs.sendChatImage(widget.user, File(i.path));
      }
      setState(() {
        _isUploading = false;
      });
    }
  }

  // ┏━━━━━━━━━━━━━━━━━━━━━━┓
  // ┃  카메라 이미지 선택  ┃
  // ┗━━━━━━━━━━━━━━━━━━━━━━┛
  Future<void> _requestCameraPermission() async {
    bool isGrant = await PermHelper.checkCameraPermission();
    if (isGrant) {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
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
    } else {
      PermHelper.showPermissionDialog(context, "카메라"); // 권한 거부된 경우 수동 해제 유도
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(56, 56, 60, 1), // 채팅방 backgroundColor
      // ┏━━━━━━━━━━━━┓
      // ┃   AppBar   ┃
      // ┗━━━━━━━━━━━━┛
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.user.name),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))],
      ),
      // ┏━━━━━━━━━━┓
      // ┃   Body   ┃
      // ┗━━━━━━━━━━┛
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _focusNode.unfocus(); // 제스처 감지 시 포커스 해제
        },
        // 채팅 내용
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                  stream: ChatAPIs.getAllMessages(widget.user),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const Center(child: CircularProgressIndicator());
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;

                        // API로 받아온 데이터 MessageList 에 저장
                        _messageList = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

                        // ListView.builder 로 채팅 내역 뿌리기
                        if (_messageList.isNotEmpty) {
                          return ListView.builder(
                            reverse: true, // 채팅 내역 거꾸로
                            itemCount: _messageList.length,
                            padding: EdgeInsets.only(top: mq.height * 0.01),
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              // ┏━━━━━━━━━━━━┓
                              // ┃   말풍선   ┃
                              // ┗━━━━━━━━━━━━┛
                              return MessageCard(
                                message: _messageList[index],
                              );
                            },
                          );
                        } else {
                          // 대화 내역 없을때
                          return const Center(
                            child: Text(
                              "반가워요!👋",
                              style: TextStyle(fontSize: 28),
                            ),
                          );
                        }
                    }
                  }),
            ),
            // 파일 전송시 Loading 표시
            if (_isUploading)
              const Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  child: CircularProgressIndicator(),
                ),
              ),
            // ┏━━━━━━━━━━━━━━━┓
            // ┃   채팅 인풋   ┃
            // ┗━━━━━━━━━━━━━━━┛
            _chatInput()
          ],
        ),
      ),
    );
  }

  // 앱바 임시(디자인에 따라서 기능 붙일 예정)
  //
  // Widget _appBar() {
  //   return InkWell(
  //     onTap: () {
  //       Navigator.push(context, MaterialPageRoute(builder: (_) => ViewProfileScreen(user: widget.user)));
  //     },
  //     child: StreamBuilder(
  //       stream: APIs.getUserInfo(widget.user),
  //       builder: (context, snapshot) {
  //         final data = snapshot.data?.docs;
  //         final list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
  //
  //         return Row(children: [
  //           ClipRRect(
  //             borderRadius: BorderRadius.circular(mq.width * .3),
  //             child: CachedNetworkImage(
  //               width: mq.height * .05,
  //               height: mq.height * .05,
  //               fit: BoxFit.cover,
  //               imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
  //               placeholder: (context, url) => CircularProgressIndicator(),
  //               errorWidget: (context, url, error) => Icon(Icons.error),
  //             ),
  //           ),
  //           const SizedBox(
  //             width: 10,
  //           ),
  //           Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 list.isNotEmpty ? list[0].name : widget.user.name,
  //                 style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w900),
  //               ),
  //               const SizedBox(
  //                 height: 2,
  //               ),
  //               Text(
  //                 list.isNotEmpty
  //                     ? list[0].isOnline
  //                         ? 'Online'
  //                         : MyDateUtil.getLastActiveTime(context: context, lastActivce: list[0].lastActive)
  //                     : MyDateUtil.getLastMessageTime(context: context, time: widget.user.lastActive),
  //                 style: TextStyle(fontSize: 13, color: Colors.black38),
  //               )
  //             ],
  //           ),
  //         ]);
  //       },
  //     ),
  //   );
  // }

  // ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  // ┃   채팅 인풋 위젯 (임시) - 디자인   ┃
  // ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: mq.height * .02, horizontal: mq.width * .025),
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
                  icon: const Icon(Icons.emoji_emotions),
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
                  decoration: const InputDecoration(hintText: '채팅을 입력해 보세요', hintStyle: TextStyle(color: Colors.blueAccent), border: InputBorder.none),
                )),
                IconButton(
                  onPressed: () {
                    _requestPhotoPermission();
                  },
                  icon: const Icon(Icons.image),
                  color: Colors.blueAccent,
                ),
                IconButton(
                  onPressed: () {
                    _requestCameraPermission();
                  },
                  icon: const Icon(Icons.camera_alt_rounded),
                  color: Colors.blueAccent,
                )
              ]),
            ),
          ),
          MaterialButton(
            minWidth: 0,
            padding: const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: const CircleBorder(),
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                ChatAPIs.sendMessage(widget.user, _textController.text, Type.text);
                _textController.text = '';
              }
            },
            color: Colors.green,
            child: const Icon(
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
