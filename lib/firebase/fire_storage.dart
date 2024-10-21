import 'dart:io';
import 'package:chat_app_project/firebase/fire_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FireStorage {
  final fireStorage = FirebaseStorage.instance;

  Future sendImage({
    required File file,
    required String roomId,
    required String friendId,
  }) async {
    String ext = file.path.split('.').last;

    final ref = fireStorage
        .ref()
        .child('images/$roomId/${DateTime.now().millisecondsSinceEpoch}.$ext');

    await ref.putFile(file);

    String imageUrl = await ref.getDownloadURL();

    await FireData().sendMessage(
      friendId: friendId,
      msg: imageUrl,
      roomId: roomId,
      type: 'image',
    );
  }

  Future sendGroupImage({
    required File file,
    required String groupId,
  }) async {
    String ext = file.path.split('.').last;

    final ref = fireStorage
        .ref()
        .child('images/$groupId/${DateTime.now().millisecondsSinceEpoch}.$ext');

    await ref.putFile(file);

    String imageUrl = await ref.getDownloadURL();

    await FireData().sendGroupMessage(
      msg: imageUrl,
      groupId: groupId,
      type: 'image',
    );
  }

  Future updateProfileImage({
    required File file,

  }) async {

    String myId = FirebaseAuth.instance.currentUser!.uid;
    String ext = file.path.split('.').last;

    final ref = fireStorage
        .ref()
        .child('Profile/$myId/${DateTime.now().millisecondsSinceEpoch}.$ext');

    await ref.putFile(file);

    String imageUrl = await ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(myId)
        .update({'image': imageUrl});
  }

  Future updateGroupImage({
    required File file,
    required String groupId,
  }) async {
    String ext = file.path.split('.').last;

    final ref = fireStorage
        .ref()
        .child('groups/$groupId/${DateTime.now().millisecondsSinceEpoch}.$ext');

    await ref.putFile(file);

    String imageUrl = await ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .update({'image': imageUrl});
  }
}
