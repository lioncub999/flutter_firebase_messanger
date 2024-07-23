import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import 'apis.dart';

// ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
// ┃                                                                                                    ┃
// ┃                                            채팅 API                                                ┃
// ┃                                                                                                    ┃
// ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
class UserAPIs {
  // ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  // ┃   ● 특정 유저 정보 조회                                             ┃
  // ┃      - parameterType : ChatUser                                     ┃
  // ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(ModuUser chatUser) {
    return APIs.fireStore.collection('CL_USER').where('id', isEqualTo: chatUser.id).snapshots();
  }

  // ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  // ┃   ● 유저 정보 업데이트 (name)                                       ┃
  // ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  static Future<void> updateUserInfo() async {
    await APIs.fireStore.collection('CL_USER').doc(APIs.user.uid).update({'name': APIs.me.name});
  }
  // ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  // ┃   ● 유저 기본 정보 업데이트 (gender, birthDay, mood)                ┃
  // ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  static Future<void> updateUserDefaultInfo(ModuUser user) async {
    await APIs.fireStore.collection('CL_USER').doc(APIs.user.uid).update({'gender' : user.gender, 'is_default_info_set' : user.isDefaultInfoSet});
  }


  // ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  // ┃   ● 유저 프로필 사진 업데이트 (image)                               ┃
  // ┃      - parameterType : File                                         ┃
  // ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    final ref = APIs.storage.ref().child('profile_pictures/${APIs.user.uid}.$ext');
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then((p0) {});
    APIs.me.image = await ref.getDownloadURL();
    await APIs.fireStore.collection('CL_USER').doc(APIs.user.uid).update({'image': APIs.me.image});
  }
}
