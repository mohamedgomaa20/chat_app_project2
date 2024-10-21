import 'package:chat_app_project/firebase/fire_database.dart';
import 'package:chat_app_project/models/user_model.dart';
import 'package:chat_app_project/screens/chat/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ContactCard extends StatelessWidget {
 final ChatUser user;

 const ContactCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: user.image == ""
            ? const CircleAvatar(
                radius: 30,
                child: Icon(Iconsax.user),
              )
            : CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(user.image!),
              ),
        title: Text(user.name.toString()),
        subtitle: Text(user.email.toString()),
        trailing: IconButton(
          onPressed: () {
            List<String> members = [
              user.id!,
              FirebaseAuth.instance.currentUser!.uid
            ]..sort((a, b) => a.compareTo(b));

            FireData().createRoom(user.email!).then(
                  (value) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        roomId: members.toString(),
                        chatUser: user,
                      ),
                    ),
                  ),
                );
          },
          icon: const Icon(Iconsax.message),
        ),
        // title: Text(users[index].id.toString()),
      ),
    );
  }
}
