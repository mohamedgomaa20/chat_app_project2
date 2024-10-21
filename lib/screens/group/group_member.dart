import 'package:chat_app_project/firebase/fire_database.dart';
import 'package:chat_app_project/models/group_model.dart';
import 'package:chat_app_project/models/user_model.dart';
import 'package:chat_app_project/screens/chat/profile_friend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'group_edit.dart';

class GroupMemberScreen extends StatefulWidget {
  const GroupMemberScreen({super.key, required this.chatGroup});

  final ChatGroup chatGroup;

  @override
  State<GroupMemberScreen> createState() => _GroupMemberScreenState();
}

class _GroupMemberScreenState extends State<GroupMemberScreen> {
  @override
  Widget build(BuildContext context) {
    String myUid = FirebaseAuth.instance.currentUser!.uid;
    bool iAdmin = widget.chatGroup.adminsId!.contains(myUid);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Group members"),
        actions: [
          iAdmin
              ? IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditGroupScreen(
                            chatGroup: widget.chatGroup,
                          ),
                        ));
                  },
                  icon: const Icon(Iconsax.user_edit),
                )
              : SizedBox(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('groups')
                    .doc(widget.chatGroup.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List members = snapshot.data!['members'];
                    return StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where('id', whereIn: members)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<ChatUser> membersList = snapshot.data!.docs
                              .map((e) => ChatUser.fromJson(e.data()))
                              .toList()
                            ..sort((a, b) => a.name!.compareTo(b.name!));

                          return ListView.builder(
                            itemCount: membersList.length,
                            itemBuilder: (context, index) {
                              bool memberAdmin = widget.chatGroup.adminsId!
                                  .contains(membersList[index].id);

                              return ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProfileFriendScreen(
                                                chatUser: membersList[index]),
                                      ));
                                },
                                leading: membersList[index].image == ""
                                    ? const CircleAvatar(
                                        radius: 30,
                                        child: Icon(Iconsax.user),
                                      )
                                    : CircleAvatar(
                                        radius: 30,
                                        backgroundImage: NetworkImage(
                                            membersList[index].image!),
                                      ),
                                title: Text(membersList[index].name!),
                                subtitle: memberAdmin
                                    ? const Text(
                                        "Admin",
                                        style: TextStyle(color: Colors.green),
                                      )
                                    : const Text("Member"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    iAdmin && myUid != membersList[index].id
                                        ? IconButton(
                                            onPressed: () {
                                              memberAdmin
                                                  ? FireData()
                                                      .removeAdmin(
                                                          groupId: widget
                                                              .chatGroup.id!,
                                                          memberId:
                                                              membersList[index]
                                                                  .id!)
                                                      .then(
                                                      (value) {
                                                        setState(() {
                                                          widget.chatGroup
                                                              .adminsId!
                                                              .remove(
                                                                  membersList[
                                                                          index]
                                                                      .id!);
                                                        });
                                                      },
                                                    )
                                                  : FireData()
                                                      .promptAdmin(
                                                          groupId: widget
                                                              .chatGroup.id!,
                                                          memberId:
                                                              membersList[index]
                                                                  .id!)
                                                      .then(
                                                      (value) {
                                                        setState(() {
                                                          widget.chatGroup
                                                              .adminsId!
                                                              .add(membersList[
                                                                      index]
                                                                  .id!);
                                                        });
                                                      },
                                                    );
                                            },
                                            icon: Icon(memberAdmin
                                                ? Iconsax.user_tick
                                                : Iconsax.user_minus),
                                          )
                                        : Container(),
                                    iAdmin && myUid != membersList[index].id
                                        ? IconButton(
                                            onPressed: () {
                                              FireData()
                                                  .removeMember(
                                                groupId: widget.chatGroup.id!,
                                                memberId:
                                                    membersList[index].id!,
                                              )
                                                  .then(
                                                (value) {
                                                  setState(() {
                                                    widget.chatGroup.members!
                                                        .remove(
                                                            membersList[index]
                                                                .id);
                                                  });
                                                  print(
                                                      "-------- Remove Done ---------");
                                                },
                                              ).onError(
                                                (error, stackTrace) {
                                                  print(
                                                      "---------- Error -----------");
                                                },
                                              );
                                            },
                                            icon: const Icon(Iconsax.trash),
                                          )
                                        : Container(),
                                  ],
                                ),
                              );
                            },
                          );
                        } else {
                          return Container();
                        }
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}