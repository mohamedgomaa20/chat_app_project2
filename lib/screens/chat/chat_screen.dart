import 'dart:io';

import 'package:chat_app_project/firebase/fire_database.dart';
import 'package:chat_app_project/firebase/fire_storage.dart';
import 'package:chat_app_project/models/message_model.dart';
import 'package:chat_app_project/models/user_model.dart';
import 'package:chat_app_project/screens/chat/widgets/chat_message_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({super.key, required this.roomId, required this.chatUser});

  final String roomId;
  final ChatUser chatUser;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

TextEditingController msgCon = TextEditingController();
ScrollController controller = ScrollController();

class _ChatScreenState extends State<ChatScreen> {
  List<String> selectedMsg = [];
  List<String> copyMsg = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.chatUser.name!),
            // Text(
            //   widget.chatUser.lastActivated!,
            //   style: Theme.of(context).textTheme.labelLarge,
            // ),
            Text("Online",style: Theme.of(context).textTheme.labelLarge,)
          ],
        ),
        actions: [
          selectedMsg.isEmpty && copyMsg.isEmpty
              ? IconButton(onPressed: () {}, icon: const Icon(Iconsax.user))
              : const SizedBox(),
          selectedMsg.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    // FireData().deleteMessage(widget.roomId, selectedMsg);
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          actionsAlignment: MainAxisAlignment.center,
                          title: Text(
                            "Are you sure you want to delete these messages?",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          titlePadding: EdgeInsets.all(30),
                          actions: [
                            TextButton(
                              onPressed: () {
                                FireData()
                                    .deleteMessage(widget.roomId, selectedMsg)
                                    .then(
                                  (value) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "The messages were deleted successfully.")),
                                    );
                                    setState(() {
                                      copyMsg.clear();
                                      selectedMsg.clear();
                                    });
                                  },
                                ).onError(
                                  (error, stackTrace) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text("There was an error.")),
                                    );
                                  },
                                );
                              },
                              child: Text("Yes"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("No"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Iconsax.trash),
                )
              : SizedBox(),
          copyMsg.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: copyMsg.join('\n')));
                    setState(() {
                      copyMsg.clear();
                      selectedMsg.clear();
                    });
                  },
                  icon: const Icon(Iconsax.copy),
                )
              : SizedBox(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('rooms')
                        .doc(widget.roomId)
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

                        if (messageList.isNotEmpty) {
                          return ListView.builder(
                            controller: controller,
                            reverse: true,
                            itemCount: messageList.length,
                            itemBuilder: (context, index) {
                              Message message = messageList[index];

                              // Check if the message is for the current user and hasn't been read
                              if (message.toId ==
                                      FirebaseAuth.instance.currentUser!.uid &&
                                  message.read == "") {
                                // Mark the message as read
                                FireData().readMessage(
                                  roomId: widget.roomId,
                                  msgId: message.id!,
                                );
                              }

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedMsg.isNotEmpty
                                        ? selectedMsg
                                                .contains(messageList[index].id)
                                            ? selectedMsg
                                                .remove(messageList[index].id)
                                            : selectedMsg
                                                .add(messageList[index].id!)
                                        : null;
                                    copyMsg.isNotEmpty
                                        ? messageList[index].type == 'text'
                                            ? copyMsg.contains(
                                                    messageList[index].msg)
                                                ? copyMsg.remove(
                                                    messageList[index].msg)
                                                : copyMsg.add(
                                                    messageList[index].msg!)
                                            : null
                                        : null;
                                    print(copyMsg);
                                  });
                                },
                                onLongPress: () {
                                  setState(() {
                                    selectedMsg.contains(messageList[index].id)
                                        ? selectedMsg
                                            .remove(messageList[index].id)
                                        : selectedMsg
                                            .add(messageList[index].id!);
                                    messageList[index].type == 'text'
                                        ? copyMsg.contains(
                                                messageList[index].msg)
                                            ? copyMsg
                                                .remove(messageList[index].msg)
                                            : copyMsg
                                                .add(messageList[index].msg!)
                                        : null;
                                    print(copyMsg);
                                  });
                                },
                                child: ChatMessageCard(
                                  selected: selectedMsg
                                      .contains(messageList[index].id),
                                  roomId: widget.roomId,
                                  message: message,
                                ),
                              );
                            },
                          );
                        } else {
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () {
                                FireData().sendMessage(
                                  friendId: widget.chatUser.id!,
                                  msg: "Assalamu Alaikum 👋",
                                  roomId: widget.roomId,
                                );
                              },
                            ),
                          );
                        }
                      }
                      return Container();
                    },
                  ),
                ),
                // Message input field
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: TextField(
                          controller: msgCon,
                          maxLines: 5,
                          minLines: 1,
                          decoration: InputDecoration(
                              suffixIcon: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      ImagePicker picker = ImagePicker();
                                      XFile? image = await picker.pickImage(
                                        source: ImageSource.gallery,
                                      );
                                      if (image != null) {
                                        await FireStorage()
                                            .sendImage(
                                          file: File(image.path),
                                          roomId: widget.roomId,
                                          friendId: widget.chatUser.id!,
                                        )
                                            .then(
                                          (value) {
                                            print("Image Send Success");
                                          },
                                        ).onError(
                                          (error, stackTrace) {
                                            print(error.toString());
                                          },
                                        );
                                      }
                                    },
                                    icon: const Icon(Iconsax.emoji_happy),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      ImagePicker picker = ImagePicker();
                                      XFile? image = await picker.pickImage(
                                        source: ImageSource.camera,
                                      );
                                      if (image != null) {
                                        await FireStorage()
                                            .sendImage(
                                          file: File(image.path),
                                          roomId: widget.roomId,
                                          friendId: widget.chatUser.id!,
                                        )
                                            .then(
                                          (value) {
                                            print("Image Send Success Camera");
                                          },
                                        ).onError(
                                          (error, stackTrace) {
                                            print(error.toString());
                                          },
                                        );
                                      }
                                    },
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
                          if (msgCon.text.trim().isNotEmpty) {
                            await FireData()
                                .sendMessage(
                              friendId: widget.chatUser.id!,
                              msg: msgCon.text,
                              roomId: widget.roomId,
                            )
                                .then(
                              (value) {
                                msgCon.clear();
                                print(
                                    "------------- Send Message Done -----------");
                              },
                            ).onError(
                              (error, stackTrace) {
                                print("------------- Error  -----------");
                              },
                            );
                          }
                        },
                        icon: Icon(Iconsax.send_1))
                  ],
                ),
              ],
            ),
            Positioned(
                left: 0,
                bottom: 60,
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('rooms')
                      .doc(widget.roomId)
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
                    return unReadList.length != 0
                        ? Stack(
                            children: [
                              IconButton(
                                onPressed: () {
                                  controller.animateTo(0,
                                      duration: Duration(seconds: 1),
                                      curve: Curves.easeIn);
                                },
                                icon: Icon(
                                  Icons.expand_circle_down,
                                  size: 45,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              Positioned(
                                child: CircleAvatar(
                                  child: Text(
                                    unReadList.length.toString(),
                                  ),
                                  radius: 13,
                                ),
                                top: 0,
                                right: 5,
                              )
                            ],
                          )
                        : SizedBox();
                  },
                ))
          ],
        ),
      ),
    );
  }
}
