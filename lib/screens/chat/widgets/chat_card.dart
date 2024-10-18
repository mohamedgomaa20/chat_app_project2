import 'package:chat_app_project/models/message_model.dart';
import 'package:chat_app_project/models/room_model.dart';
import 'package:chat_app_project/models/user_model.dart';
import 'package:chat_app_project/utils/date_time.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../chat_screen.dart';

class ChatCard extends StatelessWidget {
  final ChatRoom item;

  const ChatCard({super.key, required this.item});

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
            leading: chatUser.image == ""
                ? chatUser.online!
                    ? Stack(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            child: Text(chatUser.name!.characters.first),
                          ),
                          const Positioned(
                            right: 1,
                            bottom: 4,
                            child: CircleAvatar(
                                radius: 7,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 5,
                                  backgroundColor: Colors.green,
                                )),
                          ),
                        ],
                      )
                    : CircleAvatar(
                        radius: 30,
                        child: Text(chatUser.name!.characters.first),
                      )
                : chatUser.online!
                    ? Stack(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(chatUser.image!),
                          ),
                          const Positioned(
                            right: 1,
                            bottom: 4,
                            child: CircleAvatar(
                                radius: 7,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 5,
                                  backgroundColor: Colors.green,
                                )),
                          ),
                        ],
                      )
                    : CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(chatUser.image!),
                      ),
            title: Text(
              // snapshot.data!.data()!['name'].toString(),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        label: Text(unReadList.length.toString()),
                        largeSize: 30,
                      )
                    :

                    Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              '${myDateTime.dateAndTime(item.lastMessageTime!)}'),
                          Text('${myDateTime.onlyTime(item.lastMessageTime!)}'),
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
