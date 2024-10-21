import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../models/message_model.dart';
import '../chat_screen.dart';


class UnreadMessagesIndicator extends StatelessWidget {
  const UnreadMessagesIndicator({
    super.key,
    required this.roomId,
  });

  final String roomId;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: 0,
        bottom: 60,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('rooms')
              .doc(roomId)
              .collection('messages')
              .snapshots(),
          builder: (context, snapshot) {
            var unReadList = snapshot.data?.docs
                .map((e) => Message.fromJson(e.data()))
                .where((element) => element.read == "")
                .where(
                  (element) =>
              element.fromId !=
                  FirebaseAuth.instance.currentUser!.uid,
            ) ??
                [];
            return unReadList.isNotEmpty
                ? Stack(
              children: [
                IconButton(
                  onPressed: () {
                    controller
                        .animateTo(0,
                        duration: const Duration(seconds: 1),
                        curve: Curves.easeIn)
                        .then(
                          (value) {
                        unReadList = [];
                      },
                    );
                  },
                  icon: Icon(
                    Icons.expand_circle_down,
                    size: 45,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 5,
                  child: CircleAvatar(
                    radius: 13,
                    child: Text(
                      unReadList.length.toString(),
                    ),
                  ),
                )
              ],
            )
                : const SizedBox();
          },
        ));
  }
}
