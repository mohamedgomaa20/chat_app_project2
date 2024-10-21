import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

import '../../firebase/fire_database.dart';
import '../../models/room_model.dart';
import '../../utils/constants.dart';
import '../../widgets/create_bottom_sheet.dart';
import '../chat/widgets/chat_card.dart';
import '../chat/widgets/users_online_card.dart';

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
              return CreateChatBottomSheet(
                txtOfButton: "Create Chat",
                onCreateRoom: (email) async {
                  QuerySnapshot friendEmail = await FirebaseFirestore.instance
                      .collection('users')
                      .where('email', isEqualTo: email)
                      .get();

                  if (friendEmail.docs.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("This email does not exist")),
                    );
                  } else {
                    await FireData().createRoom(email).then(
                      (value) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("The room has been created.")),
                        );
                        print(
                            "---------------- Created Room Done ----------------");
                      },
                    ).onError((error, stackTrace) {
                      print("----------------- Some Error ----------------");
                    });
                  }
                },
              );
            },
          ).closed.then(
            (value) {
              // Clear the controller after closing the bottom sheet
            },
          );
        },
        child: const Icon(Iconsax.message_add),
      ),
      appBar: AppBar(
        title: const Text("Chats"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kPadding),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('rooms')
              .where('members',
                  arrayContains: FirebaseAuth.instance.currentUser!.uid)
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
            if (snapshot.hasError) {
              return const Center(
                child: Text('Something went wrong!'),
              );
            }
            List<ChatRoom> items = snapshot.data!.docs
                .map((e) => ChatRoom.fromJson(e.data()))
                .toList()
              ..sort(
                (a, b) => b.lastMessageTime!.compareTo(a.lastMessageTime!),
              );
            return SingleChildScrollView(
              child: Column(
                children: [
                  UsersOnlineList(items: items),
                  const Gap(5),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return ChatCard(item: items[index]);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
