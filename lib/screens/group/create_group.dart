import 'package:chat_app_project/firebase/fire_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../models/user_model.dart';
import '../../widgets/text_field.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  TextEditingController gNameCon = TextEditingController();
  List<String> gMembers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: gMembers.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () async {
             if(gNameCon.text.isNotEmpty){
               await FireData().createGroup(gNameCon.text, gMembers).then(
                     (value) {
                   print("---------------- Created Done ---------------");
                   Navigator.pop(context);
                   ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text("Created Done")));
                 },
               ).onError(
                     (error, stackTrace) {
                   print("--------------- Error ----------------");
                   print(error.toString());
                 },
               );
             }
                },
                label: Text("Done"),
                icon: Icon(Iconsax.tick_circle),
              )
            : SizedBox(),
        appBar: AppBar(
          title: Text("Create Group"),
        ),
        body:
        Padding(
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
                                onPressed: () {}, icon: Icon(Iconsax.camera)))
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
                                            print(gMembers);
                                          });
                                        },
                                      ),
                                    );
                                    // ContactCard(
                                    //   user: itemContacts[index],
                                    // );
                                    // ChatCard(item: items[index]);
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
