import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_project/utils/date_time.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../models/message_model.dart';
import '../../../utils/photo_view.dart';

class GroupMessageCard extends StatelessWidget {
  final Message message;
  final bool selected;

  const GroupMessageCard(
      {super.key, required this.message, required this.selected});

  @override
  Widget build(BuildContext context) {
    bool isMe = message.fromId == FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(message.fromId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          String name = snapshot.data!.data()!['name'];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: .5),
            decoration: BoxDecoration(
              // Color of Selected Message
              color: selected
                  ? Theme.of(context).colorScheme.inversePrimary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment:
                  isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                // isMe
                //     ? IconButton(
                //         onPressed: () {}, icon: const Icon(Iconsax.message_edit))
                //     : const SizedBox(),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(isMe ? 16 : 0),
                    bottomRight: Radius.circular(isMe ? 0 : 16),
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                  )),
                  color: isMe
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.sizeOf(context).width / 2 + 50),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          !isMe
                              ? Text(
                                  '$name ',
                                  style: Theme.of(context).textTheme.labelLarge,
                                )
                              : const SizedBox(),
                          const SizedBox(
                            height: 2,
                          ),
                          message.type == 'image'
                              ? GestureDetector(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl: message.msg.toString(),
                                      placeholder: (context, url) {
                                        return Container(
                                          height: 120,
                                        );
                                      },
                                    ),
                                  ),
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PhotoViewScreen(
                                          image: message.msg!,
                                        ),
                                      )),
                                )
                              : Text(message.msg!),
                          const SizedBox(
                            height: 4,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              isMe
                                  ? const Icon(
                                      Iconsax.tick_circle,
                                      color: Colors.blueAccent,
                                      size: 18,
                                    )
                                  : const SizedBox(),
                              const SizedBox(
                                width: 6,
                              ),
                              Text(
                                myDateTime.onlyTime(message.createdAt!),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
