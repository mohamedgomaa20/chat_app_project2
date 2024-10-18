import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../models/message_model.dart';

class GroupMessageCard extends StatelessWidget {
  final int index;
  Message message;

  GroupMessageCard({super.key, required this.index, required this.message});

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
          return Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              isMe
                  ? IconButton(
                      onPressed: () {}, icon: Icon(Iconsax.message_edit))
                  : SizedBox(),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(isMe ? 16 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 16),
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                )),
                color: isMe
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width / 2
                    +20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        !isMe
                            ? Text(
                                name+': ',
                               style: Theme.of(context).textTheme.labelLarge,
                              )
                            : SizedBox(),
                        SizedBox(
                          height: 4,
                        ),
                        Text(message.msg!),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            isMe
                                ? Icon(
                                    Iconsax.tick_circle,
                                    color: Colors.blueAccent,
                                    size: 18,
                                  )
                                : SizedBox(),
                            SizedBox(
                              width: 6,
                            ),
                            Text(
                              DateFormat('h:mm a').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(message.createdAt!))),
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
          );
        } else {
          return Container();
        }
      },
    );
  }
}
