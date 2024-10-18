import 'package:chat_app_project/models/group_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../group/create_group.dart';
import '../group/widgets/group_card.dart';

class GroupHomeScreen extends StatefulWidget {
  const GroupHomeScreen({super.key});

  @override
  State<GroupHomeScreen> createState() => _GroupHomeScreenState();
}

class _GroupHomeScreenState extends State<GroupHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateGroupScreen(),
                ));
          },
          child: Icon(Iconsax.message_add_1),
        ),
        appBar: AppBar(
          title: Text("Groups"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('groups')
                        .where('members',
                            arrayContains:
                                FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );

                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('No Groups available.'),
                        );
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Something went wrong!'),
                        );
                      }
                      if (snapshot.hasData) {
                        List<ChatGroup> items = snapshot.data!.docs
                            .map((e) => ChatGroup.fromJson(e.data()))
                            .toList()
                          ..sort(
                            (a, b) => b.lastMessageTime!
                                .compareTo(a.lastMessageTime!),
                          );
                        return ListView.builder(
                            // itemCount: snapshot.data!.size,
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              return GroupCard(chatGroup: items[index]);
                            });
                      } else {
                        return Container();
                      }
                    }),
              ),
            ],
          ),
        ));
  }
}
