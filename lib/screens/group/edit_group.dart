import 'dart:io';
import 'package:chat_app_project/utils/constants.dart';
import 'package:chat_app_project/utils/show_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../firebase/fire_database.dart';
import '../../firebase/fire_storage.dart';
import '../../models/group_model.dart';
import '../../models/user_model.dart';
import '../../widgets/text_form_field.dart';

class EditGroupScreen extends StatefulWidget {
   ChatGroup chatGroup;

   EditGroupScreen({super.key, required this.chatGroup});

  @override
  State<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  TextEditingController gNameCon = TextEditingController();
  List<String> gMembers = [];
  File? _selectedImage;
  bool isLoading = false;

  @override
  void initState() {
    FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.chatGroup.id)
        .get()
        .then((snapshot) {
      setState(() {
        widget.chatGroup = ChatGroup.fromJson(snapshot.data()!);
        gNameCon.text = widget.chatGroup.name!;
      });
    });

    super.initState();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            setState(() {
              isLoading = true;
            });

            if (_selectedImage != null) {
              await FireStorage().updateGroupImage(
                file: _selectedImage!,
                groupId: widget.chatGroup.id!,
              );
            }

            await FireData()
                .editInfoGroup(
              groupId: widget.chatGroup.id!,
              newGroupName: gNameCon.text,
              membersId: gMembers,
            )
                .then(
              (value) {
                setState(() {
                  widget.chatGroup.members = gMembers;
                });
                Navigator.pop(context);
                showSnackBar(context: context, message: "Edit Done");
              },
            ).onError(
              (error, stackTrace) {
                print("Error: $error");
              },
            );
            setState(() {
              isLoading = false;
            });
          },
          label: const Text("Done"),
          icon: const Icon(Iconsax.tick_circle),
        ),
        appBar: AppBar(
          title: const Text("Edit Group"),
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
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (widget.chatGroup.image!.isNotEmpty
                                  ? NetworkImage(widget.chatGroup.image!)
                                  : null) as ImageProvider?,
                        ),
                        Positioned(
                          bottom: -10,
                          right: -10,
                          child: IconButton(
                            onPressed: _pickImage,
                            icon: const Icon(
                              Iconsax.edit,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
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
                                        element.id! !=
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
                                          leading: itemContacts[index].image == ""
                                              ? const CircleAvatar(
                                            radius: 30,
                                            child: Icon(Iconsax.user),
                                          )
                                              : CircleAvatar(
                                            radius: 30,
                                            backgroundImage: NetworkImage(
                                                itemContacts[index].image!),
                                          ),
                                          title: Text(itemContacts[index]
                                              .name
                                              .toString()),
                                          subtitle: Text(itemContacts[index]
                                              .email
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
        ),
      ),
    );
  }
}
