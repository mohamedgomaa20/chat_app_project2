import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_project/models/message_model.dart';
import 'package:chat_app_project/utils/photo_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import '../../../utils/date_time.dart';

class ChatMessageCard extends StatefulWidget {
  final Message message;
  final String roomId;
  final bool selected;

  const ChatMessageCard(
      {super.key, required this.message, required this.roomId, required this.selected});

  @override
  State<ChatMessageCard> createState() => _ChatMessageCardState();
}

class _ChatMessageCardState extends State<ChatMessageCard> {
  String myId = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController msgCon = TextEditingController();

   bool isArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    bool isMe = widget.message.fromId == FirebaseAuth.instance.currentUser!.uid;
    bool messageIsArabic = isArabic(widget.message.msg!);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: .5),
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
              padding: const EdgeInsets.all(10),
              child: Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width / 2 + 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    widget.message.type == 'image'
                        ? GestureDetector(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: widget.message.msg.toString(),
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
                              image: widget.message.msg!,
                            ),
                          )),
                    )
                        : Text(
                      widget.message.msg!,
                      textDirection: messageIsArabic
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                    ),
                    // Text("dcd",tes),
                    const Gap(3),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        widget.message.fromId == myId
                            ? Icon(
                          Iconsax.tick_circle,
                          size: 14,
                          color: widget.message.read == ""
                              ? Colors.grey
                              : Colors.blue,
                        )
                            : const SizedBox(),
                        const Gap(4),
                        Text(
                          MyDateTime.onlyTime(widget.message.createdAt!),
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
  }
}




// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:chat_app_project/models/message_model.dart';
// import 'package:chat_app_project/utils/photo_view.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// import 'package:gap/gap.dart';
// import 'package:iconsax/iconsax.dart';
//
// import '../../../utils/date_time.dart';
//
// class ChatMessageCard extends StatefulWidget {
//   final Message message;
//   final String roomId;
//   final bool selected;
//
//   const ChatMessageCard(
//       {super.key,
//       required this.message,
//       required this.roomId,
//       required this.selected});
//
//   @override
//   State<ChatMessageCard> createState() => _ChatMessageCardState();
// }
//
// class _ChatMessageCardState extends State<ChatMessageCard> {
//   String myId = FirebaseAuth.instance.currentUser!.uid;
//   TextEditingController msgCon = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     bool isMe = widget.message.fromId == FirebaseAuth.instance.currentUser!.uid;
//
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: .5),
//       decoration: BoxDecoration(
//         color: widget.selected
//             ? Theme.of(context).colorScheme.inversePrimary
//             : Colors.transparent,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisAlignment: widget.message.fromId == myId
//             ? MainAxisAlignment.end
//             : MainAxisAlignment.start,
//         children: [
//           Card(
//             color: widget.message.fromId == myId
//                 ? Theme.of(context).colorScheme.primaryContainer
//                 : Theme.of(context).colorScheme.secondaryContainer,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.only(
//                 topLeft: const Radius.circular(16),
//                 topRight: const Radius.circular(16),
//                 bottomRight:
//                     Radius.circular(widget.message.fromId == myId ? 0 : 16),
//                 bottomLeft:
//                     Radius.circular(widget.message.fromId == myId ? 16 : 0),
//               ),
//             ),
//             child: Padding(
//               // padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 8),
//               padding: const EdgeInsets.all(10),
//               child: Container(
//                 constraints: BoxConstraints(
//                     maxWidth: MediaQuery.sizeOf(context).width / 2 + 50),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     widget.message.type == 'image'
//                         ? GestureDetector(
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(12),
//                               child: CachedNetworkImage(
//                                 imageUrl: widget.message.msg.toString(),
//                                 placeholder: (context, url) {
//                                   return Container(
//                                     height: 120,
//                                   );
//                                 },
//                               ),
//                             ),
//                             onTap: () => Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => PhotoViewScreen(
//                                     image: widget.message.msg!,
//                                   ),
//                                 )),
//                           )
//                         : Text(widget.message.msg!),
//                     const Gap(3),
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         widget.message.fromId == myId
//                             ? Icon(
//                                 Iconsax.tick_circle,
//                                 size: 14,
//                                 color: widget.message.read == ""
//                                     ? Colors.grey
//                                     : Colors.blue,
//                               )
//                             : const SizedBox(),
//                         const Gap(4),
//                         Text(
//                           myDateTime.onlyTime(widget.message.createdAt!),
//                           style: Theme.of(context).textTheme.labelSmall,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
