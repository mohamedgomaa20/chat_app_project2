import 'package:chat_app_project/models/group_model.dart';
import 'package:chat_app_project/models/message_model.dart';
import 'package:chat_app_project/models/room_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class FireData {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String timeNow = DateTime.now().millisecondsSinceEpoch.toString();

  Future createRoom(String email) async {
    String myUid = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot friendEmail = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (friendEmail.docs.isNotEmpty) {
      String friendId = friendEmail.docs.first.id;
      List<String> members = [myUid, friendId]..sort((a, b) => a.compareTo(b));

      QuerySnapshot roomExist = await firestore
          .collection('rooms')
          .where('members', isEqualTo: members)
          .get();

      if (roomExist.docs.isEmpty) {
        ChatRoom chatRoom = ChatRoom(
          id: members.toString(),
          members: members,
          lastMessage: "",
          lastMessageTime: DateTime.now().millisecondsSinceEpoch.toString(),
          createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
        );

        await firestore
            .collection('rooms')
            .doc(members.toString())
            .set(chatRoom.toJson());
      }
    } else {
      throw Exception("No user found with the provided email.");
    }
  }

  Future createGroup(String gName, List members) async {
    String myUid = FirebaseAuth.instance.currentUser!.uid;
    String gId = Uuid().v1();
    members.add(myUid);
    ChatGroup chatGroup = ChatGroup(
        id: gId,
        name: gName,
        image: "",
        members: members,
        adminsId: [myUid],
        createdAt: timeNow,
        lastMessage: "",
        lastMessageTime: timeNow);
    await firestore.collection('groups').doc(gId).set(chatGroup.toJson());
  }

  Future addContact(String email) async {
    String myUid = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot friendEmail = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (friendEmail.docs.isNotEmpty) {
      String friendId = friendEmail.docs.first.id;
      await firestore.collection('users').doc(myUid).update({
        'my_contacts': FieldValue.arrayUnion([friendId])
      });
    }
  }

  Future sendMessage({
    required String friendId,
    required String msg,
    required String roomId,
    String type = 'text',
  }) async {
    String msgId = const Uuid().v1();
    String myUid = FirebaseAuth.instance.currentUser!.uid;
    Message message = Message(
        id: msgId,
        msg: msg,
        fromId: myUid,
        toId: friendId,
        // createdAt: FieldValue.serverTimestamp().toString(),
        createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
        read: '',
        type: type ?? 'text');
    await firestore
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .doc(msgId)
        .set(message.toJson());
    firestore.collection('rooms').doc(roomId).update({
      'last_message': type == 'image' ? 'image' : msg,
      'last_message_time': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

  Future sendGMessage({
    required String msg,
    required String groupId,
    String type = 'text',
  }) async {
    String msgId = const Uuid().v1();
    String myUid = FirebaseAuth.instance.currentUser!.uid;
    Message message = Message(
        id: msgId,
        msg: msg,
        fromId: myUid,
        toId: '',
        // createdAt: FieldValue.serverTimestamp().toString(),
        createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
        read: '',
        type: type ?? 'text');
    await firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(msgId)
        .set(message.toJson());
    firestore.collection('groups').doc(groupId).update({
      'last_message': type == 'image' ? 'image' : msg,
      'last_message_time': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

  Future readMessage({
    required String roomId,
    required String msgId,
  }) async {
    await firestore
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .doc(msgId)
        .update(
      {
        'read': DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );
  }

  Future deleteMessage(String roomId, List<String> messages) async {
    for (var element in messages) {
      await firestore
          .collection('rooms')
          .doc(roomId)
          .collection('messages')
          .doc(element)
          .delete();
    }
  }

  Future editGroup(
      {required String groupId,
      required String newGName,
      required List members}) async {
    await firestore.collection('groups').doc(groupId).update({
      'name': newGName,
      'members': FieldValue.arrayUnion(members),
    });
  }

  Future removeMember(
      {required String groupId, required String memberId}) async {
    await firestore.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayRemove([memberId]),
    });
  }

  Future promptAdmin(
      {required String groupId, required String memberId}) async {
    await firestore.collection('groups').doc(groupId).update({
      'admins_id': FieldValue.arrayUnion([memberId]),
    });
  }

  Future removeAdmin(
      {required String groupId, required String memberId}) async {
    await firestore.collection('groups').doc(groupId).update({
      'admins_id': FieldValue.arrayRemove([memberId]),
    });
  }

  Future editProfile({required String newName, required String about}) async {
    String myId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(myId)
        .update({'name': newName, 'about': about});
  }
}
