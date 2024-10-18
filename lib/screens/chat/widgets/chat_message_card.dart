import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_project/models/message_model.dart';
import 'package:chat_app_project/utils/photo_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class ChatMessageCard extends StatefulWidget {
  final Message message;
  final String roomId;
  final bool selected;

  const ChatMessageCard(
      {super.key,
      required this.message,
      required this.roomId,
      required this.selected});

  @override
  State<ChatMessageCard> createState() => _ChatMessageCardState();
}

class _ChatMessageCardState extends State<ChatMessageCard> {
  String myId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    // bool isMe = message.fromId == FirebaseAuth.instance.currentUser!.uid;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        color: widget.selected
            ? Theme.of(context).colorScheme.inversePrimary
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: widget.message.fromId == myId
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          widget.message.fromId == myId
              ? IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Iconsax.message_edit,
                  ),
                )
              : SizedBox(),
          Card(
            color: widget.message.fromId == myId
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.secondaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomRight:
                    Radius.circular(widget.message.fromId == myId ? 0 : 16),
                bottomLeft:
                    Radius.circular(widget.message.fromId == myId ? 16 : 0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width / 2 + 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    widget.message.type == 'image'
                        ? GestureDetector(
                            child: Container(
                              // child: Image.network(message.msg.toString()) ,
                              child: CachedNetworkImage(
                                imageUrl: widget.message.msg.toString(),
                                placeholder: (context, url) {
                                  return Container(
                                    height: 100,
                                  );
                                },
                              ),
                            ),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PhotoViewScreen(
                                    image: widget.message.msg!,
                                  ),
                                )),
                          )
                        : Text(widget.message.msg.toString()),
                    const Gap(5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        widget.message.fromId == myId
                            ? Icon(
                                Iconsax.tick_circle,
                                size: 14,
                                color: widget.message.read == ""
                                    ? Colors.grey
                                    : Colors.blue,
                              )
                            : SizedBox(),
                        Gap(4),
                        Text(
                          DateFormat('h:mm a').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(widget.message.createdAt!))),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                      mainAxisSize: MainAxisSize.min,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
