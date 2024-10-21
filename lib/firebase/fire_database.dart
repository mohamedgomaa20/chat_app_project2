import 'package:chat_app_project/models/group_model.dart';
import 'package:chat_app_project/models/message_model.dart';
import 'package:chat_app_project/models/room_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
          lastMessageTime: timeNow,
          createdAt: timeNow,
        );

        await firestore
            .collection('rooms')
            .doc(members.toString())
            .set(chatRoom.toJson());
      }
    } else {
      print("No user found with the provided email.");
    }
  }

  Future createGroup(String groupName, List<String> members) async {
    try {
      String myUid = FirebaseAuth.instance.currentUser!.uid;

      String gId = const Uuid().v1();
      members.add(myUid);

      ChatGroup chatGroup = ChatGroup(
        id: gId,
        name: groupName,
        image: "",
        members: members,
        adminsId: [myUid],
        createdAt: timeNow,
        lastMessage: "",
        lastMessageTime: timeNow,
      );

      await FirebaseFirestore.instance
          .collection('groups')
          .doc(gId)
          .set(chatGroup.toJson());
      return gId;
    } catch (e) {
      print("Error creating group: $e");
      return null;
    }
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
    required String roomId,
    required String friendId,
    required String msg,
    String type = 'text',
  }) async {
    String msgId = const Uuid().v1();
    String myUid = FirebaseAuth.instance.currentUser!.uid;

    Message message = Message(
        id: msgId,
        msg: msg,
        fromId: myUid,
        toId: friendId,
        createdAt: timeNow,
        read: '',
        type: type);

    await firestore
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .doc(msgId)
        .set(message.toJson());

    firestore.collection('rooms').doc(roomId).update({
      'last_message': type == 'image' ? 'image' : msg,
      'last_message_time': timeNow,
    });
  }

  Future sendGroupMessage({
    required String groupId,
    required String msg,
    String type = 'text',
  }) async {
    String msgId = const Uuid().v1();
    String myUid = FirebaseAuth.instance.currentUser!.uid;

    Message message = Message(
        id: msgId,
        msg: msg,
        fromId: myUid,
        toId: '',
        createdAt: timeNow,
        read: '',
        type: type);

    await firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(msgId)
        .set(message.toJson());

    firestore.collection('groups').doc(groupId).update({
      'last_message': type == 'image' ? 'image' : msg,
      'last_message_time': timeNow,
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
        'read': timeNow,
      },
    );
  }

  Future readMsgGroup({
    required String groupId,
    required String msgId,
  }) async {
    await firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(msgId)
        .update(
      {
        'read': timeNow,
      },
    );
  }

  Future deleteMessage(String roomId, List<String> messagesId) async {
    for (var element in messagesId) {
      await firestore
          .collection('rooms')
          .doc(roomId)
          .collection('messages')
          .doc(element)
          .delete();
    }
  }

  Future deleteMsgGroup(String groupId, List<String> messagesId) async {
    for (var element in messagesId) {
      await firestore
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .doc(element)
          .delete();
    }
  }

  Future editMessage(
      {required String roomId,
      required String messageId,
      required String editMessage}) async {
    await firestore
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .update({
      'message': editMessage,
    });
  }

  Future editMessageGroup(
      {required String groupId,
      required String messageId,
      required String editMessage}) async {
    await firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(messageId)
        .update({
      'message': editMessage,
    });
  }

  Future editInfoGroup(
      {required String groupId,
      required String newGroupName,
      required List membersId}) async {
    await firestore.collection('groups').doc(groupId).update({
      'name': newGroupName,
      'members': FieldValue.arrayUnion(membersId),
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

  sendNotification() {}
}
