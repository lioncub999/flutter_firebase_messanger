import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modu_messenger_firebase/models/chat_user.dart';

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  static get user => auth.currentUser!;

  // for checking if user exist or not?
  static Future<bool> userExists() async {
    return (await fireStore.collection('users').doc(user!.uid).get()).exists;
  }

  //for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        id: user!.uid,
        name: user!.displayName.toString(),
        about: "hi",
        image: user!.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '',
        email: user!.email.toString());

    return await fireStore.collection('users').doc(user.uid).set(chatUser.toJson());
  }
}
