import 'package:chat_app_project/firebase/fire_database.dart';
import 'package:chat_app_project/models/group_model.dart';
import 'package:chat_app_project/models/user_model.dart';
import 'package:chat_app_project/screens/chat/profile_friend.dart';
import 'package:chat_app_project/utils/show_alert_dialog.dart';
import 'package:chat_app_project/utils/show_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'edit_group.dart';

class GroupMemberScreen extends StatefulWidget {
  const GroupMemberScreen({super.key, required this.chatGroup});

  final ChatGroup chatGroup;

  @override
  State<GroupMemberScreen> createState() => _GroupMemberScreenState();
}

class _GroupMemberScreenState extends State<GroupMemberScreen> {
  bool isLoading = false;
  bool iAdmin = false;

  @override
  Widget build(BuildContext context) {
    ChatGroup chatGroup;
    String myUid = FirebaseAuth.instance.currentUser!.uid;

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
              : const SizedBox(),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Padding(
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
                      chatGroup = ChatGroup.fromJson(snapshot.data!.data()!);
                      iAdmin = chatGroup.adminsId!.contains(myUid);


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
                                bool memberAdmin = chatGroup.adminsId!
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
                                                            groupId:chatGroup.id!,
                                                            memberId:membersList[index].id!)
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
                                                            groupId:
                                                                chatGroup.id!,
                                                            memberId:
                                                                membersList[
                                                                        index]
                                                                    .id!)
                                                        .then(
                                                        (value) {
                                                          setState(() {
                                                            chatGroup.adminsId!
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
                                                showAlertDialog(
                                                  content:
                                                      "Are you sure you want to remove this member from the group?",
                                                  txtYes: "delete",
                                                  txtNo: "cancel",
                                                  context: context,
                                                  onPressedYes: () async {
                                                    Navigator.pop(context);
                                                    setState(() {
                                                      isLoading = true;
                                                    });
                                                    await FireData()
                                                        .removeMember(
                                                      groupId:
                                                          widget.chatGroup.id!,
                                                      memberId:
                                                          membersList[index]
                                                              .id!,
                                                    )
                                                        .then(
                                                      (value) {
                                                        showSnackBar(
                                                            context: context,
                                                            message:
                                                                "User deleted successfully!");
                                                        setState(() {
                                                          widget.chatGroup
                                                              .members!
                                                              .remove(
                                                                  membersList[
                                                                          index]
                                                                      .id);
                                                        });
                                                      },
                                                    ).onError(
                                                      (error, stackTrace) {
                                                        showSnackBar(
                                                            context: context,
                                                            message:
                                                                "An error occurred while deleting the user.");
                                                      },
                                                    );
                                                    setState(() {
                                                      isLoading = false;
                                                    });
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
      ),
    );
  }
}
