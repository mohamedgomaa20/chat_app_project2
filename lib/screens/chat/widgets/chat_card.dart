import 'package:chat_app_project/models/message_model.dart';
import 'package:chat_app_project/models/room_model.dart';
import 'package:chat_app_project/models/user_model.dart';
import 'package:chat_app_project/screens/chat/widgets/user_avatar.dart';
import 'package:chat_app_project/utils/date_time.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../chat_screen.dart';

class ChatCard extends StatelessWidget {
  final ChatRoom item;

  const ChatCard({super.key, required this.item});

  // Function to check if the text contains Arabic characters
  bool isArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    List members = item.members!
        .where(
          (element) => element != FirebaseAuth.instance.currentUser!.uid,
        )
        .toList();

    String friendId = members.isEmpty
        ? FirebaseAuth.instance.currentUser!.uid
        : members.first;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          ChatUser chatUser = ChatUser.fromJson(snapshot.data!.data()!);
          return Card(
              child: ListTile(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  chatUser: chatUser,
                  roomId: item.id!,
                ),
              ),
            ),
            leading: UserAvatar(
                name: chatUser.name!,
                imageUrl: chatUser.image!,
                online: chatUser.online!),
            title: Text(
              chatUser.name!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: item.lastMessage != ""
                ? Text(
                    item.lastMessage.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: isArabic(item.lastMessage.toString())
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                  )
                : Text(chatUser.about!),
            trailing: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('rooms')
                  .doc(item.id)
                  .collection('messages')
                  .snapshots(),
              builder: (context, snapshot) {
                final unReadList = snapshot.data?.docs
                        .map((e) => Message.fromJson(e.data()))
                        .where((element) => element.read == "")
                        .where(
                          (element) =>
                              element.fromId !=
                              FirebaseAuth.instance.currentUser!.uid,
                        ) ??
                    [];
                return unReadList.isNotEmpty
                    ? Badge(
                        textStyle: const TextStyle(fontSize: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        label: Text(unReadList.length.toString()),
                        largeSize: 25,
                        backgroundColor:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              MyDateTime.dateAndTime(item.lastMessageTime!)),
                          Text(MyDateTime.onlyTime(item.lastMessageTime!)),
                        ],
                      );
              },
            ),
          ));
        } else {
          return Container();
        }
      },
    );
  }
}
