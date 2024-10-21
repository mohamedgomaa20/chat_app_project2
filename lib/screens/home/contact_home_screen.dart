import 'package:chat_app_project/firebase/fire_database.dart';
import 'package:chat_app_project/models/user_model.dart';
import 'package:chat_app_project/screens/contacts/contact_card.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../utils/constants.dart';

import 'bottom_sheet.dart';

class ContactHomeScreen extends StatefulWidget {
  const ContactHomeScreen({super.key});

  @override
  State<ContactHomeScreen> createState() => _ContactHomeScreenState();
}

class _ContactHomeScreenState extends State<ContactHomeScreen> {
  bool searched = false;
  TextEditingController emailCon = TextEditingController();
  TextEditingController searchCon = TextEditingController();
  List myContacts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          searched
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      searched = false;
                      searchCon.text = "";
                    });
                  },
                  icon: const Icon(Iconsax.close_circle))
              : IconButton(
                  onPressed: () {
                    setState(() {
                      searched = true;
                    });
                  },
                  icon: const Icon(Iconsax.search_normal))
        ],
        title: searched
            ? Row(
                children: [
                  Expanded(
                      child: TextField(
                    autofocus: true,
                    controller: searchCon,
                    onChanged: (value) {
                      setState(() {
                        searchCon.text = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: "Search by name",
                      border: InputBorder.none,
                    ),
                  ))
                ],
              )
            : const Text("My Contacts"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showBottomSheet(
            context: context,
            builder: (context) {
              return CreateBottomSheet(
                txtOfButton: "Add Contat",
                onPressed: () async {
                  QuerySnapshot friendEmail = await FirebaseFirestore.instance
                      .collection('users')
                      .where('email', isEqualTo: emailCon.text)
                      .get();

                  if (friendEmail.docs.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("This email does not exist")),
                    );
                  } else {
                    await FireData().addContact(emailCon.text).then(
                      (value) {
                        setState(() {
                          emailCon.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Contact added successfully")));
                          Navigator.pop(context);
                        });
                      },
                    ).onError((error, stackTrace) {
                      print("----------------- Some Error ----------------");
                    });
                  }
                },
                controller: emailCon,
              );
            },
          ).closed.then(
            (value) {
              emailCon.clear();
            },
          );
        },
        child: const Icon(Iconsax.user_add),
      ),
      body: Padding(
          padding: const EdgeInsets.all(kPadding),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        myContacts =
                            snapshot.data!.data()!['my_contacts'] ?? [];

                        return StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .where('id',
                                  whereIn:
                                      myContacts.isEmpty ? [''] : myContacts)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return const Center(
                                child: Text('No Contacts available.'),
                              );
                            }
                            if (snapshot.hasData) {
                              List<ChatUser> itemContacts = snapshot.data!.docs
                                  .map(
                                    (e) => ChatUser.fromJson(e.data()),
                                  )
                                  .where(
                                    (element) => element.name!
                                        .toLowerCase()
                                        .startsWith(
                                            searchCon.text.toLowerCase()),
                                  )
                                  .toList()
                                ..sort(
                                  (a, b) => a.name!.compareTo(b.name!),
                                );
                              return ListView.builder(
                                  itemCount: itemContacts.length,
                                  itemBuilder: (context, index) {
                                    return ContactCard(
                                      user: itemContacts[index],
                                    );
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
              ),
            ],
          )),
    );
  }
}
