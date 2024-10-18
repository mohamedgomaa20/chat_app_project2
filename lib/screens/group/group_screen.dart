import 'package:chat_app_project/firebase/fire_database.dart';
import 'package:chat_app_project/models/group_model.dart';
import 'package:chat_app_project/screens/group/widgets/group_message_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../models/message_model.dart';
import 'group_member.dart';

class GroupScreen extends StatefulWidget {
  ChatGroup chatGroup;

  GroupScreen({super.key, required this.chatGroup});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  TextEditingController msgCon = TextEditingController();
  ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.chatGroup.name!),
            StreamBuilder(
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
                        List membersName = [];
                        for (var userDoc in snapshot.data!.docs) {
                          membersName.add(userDoc['name']);
                        }
                        return Text(
                          membersName.join(', '),
                          style: Theme.of(context).textTheme.labelLarge,
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
            )


            // StreamBuilder(
            //   stream: FirebaseFirestore.instance
            //       .collection('users')
            //       .where('id', whereIn: widget.chatGroup.members)
            //       .snapshots(),
            //   builder: (context, snapshot) {
            //     if (snapshot.hasData) {
            //       List membersName = [];
            //       for (var element in snapshot.data!.docs) {
            //         membersName.add(element.data()['name']);
            //         print(membersName);
            //       }
            //       return Text(
            //         membersName.join(', '),
            //         style: Theme.of(context).textTheme.labelLarge,
            //       );
            //     }
            //     else {
            //       return Container();
            //     }
            //   },
            // )
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GroupMemberScreen(chatGroup: widget.chatGroup),
                  ));
            },
            icon: const Icon(Iconsax.user),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('groups')
                    .doc(widget.chatGroup.id)
                    .collection('messages')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Message> messageList = snapshot.data!.docs
                        .map(
                          (e) => Message.fromJson(e.data()),
                        )
                        .toList()
                      ..sort(
                        (a, b) => b.createdAt!.compareTo(a.createdAt!),
                      );
                    if (messageList.isEmpty) {
                      return Center(
                        child: GestureDetector(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "👋",
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium,
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Text(
                                    "Say Assalamu Alaikum",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            FireData().sendGMessage(
                              msg: "Assalamu Alaikum 👋",
                              groupId: widget.chatGroup.id!,
                            );
                          },
                        ),
                      );
                    } else {
                      return ListView.builder(
                        reverse: true,
                        itemCount: messageList.length,
                        itemBuilder: (context, index) {
                          return GroupMessageCard(
                            index: index,
                            message: messageList[index],
                          );
                        },
                      );
                    }
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: TextField(
                      maxLines: 5,
                      minLines: 1,
                      controller: msgCon,
                      decoration: InputDecoration(
                          suffixIcon: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Iconsax.emoji_happy),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Iconsax.camera),
                              ),
                            ],
                          ),
                          border: InputBorder.none,
                          hintText: "Message",
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10)),
                    ),
                  ),
                ),
                IconButton.filled(
                    onPressed: () async {
                      if (msgCon.text.isNotEmpty) {
                        await FireData()
                            .sendGMessage(
                                msg: msgCon.text, groupId: widget.chatGroup.id!)
                            .then(
                          (value) {
                            print("------------- send done ---------------");
                            setState(() {
                              msgCon.clear();
                            });
                          },
                        ).onError(
                          (error, stackTrace) {
                            print("------------- error ---------------");
                          },
                        );
                      }
                    },
                    icon: Icon(Iconsax.send_1))
              ],
            )
          ],
        ),
      ),
    );
  }
}
