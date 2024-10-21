import 'package:chat_app_project/models/room_model.dart';
import 'package:chat_app_project/models/user_model.dart';
import 'package:chat_app_project/screens/chat/widgets/user_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../chat_screen.dart';

class UsersOnlineList extends StatelessWidget {
  final List<ChatRoom> items;

  const UsersOnlineList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
        if (userSnapshot.hasData) {
          List myContacts = userSnapshot.data?['my_contacts'] ?? [];

          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('online', isEqualTo: true)
                .snapshots(),
            builder:
                (context, AsyncSnapshot<QuerySnapshot> activeUsersSnapshot) {
              if (activeUsersSnapshot.hasData &&
                  activeUsersSnapshot.data!.docs.isNotEmpty) {
                List<ChatUser> activeUsers = activeUsersSnapshot.data!.docs
                    .map((doc) =>
                        ChatUser.fromJson(doc.data() as Map<String, dynamic>))
                    .toList();

                List<ChatUser> friends = activeUsers
                    .where((user) => myContacts.contains(user.id))
                    .toList();

                return friends.isNotEmpty
                    ? Container(
                        height: 86,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: friends.length,
                          itemBuilder: (context, index) {
                            return UsersOnlineCard(chatUser: friends[index]);
                          },
                        ),
                      )
                    : Container();
              } else {
                return Container();
              }
            },
          );
        } else {
          return Container();
        }
      },
    );
  }
}

class UsersOnlineCard extends StatelessWidget {
  final ChatUser chatUser;

  const UsersOnlineCard({super.key, required this.chatUser});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatUser: chatUser,
            roomId: chatUser.id!,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 10),
        child: Container(
          width: 60,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              UserAvatar(
                name: chatUser.name!,
                imageUrl: chatUser.image!,
                online: chatUser.online!,
              ),
              Expanded(
                child: Text(
                  chatUser.name!.split(' ').first.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
