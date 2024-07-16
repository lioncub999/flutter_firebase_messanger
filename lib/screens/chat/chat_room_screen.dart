import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modu_messenger_firebase/helper/permission_helper.dart';
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
  final _textController = TextEditingController(); // TextField 컨트롤러

  bool _isUploading = false; // 사진 전송시 대화방 로딩중 표시
  List<Message> _messageList = []; // _messageList 초기화

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
          _focusNode.unfocus(); // 포커스 해제
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
                            reverse: true,
                            // 채팅 내역 거꾸로
                            itemCount: _messageList.length,
                            padding: EdgeInsets.only(top: mq.height * 0.01),
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              // 마지막 메시지이거나, 다음 메시지와 날짜가 다른 경우 구분선 추가
                              if (index == _messageList.length - 1 || _isDifferentDay(index)) {
                                return Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 1.5,
                                              color: Colors.grey.withOpacity(1),
                                              margin: const EdgeInsets.only(right: 6.0),
                                            ),
                                          ),
                                          Text(
                                            _getDateLabel(index),
                                            style: TextStyle(color: Colors.grey.withOpacity(1), fontSize: 11, fontWeight: FontWeight.w600),
                                          ),
                                          Expanded(
                                            child: Container(
                                              height: 1.5,
                                              color: Colors.grey.withOpacity(1),
                                              margin: const EdgeInsets.only(left: 6.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    MessageCard(message: _messageList[index], user: widget.user),
                                  ],
                                );
                              } else {
                                return MessageCard(message: _messageList[index], user: widget.user);
                              }
                              // ┏━━━━━━━━━━━━┓
                              // ┃   말풍선   ┃
                              // ┗━━━━━━━━━━━━┛
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
  // ┃   채팅 텍스트 필드 위젯            ┃
  // ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  Widget _chatInput() {
    return Container(
      constraints: BoxConstraints(minHeight: mq.height * .12),
      width: mq.width * 1,
      margin: EdgeInsets.only(top: mq.height * .01),
      color: const Color.fromRGBO(245, 245, 245, .94),
      child: Padding(
        padding: EdgeInsets.only(top: mq.height * .012, bottom: mq.height * .012, right: mq.width * .06),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ┏━━━━━━━━━━━━━━━━━━┓
            // ┃   첨부(+) 버튼   ┃
            // ┗━━━━━━━━━━━━━━━━━━┛
            Padding(
              padding: EdgeInsets.only(top: mq.height * .003),
              child: IconButton(
                onPressed: () {
                  _showBottomSheet();
                },
                icon: SvgPicture.asset(
                  'assets/icons/plusIcon.svg',
                  width: 24,
                  height: 24,
                  color: Colors.black,
                ),
              ),
            ),
            // ┏━━━━━━━━━━━━━━━━━┓
            // ┃   텍스트 필드   ┃
            // ┗━━━━━━━━━━━━━━━━━┛
            Expanded(
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Container(
                  padding: EdgeInsets.only(left: mq.width * .05, right: mq.width * .02),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          focusNode: _focusNode,
                          controller: _textController,
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: 6,
                          style: const TextStyle(fontSize: 14, letterSpacing: -0.24),
                          decoration: const InputDecoration(
                            hintText: '채팅을 입력하세요',
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      // ┏━━━━━━━━━━━━━━━┓
                      // ┃   전송 버튼   ┃
                      // ┗━━━━━━━━━━━━━━━┛
                      MaterialButton(
                        minWidth: 0,
                        padding: EdgeInsets.all(mq.width * .005),
                        shape: const CircleBorder(),
                        onPressed: () {
                          if (_textController.text.isNotEmpty) {
                            ChatAPIs.sendMessage(widget.user, _textController.text, Type.text);
                            _textController.text = '';
                          }
                        },
                        child: SvgPicture.asset(
                          'assets/icons/sendIcon.svg',
                          width: 28,
                          height: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ┏━━━━━━━━━━━━━━━━━━━━┓
  // ┃   사진 전송 임시   ┃
  // ┗━━━━━━━━━━━━━━━━━━━━┛
  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(top: mq.height * 0.03, bottom: mq.height * 0.05),
            children: [
              Text(
                "Pick Profile Picture",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () async {
                      _requestPhotoPermission();
                    },
                    icon: Icon(
                      Icons.add_photo_alternate,
                      size: 100,
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        _requestCameraPermission();
                      },
                      icon: Icon(
                        Icons.camera_enhance,
                        size: 100,
                      ))
                ],
              )
            ],
          );
        });
  }
  bool _isDifferentDay(int index) {
    final currentMessageDate = DateTime.fromMillisecondsSinceEpoch(int.parse(_messageList[index].sent));
    final nextMessageDate = DateTime.fromMillisecondsSinceEpoch(int.parse(_messageList[index + 1].sent));
    return currentMessageDate.day != nextMessageDate.day;
  }

  String _getDateLabel(int index) {
    final messageDate = DateTime.fromMillisecondsSinceEpoch(int.parse(_messageList[index].sent));
    return '${messageDate.year}-${messageDate.month}-${messageDate.day}';
  }
}
