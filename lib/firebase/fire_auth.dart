import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class FireAuth {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future createUser() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      ChatUser chatUser = ChatUser(
        id: currentUser.uid,
        name: currentUser.displayName ?? "",
        email: currentUser.email ?? "",
        about: "hello i'm a new user",
        image: "",
        online: true,
        pushToken: "",
        lastActivated: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
        myContacts: [],
      );

      await firestore
          .collection('users')
          .doc(currentUser.uid)
          .set(chatUser.toJson());
    } else {
      print("Error: No user is currently logged in.");
    }
  }

  Future getToken(String token) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'push_token': token});
  }
}
