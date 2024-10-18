import 'package:chat_app_project/firebase/fire_database.dart';
import 'package:chat_app_project/models/room_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../widgets/text_field.dart';
import '../chat/widgets/chat_card.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  TextEditingController emailCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Enter Friend Email",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const Spacer(),
                        IconButton.filled(
                          onPressed: () {},
                          icon: const Icon(Iconsax.scan_barcode),
                        )
                      ],
                    ),
                    CustomField(
                      controller: emailCon,
                      icon: Iconsax.direct,
                      lable: "Email",
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer),
                        onPressed: () async {
                          QuerySnapshot friendEmail = await FirebaseFirestore
                              .instance
                              .collection('users')
                              .where('email', isEqualTo: emailCon.text)
                              .get();

                          if (emailCon.text.isNotEmpty) {
                            if (friendEmail.docs.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("This email does not exist")));
                            } else {
                              // if (friendEmail.docs.first.id ==
                              //     FirebaseAuth.instance.currentUser!.uid) {
                              //   ScaffoldMessenger.of(context).showSnackBar(
                              //       const SnackBar(
                              //           content: Text(
                              //               "You can't have a conversation with yourself!!!")));
                              //   emailCon.clear();
                              // }
                              await FireData().createRoom(emailCon.text).then(
                                (value) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "The room has been created.")));
                                  emailCon.clear();
                                  print(
                                      "---------------- Created Room Done ----------------");
                                },
                              ).onError((error, stackTrace) {
                                print(
                                    "----------------- Some Error ----------------");
                              });
                            }
                          }
                          // } else {}
                        },
                        child: const Center(
                          child: Text("Create Chat"),
                        ))
                  ],
                ),
              );
            },
          ).closed.then(
            (value) {
              emailCon.clear();
            },
          );
        },
        child: const Icon(Iconsax.message_add),
      ),
      appBar: AppBar(
        title: const Text("Chats"),
      ),
      body:
      Padding(
        padding: const EdgeInsets.all(20.0),
        child:
        Column(
          children: [
            Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('rooms')
                      .where('members',
                          arrayContains: FirebaseAuth.instance.currentUser!.uid)
                      // .orderBy('last_message_time', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Something went wrong!'),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('No rooms available.'),
                      );
                    }
                    List<ChatRoom> items = snapshot.data!.docs
                        .map((e) => ChatRoom.fromJson(e.data()))
                        .toList()
                      ..sort(
                        (a, b) =>
                            b.lastMessageTime!.compareTo(a.lastMessageTime!),
                      );
                    return ListView.builder(
                        // itemCount: snapshot.data!.size,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          return ChatCard(item: items[index]);
                        });
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
