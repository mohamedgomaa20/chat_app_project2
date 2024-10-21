import 'dart:io';

import 'package:chat_app_project/firebase/fire_database.dart';
import 'package:chat_app_project/models/group_model.dart';
import 'package:chat_app_project/screens/chat/chat_screen.dart';
import 'package:chat_app_project/screens/group/widgets/group_message_card.dart';
import 'package:chat_app_project/utils/constants.dart';
import 'package:chat_app_project/utils/show_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../firebase/fire_storage.dart';
import '../../models/message_model.dart';
import '../../utils/date_time.dart';
import '../../utils/show_alert_dialog.dart';
import '../../widgets/say_hello.dart';
import '../chat/widgets/text_field_for_message.dart';
import '../chat/widgets/user_avatar.dart';
import 'group_member.dart';

class GroupScreen extends StatefulWidget {
  final ChatGroup chatGroup;

  const GroupScreen({super.key, required this.chatGroup});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  TextEditingController msgCon = TextEditingController();
  ScrollController controller = ScrollController();
  List<String> selectedMsg = [];
  List<String> copyMsg = [];
  List<String> editMessageId = [];
  String? editingMessageId;
  bool messageFromMe = false;
  bool isAdmin = false;
  bool isEditing = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .doc(widget.chatGroup.id)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List members = snapshot.data!['members'];
                  String groupName = snapshot.data!['name'];
                  ChatGroup chatGroup =
                      ChatGroup.fromJson(snapshot.data!.data()!);
                  isAdmin = chatGroup.adminsId!
                      .contains(FirebaseAuth.instance.currentUser!.uid);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.arrow_back),
                      ),
                      const Gap(5),
                      selectedMsg.isEmpty
                          ? Row(
                              children: [
                                UserAvatar(
                                  name: groupName,
                                  imageUrl: snapshot.data!['image'],
                                  online: false,
                                  radius: 22,
                                ),
                                const Gap(10),
                                StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .where('id', whereIn: members)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      List<String> membersNames = [];
                                      for (var userDoc in snapshot.data!.docs) {
                                        membersNames.add(
                                            userDoc['name'].split(' ').first);
                                      }
                                      return Container(
                                        width: 150,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              groupName,
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              membersNames.join(', '),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelLarge,
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      return Container();
                                    }
                                  },
                                ),
                              ],
                            )
                          : Container(),
                      Spacer(),
                      Expanded(
                        child: Row(
                          children: [
                            Spacer(),
                            selectedMsg.isEmpty && copyMsg.isEmpty
                                ? IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              GroupMemberScreen(
                                                  chatGroup: widget.chatGroup),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Iconsax.user),
                                  )
                                : const SizedBox(),
                            isAdmin && selectedMsg.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      showAlertDialog(
                                          context: context,
                                          content:
                                              "Are you sure you want to delete this message? This action cannot be undone.",
                                          txtNo: "Cancel",
                                          txtYes: "Delete",
                                          onPressedYes: () {
                                            FireData()
                                                .deleteMsgGroup(
                                                    widget.chatGroup.id!,
                                                    selectedMsg)
                                                .then(
                                              (value) {
                                                Navigator.pop(context);

                                                showSnackBar(
                                                    context: context,
                                                    message:
                                                        "Message deleted successfully.");
                                                setState(() {
                                                  copyMsg.clear();
                                                  selectedMsg.clear();
                                                  editingMessageId = null;
                                                  isEditing = false;
                                                  editMessageId = [];
                                                });
                                              },
                                            ).onError(
                                              (error, stackTrace) {
                                                showSnackBar(
                                                    context: context,
                                                    message:
                                                        "An error occurred while trying to delete the message.");
                                              },
                                            );
                                          });
                                    },
                                    icon: const Icon(Iconsax.trash),
                                  )
                                : const SizedBox(),
                            copyMsg.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(
                                              text: copyMsg.join('\n')))
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
                                        msgCon.text = copyMsg.first;
                                        isEditing = true;
                                        editingMessageId = editMessageId.first;
                                      });
                                    },
                                    icon: const Icon(Iconsax.message_edit),
                                  )
                                : Container(),
                          ],
                        ),
                      )
                    ],
                  );
                } else {
                  return Container();
                }
              }),
          // actions: [
          // ],
        ),
        body: Padding(
          padding:
              const EdgeInsets.symmetric(vertical: 5, horizontal: kPadding),
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

                      if (messageList.isNotEmpty) {
                        return ListView.builder(
                          reverse: true,
                          itemCount: messageList.length,
                          itemBuilder: (context, index) {
                            Message message = messageList[index];

                            // Check if the message is for the current user and hasn't been read

                            // if (message.toId ==
                            //     FirebaseAuth
                            //         .instance.currentUser!.uid &&
                            //     message.read == "") {
                            //   // Mark the message as read
                            //   FireData().readMsgGroup(
                            //     groupId: widget.chatGroup.id!,
                            //     msgId: message.id!,
                            //   );
                            // }

                            // Today or Yesterday or any date

                            String newDate = '';
                            bool isSameDate = false;

                            if ((index == 0 && messageList.length == 1) ||
                                index == messageList.length - 1) {
                              newDate = myDateTime
                                  .dateAndTime(messageList[index].createdAt!);
                            } else {
                              final DateTime dateThisMsg = myDateTime
                                  .dateFormat(messageList[index].createdAt!);
                              final DateTime datePreviousMsg =
                                  myDateTime.dateFormat(
                                      messageList[index + 1].createdAt!);

                              isSameDate =
                                  dateThisMsg.isAtSameMomentAs(datePreviousMsg);

                              newDate = isSameDate
                                  ? ""
                                  : myDateTime.dateAndTime(
                                      messageList[index].createdAt!);
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
                                  if (copyMsg.isNotEmpty) {
                                    if (messageList[index].type == 'text') {
                                      if (copyMsg
                                          .contains(messageList[index].msg)) {
                                        copyMsg.remove(messageList[index].msg);
                                        editMessageId
                                            .remove(messageList[index].id);
                                      } else {
                                        copyMsg.add(messageList[index].msg!);
                                        editMessageId
                                            .add(messageList[index].id!);
                                      }
                                    }
                                  }
                                  messageFromMe = messageList[index].fromId ==
                                      FirebaseAuth.instance.currentUser!.uid;
                                });
                              },
                              onLongPress: () {
                                setState(() {
                                  selectedMsg.contains(messageList[index].id)
                                      ? selectedMsg
                                          .remove(messageList[index].id)
                                      : selectedMsg.add(messageList[index].id!);
                                  if (messageList[index].type == 'text') {
                                    if (copyMsg
                                        .contains(messageList[index].msg)) {
                                      copyMsg.remove(messageList[index].msg);
                                      editMessageId
                                          .remove(messageList[index].id);
                                    } else {
                                      copyMsg.add(messageList[index].msg!);
                                      editMessageId.add(messageList[index].id!);
                                    }
                                  }
                                  messageFromMe = messageList[index].fromId ==
                                      FirebaseAuth.instance.currentUser!.uid;
                                });
                              },
                              child: Column(
                                children: [
                                  if (newDate != "")
                                    Center(
                                      child: Text(newDate),
                                    ),
                                  GroupMessageCard(
                                    selected: selectedMsg
                                        .contains(messageList[index].id),
                                    message: messageList[index],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      } else {
                        return SayAssalamuAlaikum(onTap: () {
                          FireData().sendGMessage(
                            msg: "Assalamu Alaikum 👋",
                            groupId: widget.chatGroup.id!,
                          );
                        });
                      }
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
              TextFieldForMessage(
                onPressed: () async {
                  if (msgCon.text.trim().isNotEmpty) {
                    if (isEditing) {
                      FireData()
                          .editMsgGroup(
                        groupId: widget.chatGroup.id!,
                        messageId: editingMessageId!,
                        editMessage: msgCon.text.trim(),
                      )
                          .then((value) {
                        print("------------- Message Updated -----------");
                        setState(() {
                          isEditing = false;
                          editingMessageId = null;
                          msgCon.clear();
                          copyMsg.clear();
                          selectedMsg.clear();
                          editMessageId = [];
                        });
                      });
                    } else {
                      await FireData()
                          .sendGMessage(
                              msg: msgCon.text, groupId: widget.chatGroup.id!)
                          .then((value) {
                        msgCon.clear();
                        print("------------- Send Message Done -----------");
                      });
                    }
                  }
                },
                controller: msgCon,
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
                        .sendGroupImage(
                      file: File(image.path),
                      groupId: widget.chatGroup.id!,
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
                        .sendGroupImage(
                      file: File(image.path),
                      groupId: widget.chatGroup.id!,
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
              )
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:chat_app_project/firebase/fire_database.dart';
// import 'package:chat_app_project/models/group_model.dart';
// import 'package:chat_app_project/screens/group/widgets/group_message_card.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:iconsax/iconsax.dart';
//
// import '../../models/message_model.dart';
// import '../../widgets/say_hello.dart';
// import '../chat/widgets/user_avatar.dart';
// import 'group_member.dart';
//
// class GroupScreen extends StatefulWidget {
//   ChatGroup chatGroup;
//
//   GroupScreen({super.key, required this.chatGroup});
//
//   @override
//   State<GroupScreen> createState() => _GroupScreenState();
// }
//
// class _GroupScreenState extends State<GroupScreen> {
//   TextEditingController msgCon = TextEditingController();
//   ScrollController controller = ScrollController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             InkWell(
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Icon(Icons.arrow_back)),
//             const Gap(5),
//             UserAvatar(
//               name: widget.chatGroup.name!,
//               imageUrl: widget.chatGroup.image!,
//               online: false,
//               radius: 22,
//             ),
//             const Gap(10),
//             Container(
//               width: 100,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(widget.chatGroup.name!),
//                   StreamBuilder(
//                     stream: FirebaseFirestore.instance
//                         .collection('groups')
//                         .doc(widget.chatGroup.id)
//                         .snapshots(),
//                     builder: (context, snapshot) {
//                       if (snapshot.hasData) {
//                         List members = snapshot.data!['members'];
//                         return StreamBuilder(
//                           stream: FirebaseFirestore.instance
//                               .collection('users')
//                               .where('id', whereIn: members)
//                               .snapshots(),
//                           builder: (context, snapshot) {
//                             if (snapshot.hasData) {
//                               List membersName = [];
//                               for (var userDoc in snapshot.data!.docs) {
//                                 membersName.add(userDoc['name'].split(' '));
//                               }
//                               return Text(
//                                 membersName.join(', '),
//                                 style: Theme.of(context).textTheme.labelLarge,
//                               );
//                             } else {
//                               return Container();
//                             }
//                           },
//                         );
//                       } else {
//                         return Container();
//                       }
//                     },
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         GroupMemberScreen(chatGroup: widget.chatGroup),
//                   ));
//             },
//             icon: const Icon(Iconsax.user),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
//         child: Column(
//           children: [
//             Expanded(
//               child: StreamBuilder(
//                 stream: FirebaseFirestore.instance
//                     .collection('groups')
//                     .doc(widget.chatGroup.id)
//                     .collection('messages')
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.hasData) {
//                     List<Message> messageList = snapshot.data!.docs
//                         .map(
//                           (e) => Message.fromJson(e.data()),
//                         )
//                         .toList()
//                       ..sort(
//                         (a, b) => b.createdAt!.compareTo(a.createdAt!),
//                       );
//                     if (messageList.isEmpty) {
//                       return SayAssalamuAlaikum(onTap: () {
//                         FireData().sendGMessage(
//                           msg: "Assalamu Alaikum 👋",
//                           groupId: widget.chatGroup.id!,
//                         );
//                       });
//                     } else {
//                       return ListView.builder(
//                         reverse: true,
//                         itemCount: messageList.length,
//                         itemBuilder: (context, index) {
//                           return GroupMessageCard(
//                             index: index,
//                             message: messageList[index],
//                           );
//                         },
//                       );
//                     }
//                   } else {
//                     return Container();
//                   }
//                 },
//               ),
//             ),
//             Row(
//               children: [
//                 Expanded(
//                   child: Card(
//                     child: TextField(
//                       maxLines: 5,
//                       minLines: 1,
//                       controller: msgCon,
//                       decoration: InputDecoration(
//                           suffixIcon: Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 onPressed: () {},
//                                 icon: const Icon(Iconsax.emoji_happy),
//                               ),
//                               IconButton(
//                                 onPressed: () {},
//                                 icon: const Icon(Iconsax.camera),
//                               ),
//                             ],
//                           ),
//                           border: InputBorder.none,
//                           hintText: "Message",
//                           contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 10)),
//                     ),
//                   ),
//                 ),
//                 IconButton.filled(
//                     onPressed: () async {
//                       if (msgCon.text.isNotEmpty) {
//                         await FireData()
//                             .sendGMessage(
//                                 msg: msgCon.text, groupId: widget.chatGroup.id!)
//                             .then(
//                           (value) {
//                             print("------------- send done ---------------");
//                             setState(() {
//                               msgCon.clear();
//                             });
//                           },
//                         ).onError(
//                           (error, stackTrace) {
//                             print("------------- error ---------------");
//                           },
//                         );
//                       }
//                     },
//                     icon: Icon(Iconsax.send_1))
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
