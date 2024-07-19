import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/chat_user_model.dart';
import '../models/message_model.dart';
import 'apis.dart';

// ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
// ┃                                                                                                    ┃
// ┃                                            채팅 API                                                ┃
// ┃                                                                                                    ┃
// ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
class ChatAPIs {
  // ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  // ┃   ● 내 채팅방 조회                                                      ┃
  // ┃     - CL_CHAT_ROOM doc 중 member 필드에 내 아이디 포함된 doc 가져옴     ┃
  // ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyChatRooms() {
    return APIs.fireStore
        .collection('CL_CHAT_ROOM')
        .where('member', arrayContains: APIs.user.uid)
        .snapshots();
  }

  // ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  // ┃   ● 채팅방 아이디 가져오기                                           ┃
  // ┃     - 내 아이디와 상대방 아이디로 만들어진 대화방 아이디 가져오기    ┃
  // ┃     - parameterType : String (id)                                    ┃
  // ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  static String getConversationId(String id) => APIs.user.uid.hashCode <= id.hashCode ? '${APIs.user.uid}_$id' : '${id}_${APIs.user.uid}';

  // ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  // ┃   ● 위에서 가져온 채팅방 아이디에 있는 모든 대화내용                 ┃
  // ┃     - parameterType : ChatUser                                       ┃
  // ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user) {
    return APIs.fireStore.collection('CL_CHAT/${getConversationId(user.id)}/messages/').orderBy('sent', descending: true).snapshots();
  }

  // ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  // ┃   ● 메시지 전송                                                      ┃
  // ┃     - parameterType : ChatUser, String (msg), Type                   ┃
  // ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  static Future<void> sendMessage(ChatUser chatUser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final Message message = Message(told: chatUser.id, type: type, msg: msg, read: '', fromId: APIs.user.uid, sent: time);

    final ref = APIs.fireStore.collection('CL_CHAT/${getConversationId(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson());

    final ref2 = APIs.fireStore.collection('CL_CHAT_ROOM');
    await ref2.doc('DC_${getConversationId(chatUser.id)}').update({'last_msg_dtm' : time});
  }

  // ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  // ┃   ● 이미지 전송                                                      ┃
  // ┃     - parameterType : ChatUser                                       ┃
  // ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;
    final ref = APIs.storage.ref().child('images/${getConversationId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then((p0) {});
    final imgUrl = await ref.getDownloadURL();

    await sendMessage(chatUser, imgUrl, Type.image);
  }

  // ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  // ┃   ● 메시지 읽음 표시                                                 ┃
  // ┃     - parameterType : Message                                        ┃
  // ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  static Future<void> updateMessageReadStatus(Message message) async {
    APIs.fireStore
        .collection('CL_CHAT/${getConversationId(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  // ┃   ● 마지막 메시지 가져오기                                           ┃
  // ┃     - parameterType : ChatUser                                       ┃
  // ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(ChatUser user) {
    return APIs.fireStore.collection('CL_CHAT/${getConversationId(user.id)}/messages/').orderBy('sent', descending: true).limit(1).snapshots();
  }
}
