// import 'package:chat_app_project/models/user_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class FireAuth {
//   //static FirebaseAuth auth = FirebaseAuth.instance;
//   //static User user = auth.currentUser!;
//
//   static User user = FirebaseAuth.instance.currentUser!;
//   static FirebaseFirestore firestore = FirebaseFirestore.instance;
//
//   static Future createUser() async {
//     ChatUser chatUser = ChatUser(
//       id: user.uid,
//       name: user.displayName ?? "",
//       email: user.email ?? "",
//       about: "hello i'm a new user",
//       image: "",
//       online: true,
//       pushToken: "",
//       lastActivated: DateTime.now().toString(),
//       createdAt: DateTime.now().toString(),
//     );
//     await firestore.collection('users').doc(user.uid).set(chatUser.toJson());
//   }
// }
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
}
