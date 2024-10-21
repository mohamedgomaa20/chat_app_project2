import 'dart:io';

import 'package:chat_app_project/firebase/fire_database.dart';
import 'package:chat_app_project/utils/constants.dart';
import 'package:chat_app_project/utils/show_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../firebase/fire_storage.dart';
import '../../models/user_model.dart';
import '../../widgets/text_form_field.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  TextEditingController gNameCon = TextEditingController();
  List<String> gMembers = [];
  String _groupImage = '';
  bool isLoading = false;
 
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        floatingActionButton: gMembers.isNotEmpty && gNameCon.text.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  if (gNameCon.text.isNotEmpty && gMembers.isNotEmpty) {
                    await FireData().createGroup(gNameCon.text, gMembers).then(
                      (groupId) async {
                        if (groupId != null) {
                          if (_groupImage.isNotEmpty) {
                            await FireStorage()
                                .updateGroupImage(
                                    file: File(_groupImage), groupId: groupId)
                                .then((value) {})
                                .onError((error, stackTrace) {
                              showSnackBar(
                                  context: context,
                                  message:
                                      'Error updating group image: $error');
                            });
                          }
                          showSnackBar(
                              context: context,
                              message: "Group Created Successfully");
                          Navigator.pop(context);
                        } else {
                          showSnackBar(
                              context: context,
                              message:
                                  "Error creating group. Please try again.");
                        }
                        setState(() {
                          isLoading = false;
                        });
                      },
                    ).onError((error, stackTrace) {
                      showSnackBar(
                          context: context,
                          message: "Error: ${error.toString()}");
                    });
                  }
                },
                label: const Text("Done"),
                icon: const Icon(Iconsax.tick_circle),
              )
            : const SizedBox(),
        appBar: AppBar(
          title: const Text("Create Group"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(kPadding),
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
                        _groupImage == ''
                            ? const CircleAvatar(
                                radius: 40,
                                child: Icon(
                                  Iconsax.user,
                                  size: 20,
                                ),
                              )
                            : CircleAvatar(
                                radius: 40,
                                backgroundImage: FileImage(File(_groupImage)),
                              ),
                        Positioned(
                            bottom: -10,
                            right: -10,
                            child: IconButton(
                                onPressed: () async {
                                  ImagePicker imagePicker = ImagePicker();
                                  XFile? image = await imagePicker.pickImage(
                                      source: ImageSource.gallery);
                                  if (image != null) {
                                    setState(() {
                                      _groupImage = image.path;
                                    });
                                  }
                                },
                                icon: const Icon(
                                  Iconsax.edit,
                                  size: 20,
                                )))
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: CustomTextFormField(
                      controller: gNameCon,
                      prefixIcon: Iconsax.user_octagon,
                      label: "Group Name",
                    ),
                  ),
                ],
              ),
              const Divider(
                height: 50,
              ),
              Row(
                children: [
                  const Text("Add Members"),
                  const Spacer(),
                  Text("${gMembers.length}"),
                ],
              ),
              const SizedBox(
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
                        List myContacts =
                            snapshot.data!.data()?['my_contacts'] ?? [];

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
                                  .map((e) => ChatUser.fromJson(e.data()))
                                  .where((element) =>
                                      element.id !=
                                      FirebaseAuth.instance.currentUser!.uid)
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
                                            leading: itemContacts[index]
                                                        .image ==
                                                    ""
                                                ? const CircleAvatar(
                                                    radius: 30,
                                                    child: Icon(Iconsax.user),
                                                  )
                                                : CircleAvatar(
                                                    radius: 30,
                                                    backgroundImage:
                                                        NetworkImage(
                                                            itemContacts[index]
                                                                .image!),
                                                  ),
                                            title: Text(itemContacts[index]
                                                .name
                                                .toString()),
                                            subtitle: Text(itemContacts[index]
                                                .email
                                                .toString())),
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
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          },
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
