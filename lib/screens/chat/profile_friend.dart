import 'dart:io';

import 'package:chat_app_project/models/user_model.dart';
import 'package:chat_app_project/utils/date_time.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../firebase/fire_database.dart';
import '../../utils/constants.dart';
import '../../utils/photo_view.dart';

import 'chat_screen.dart';

class ProfileFriendScreen extends StatefulWidget {
  final ChatUser chatUser;

  const ProfileFriendScreen({super.key, required this.chatUser});

  @override
  State<ProfileFriendScreen> createState() => _ProfileFriendScreenState();
}

class _ProfileFriendScreenState extends State<ProfileFriendScreen> {
  TextEditingController nameCon = TextEditingController();
  TextEditingController aboutCon = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
     inAsyncCall: isLoading,
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(kPadding),
            child: SingleChildScrollView(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.chatUser.id)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        ChatUser user = ChatUser.fromJson(snapshot.data!.data()!);
                        return Column(
                          children: [
                            const Gap(20),
                            Center(
                              child: user.image == ""
                                  ? const CircleAvatar(
                                      radius: 90,
                                      child: Icon(
                                        Iconsax.user,
                                        size: 60,
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PhotoViewScreen(
                                                image: user.image!,
                                              ),
                                            ));
                                      },
                                      child: CircleAvatar(
                                        radius: 90,
                                        backgroundImage:
                                            NetworkImage(user.image!),
                                      ),
                                    ),
                            ),
                            // Center(
                            //   child: widget.chatUser.image != ""
                            //       ? ClipRRect(
                            //           borderRadius: BorderRadius.circular(12),
                            //           child: Image.network(widget.chatUser.image!),
                            //         )
                            //       : Container(),
                            // ),
                            const Gap(20),
                            Text(
                              user.name!,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),

                            const Gap(10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      List members = [
                                        FirebaseAuth.instance.currentUser!.uid,
                                        widget.chatUser.id
                                      ]..sort((a, b) => a!.compareTo(b!));
                                      FireData().createRoom(user.email!).then(
                                            (value) => Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ChatScreen(
                                                  roomId: members.toString(),
                                                  chatUser: user,
                                                ),
                                              ),
                                            ),
                                          );
                                      setState(() {
                                        isLoading = true;
                                      });
                                    },
                                    icon: const Icon(
                                      Iconsax.message,
                                      size: 35,
                                    )),
                                const Gap(20),
                                IconButton(
                                    onPressed: () async {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      await FireData()
                                          .addContact(widget.chatUser.email!)
                                          .then(
                                        (value) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      "Contact added successfully")));
                                          setState(() {
                                            isLoading = false;
                                          });
                                        },
                                      );
                                    },
                                    icon: const Icon(
                                      Iconsax.user_add,
                                      size: 35,
                                    )),
                              ],
                            ),

                            const Gap(10),
                            Card(
                              child: ListTile(
                                  leading: const Icon(Iconsax.user_octagon),
                                  title: const Text("Name"),
                                  subtitle: Text(user.name!)),
                            ),
                            Card(
                              child: ListTile(
                                  leading: const Icon(Iconsax.information),
                                  title: const Text("About"),
                                  subtitle: Text(user.about!)),
                            ),
                            Card(
                              child: ListTile(
                                  leading: const Icon(Iconsax.direct),
                                  title: const Text("Email"),
                                  subtitle: Text(user.email!)),
                            ),
                            Card(
                              child: ListTile(
                                  leading: const Icon(Iconsax.timer_1),
                                  title: const Text("Joined On"),
                                  subtitle: Text(
                                      '${myDateTime.dateAndTime(user.createdAt!)} at ${myDateTime.onlyTime(widget.chatUser.createdAt!)}')),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        );
                      } else {
                        return Container();
                      }
                    })),
          )),
    );
  }
}
