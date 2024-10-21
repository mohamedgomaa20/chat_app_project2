import 'package:chat_app_project/models/group_model.dart';
import 'package:chat_app_project/utils/date_time.dart';
import 'package:flutter/material.dart';

import '../group_screen.dart';

class GroupCard extends StatelessWidget {
  final ChatGroup chatGroup;

  const GroupCard({super.key, required this.chatGroup});

  bool isArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GroupScreen(
                    chatGroup: chatGroup,
                  )),
        ),
        leading: chatGroup.image == ""
            ? CircleAvatar(
                radius: 30,
                child: Text(chatGroup.name.toString().characters.first),
              )
            : CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(chatGroup.image!),
              ),
        title: Text(chatGroup.name.toString()),
        subtitle: chatGroup.lastMessage == ""
            ? const Text("send first message")
            : Text(
                chatGroup.lastMessage.toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textDirection: isArabic(chatGroup.lastMessage.toString())
                    ? TextDirection.rtl
                    : TextDirection.ltr,
              ),
        trailing: Text(MyDateTime.onlyTime(chatGroup.lastMessageTime!)),
      ),
    );
  }
}
