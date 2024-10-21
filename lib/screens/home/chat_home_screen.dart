import 'package:chat_app_project/screens/home/bottom_sheet.dart';
import 'package:chat_app_project/utils/show_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../firebase/fire_database.dart';
import '../../models/room_model.dart';
import '../../utils/constants.dart';
import '../chat/widgets/chat_card.dart';
import '../chat/widgets/users_online_card.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  TextEditingController emailCon = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showBottomSheet(
              context: context,
              builder: (context) {
                return CreateBottomSheet(
                  txtOfButton: "Create Chat",
                  controller: emailCon,
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    QuerySnapshot friendEmail = await FirebaseFirestore.instance
                        .collection('users')
                        .where('email', isEqualTo: emailCon.text)
                        .get();

                    if (friendEmail.docs.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("This email does not exist")),
                      );
                    } else {
                      await FireData().createRoom(emailCon.text).then(
                        (value) {
                          Navigator.pop(context);

                          showSnackBar(
                              context: context,
                              message: "The room has been created.");
                        },
                      ).onError((error, stackTrace) {
                        showSnackBar(
                            context: context,
                            message: "An error occurred while creating room.");
                      });
                    }
                    setState(() {
                      isLoading = false;
                    });
                  },
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
      ),
    );
  }
}
