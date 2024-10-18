import 'package:chat_app_project/firebase/fire_database.dart';
import 'package:chat_app_project/models/group_model.dart';
import 'package:chat_app_project/screens/home/group_home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../layout.dart';
import '../../models/user_model.dart';
import '../../widgets/text_field.dart';

class EditGroupScreen extends StatefulWidget {
  ChatGroup chatGroup;

  EditGroupScreen({super.key, required this.chatGroup});

  @override
  State<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  TextEditingController gNameCon = TextEditingController();
  List<String> gMembers = [];

  @override
  void initState() {
    gNameCon.text = widget.chatGroup.name!;
    FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.chatGroup.id)
        .get()
        .then((snapshot) {
      setState(() {
        widget.chatGroup = ChatGroup.fromJson(snapshot.data()!);
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            FireData()
                .editGroup(
                    groupId: widget.chatGroup.id!,
                    newGName: gNameCon.text,
                    members: gMembers)
                .then(
              (value) {
                print("------------ edit done ------------");
                setState(() {
                  widget.chatGroup.members = gMembers;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("Edit Done")));
              },
            ).onError(
              (error, stackTrace) {
                print("------------------ Error ---------------");
              },
            );
          },
          label: Text("Done"),
          icon: Icon(Iconsax.tick_circle),
        ),
        appBar: AppBar(
          title: Text("Edit Group"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 40,
                        ),
                        Positioned(
                            bottom: -10,
                            right: -10,
                            child: IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.add_a_photo)))
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: CustomField(
                      controller: gNameCon,
                      icon: Iconsax.user_octagon,
                      lable: "Group Name",
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Divider(),
              SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  const Text("Add Members"),
                  const Spacer(),
                  Text("${gMembers.length}"),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Expanded(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List myContacts = snapshot.data!.data()!['my_contacts'];
                        return StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .where('id',
                                  whereIn:
                                      myContacts.isEmpty ? [''] : myContacts)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List<ChatUser> itemContacts = snapshot.data!.docs
                                  .map(
                                    (e) => ChatUser.fromJson(e.data()),
                                  )
                                  .where(
                                    (element) =>
                                        element.id !=
                                        FirebaseAuth.instance.currentUser!.uid,
                                  )
                                  .where(
                                    (element) => !widget.chatGroup.members!
                                        .contains(element.id),
                                  )
                                  .toList()
                                ..sort(
                                  (a, b) => a.name!.compareTo(b.name!),
                                );
                              return ListView.builder(
                                  itemCount: itemContacts.length,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      child: CheckboxListTile(
                                        checkboxShape: const CircleBorder(),
                                        title: ListTile(
                                          leading: CircleAvatar(
                                            child: Text(itemContacts[index]
                                                .name!
                                                .characters
                                                .first),
                                          ),
                                          title: Text(itemContacts[index]
                                              .name
                                              .toString()),
                                        ),
                                        value: gMembers
                                            .contains(itemContacts[index].id),
                                        onChanged: (value) {
                                          setState(() {
                                            if (value!) {
                                              gMembers
                                                  .add(itemContacts[index].id!);
                                            } else {
                                              gMembers.remove(
                                                  itemContacts[index].id!);
                                            }
                                          });
                                        },
                                      ),
                                    );
                                  });
                            } else {
                              return Container();
                            }
                          },
                        );
                      } else {
                        return Container();
                      }
                    }),
              )
            ],
          ),
        ));
  }
}
