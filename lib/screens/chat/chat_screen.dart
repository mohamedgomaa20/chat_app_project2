import 'dart:io';

import 'package:chat_app_project/firebase/fire_database.dart';
import 'package:chat_app_project/firebase/fire_storage.dart';
import 'package:chat_app_project/models/message_model.dart';
import 'package:chat_app_project/models/user_model.dart';
import 'package:chat_app_project/screens/chat/widgets/chat_message_card.dart';
import 'package:chat_app_project/screens/chat/widgets/text_field_for_message.dart';
import 'package:chat_app_project/screens/chat/widgets/unread_messages_indicator.dart';
import 'package:chat_app_project/screens/chat/widgets/user_avatar.dart';
import 'package:chat_app_project/utils/constants.dart';
import 'package:chat_app_project/utils/date_time.dart';
import 'package:chat_app_project/utils/show_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../utils/show_alert_dialog.dart';
import '../../widgets/say_hello.dart';
import 'profile_friend.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.roomId, required this.chatUser});

  final String roomId;
  final ChatUser chatUser;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

TextEditingController messageCon = TextEditingController();
ScrollController controller = ScrollController();

class _ChatScreenState extends State<ChatScreen> {
  List<String> selectedMsg = [];
  List<String> copyMsg = [];
  List<String> editMessageId = [];
  bool isEditing = false;
  String? editingMessageId;
  bool messageFromMe = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: selectedMsg.isEmpty
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.arrow_back)),
                    const Gap(5),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.chatUser.id)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          ChatUser user =
                              ChatUser.fromJson(snapshot.data!.data()!);
                          return Row(
                            children: [
                              UserAvatar(
                                name: user.name!,
                                imageUrl: user.image!,
                                online: user.online!,
                                radius: 22,
                              ),
                              const Gap(10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    user.online!
                                        ? "Active Now"
                                        : "Last Seen ${MyDateTime.dateAndTime(widget.chatUser.lastActivated!)} at ${MyDateTime.onlyTime(widget.chatUser.lastActivated!)}",
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            ],
                          );
                        } else {
                          return Container();
                        }
                      },
                    )
                  ],
                )
              : InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.close)),
          actions: [
            Row(
              children: [
                selectedMsg.isEmpty && copyMsg.isEmpty
                    ? IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileFriendScreen(
                                  chatUser: widget.chatUser,
                                ),
                              ));
                        },
                        icon: const Icon(Iconsax.user))
                    : const SizedBox(),
                selectedMsg.isNotEmpty && messageFromMe
                    ? IconButton(
                        onPressed: () {
                          showAlertDialog(
                            context: context,
                            content:
                                "Are you sure you want to delete this message? This action cannot be undone.",
                            txtNo: "Cancel",
                            txtYes: "Delete",
                            onPressedYes: () {
                              Navigator.pop(context); // Close the dialog
                              setState(() {
                                isLoading = true; // Start loading
                              });

                              FireData()
                                  .deleteMessage(widget.roomId, selectedMsg)
                                  .then((value) {
                                showSnackBar(
                                  context: context,
                                  message: "Message deleted successfully.",
                                );
                                setState(() {
                                  copyMsg.clear();
                                  selectedMsg.clear();
                                  editingMessageId = null;
                                  isEditing = false;
                                  editMessageId = [];
                                });
                              }).catchError((error) {
                                showSnackBar(
                                  context: context,
                                  message:
                                      "An error occurred while trying to delete the message.",
                                );
                              }).whenComplete(() {
                                setState(() {
                                  isLoading = false; // Stop loading
                                });
                              });
                            },
                          );
                        },
                        icon: const Icon(Iconsax.trash),
                      )
                    : const SizedBox(),
                copyMsg.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          Clipboard.setData(
                                  ClipboardData(text: copyMsg.join('\n')))
                              .then(
                            (value) {
                              setState(() {
                                copyMsg.clear();
                                selectedMsg.clear();
                                editingMessageId = null;
                                isEditing = false;
                                editMessageId = [];
                              });
                            },
                          );
                        },
                        icon: const Icon(Iconsax.copy),
                      )
                    : const SizedBox(),
                copyMsg.length == 1 && messageFromMe
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            messageCon.text = copyMsg.first;
                            isEditing = true;
                            editingMessageId = editMessageId.first;
                          });
                        },
                        icon: const Icon(Iconsax.message_edit),
                      )
                    : Container(),
              ],
            )
          ],
        ),
        body: Padding(
          padding:
              const EdgeInsets.symmetric(vertical: 5, horizontal: kPadding),
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
                                        FirebaseAuth
                                            .instance.currentUser!.uid &&
                                    message.read == "") {
                                  // Mark the message as read
                                  FireData().readMessage(
                                    roomId: widget.roomId,
                                    msgId: message.id!,
                                  );
                                }

                                // Today or Yesterday or any date

                                String newDate = '';
                                bool isSameDate = false;

                                if ((index == 0 && messageList.length == 1) ||
                                    index == messageList.length - 1) {
                                  newDate = MyDateTime.dateAndTime(
                                      messageList[index].createdAt!);
                                } else {
                                  final DateTime dateThisMsg =
                                      MyDateTime.dateFormat(
                                          messageList[index].createdAt!);
                                  final DateTime datePreviousMsg =
                                      MyDateTime.dateFormat(
                                          messageList[index + 1].createdAt!);

                                  isSameDate = dateThisMsg
                                      .isAtSameMomentAs(datePreviousMsg);

                                  newDate = isSameDate
                                      ? ""
                                      : MyDateTime.dateAndTime(
                                          messageList[index].createdAt!);
                                }

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedMsg.isNotEmpty
                                          ? selectedMsg.contains(
                                                  messageList[index].id)
                                              ? selectedMsg
                                                  .remove(messageList[index].id)
                                              : selectedMsg
                                                  .add(messageList[index].id!)
                                          : null;
                                      if (copyMsg.isNotEmpty) {
                                        if (messageList[index].type == 'text') {
                                          if (copyMsg.contains(
                                              messageList[index].msg)) {
                                            copyMsg
                                                .remove(messageList[index].msg);
                                            editMessageId
                                                .remove(messageList[index].id);
                                          } else {
                                            copyMsg
                                                .add(messageList[index].msg!);
                                            editMessageId
                                                .add(messageList[index].id!);
                                          }
                                        }
                                      }
                                      messageFromMe =
                                          messageList[index].fromId ==
                                              FirebaseAuth
                                                  .instance.currentUser!.uid;
                                    });
                                  },
                                  onLongPress: () {
                                    setState(() {
                                      selectedMsg
                                              .contains(messageList[index].id)
                                          ? selectedMsg
                                              .remove(messageList[index].id)
                                          : selectedMsg
                                              .add(messageList[index].id!);
                                      if (messageList[index].type == 'text') {
                                        if (copyMsg
                                            .contains(messageList[index].msg)) {
                                          copyMsg
                                              .remove(messageList[index].msg);
                                          editMessageId
                                              .remove(messageList[index].id);
                                        } else {
                                          copyMsg.add(messageList[index].msg!);
                                          editMessageId
                                              .add(messageList[index].id!);
                                        }
                                      }
                                      messageFromMe =
                                          messageList[index].fromId ==
                                              FirebaseAuth
                                                  .instance.currentUser!.uid;
                                    });
                                  },
                                  child: Column(
                                    children: [
                                      if (newDate != "")
                                        Center(
                                          child: Text(newDate),
                                        ),
                                      ChatMessageCard(
                                        selected: selectedMsg
                                            .contains(messageList[index].id),
                                        roomId: widget.roomId,
                                        message: message,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          } else {
                            return SayAssalamuAlaikum(
                              onTap: () {
                                FireData().sendMessage(
                                  friendId: widget.chatUser.id!,
                                  msg: "Assalamu Alaikum 👋",
                                  roomId: widget.roomId,
                                );
                              },
                            );
                          }
                        }
                        return Container();
                      },
                    ),
                  ),
                  // Message input field
                  TextFieldForMessage(
                    isEditing: isEditing,
                    onPressed: () async {
                      if (messageCon.text.trim().isNotEmpty) {
                        if (isEditing) {
                          FireData()
                              .editMessage(
                            roomId: widget.roomId,
                            messageId: editingMessageId!,
                            editMessage: messageCon.text.trim(),
                          )
                              .then((value) {
                            showSnackBar(
                                context: context, message: 'Message Updated');

                            setState(() {
                              isEditing = false;
                              editingMessageId = null;
                              messageCon.clear();
                              copyMsg.clear();
                              selectedMsg.clear();
                              editMessageId = [];
                            });
                          });
                        } else {
                          await FireData()
                              .sendMessage(
                            friendId: widget.chatUser.id!,
                            msg: messageCon.text.trim(),
                            roomId: widget.roomId,
                          )
                              .then((value) {
                            messageCon.clear();
                          }).onError((error, stackTrace) {
                            showSnackBar(
                              context: context,
                              message:
                                  "An error occurred while sending the message.",
                            );
                          });
                        }
                      }
                    },
                    controller: messageCon,
                    onPressedCamera: () async {
                      ImagePicker picker = ImagePicker();
                      XFile? image = await picker.pickImage(
                        source: ImageSource.camera,
                      );
                      if (image != null) {
                        setState(() {
                          isLoading = true;
                        });
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
                            showSnackBar(
                                context: context,
                                message:
                                    'An error occurred while trying to send the message."');
                          },
                        );
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    onPressedGallery: () async {
                      ImagePicker picker = ImagePicker();
                      XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (image != null) {
                        setState(() {
                          isLoading = true;
                        });
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
                            showSnackBar(
                                context: context,
                                message:
                                    'An error occurred while trying to send the message."');
                          },
                        );
                      }
                      setState(() {
                        isLoading = false;
                      });
                    },
                  ),
                ],
              ),
              UnreadMessagesIndicator(roomId: widget.roomId)
            ],
          ),
        ),
      ),
    );
  }
}
