import 'dart:io';

import 'package:chat_app_project/firebase/fire_database.dart';
import 'package:chat_app_project/firebase/fire_storage.dart';
import 'package:chat_app_project/layout.dart';
import 'package:chat_app_project/models/user_model.dart';
import 'package:chat_app_project/provider/provider.dart';
import 'package:chat_app_project/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../utils/constants.dart';
import '../../utils/date_time.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController nameCon = TextEditingController();
  TextEditingController aboutCon = TextEditingController();
  ChatUser? me;
  String _image = '';
  bool nameEdit = false;
  bool aboutEdit = false;

  @override
  void initState() {
    me = Provider.of<ProviderApp>(context, listen: false).me;
    nameCon.text = me!.name!;
    aboutCon.text = me!.about!;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(kPadding),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Gap(20),
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _image == ''
                        ? me!.image == ""
                            ? const CircleAvatar(
                                radius: 80,
                                child: Icon(
                                  Iconsax.user,
                                  size: 60,
                                ),
                              )
                            : CircleAvatar(
                                radius: 80,
                                backgroundImage: NetworkImage(me!.image!),
                              )
                        : CircleAvatar(
                            radius: 80,
                            backgroundImage: FileImage(File(_image)),
                          ),
                    Positioned(
                        bottom: -5,
                        right: -5,
                        child: IconButton.filled(
                            onPressed: () async {
                              ImagePicker imagePicker = ImagePicker();
                              XFile? image = await imagePicker.pickImage(
                                  source: ImageSource.gallery);
                              if (image != null) {
                                setState(() {
                                  _image = image.path;
                                });
                                await FireStorage()
                                    .updateProfileImage(file: File(image.path))
                                    .then(
                                  (value) {
                                    print(
                                        '----------- Updated Done ----------');
                                  },
                                );
                              }
                            },
                            icon: const Icon(Iconsax.edit)))
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Iconsax.user_octagon),
                  trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          nameEdit = true;
                        });
                      },
                      icon: const Icon(Iconsax.edit)),
                  title: TextField(
                    controller: nameCon,
                    enabled: nameEdit,
                    decoration: const InputDecoration(
                      labelText: "Name",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Iconsax.information),
                  trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          aboutEdit = true;
                        });
                      },
                      icon: const Icon(Iconsax.edit)),
                  title: TextField(
                    controller: aboutCon,
                    enabled: aboutEdit,
                    maxLines: 4,
                    minLines: 1,
                    decoration: const InputDecoration(
                      labelText: "About",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                    leading: const Icon(Iconsax.direct),
                    title: const Text("Email"),
                    subtitle: Text(me!.email!)),
              ),
              Card(
                child: ListTile(
                    leading: Icon(Iconsax.timer_1),
                    title: const Text("Joined On"),
                    subtitle: Text('${myDateTime.dateAndTime(me!.createdAt!)} at ${myDateTime.onlyTime(me!.createdAt!)}')),
              ),
              const SizedBox(
                height: 20,
              ),
              CustomElevatedButton(
                  text: 'save',
                  onPressed: () {
                    if (nameCon.text.isNotEmpty && aboutCon.text.isNotEmpty) {
                      FireData()
                          .editProfile(
                              newName: nameCon.text, about: aboutCon.text)
                          .then(
                        (value) {
                          Provider.of<ProviderApp>(context, listen: false)
                              .getUserDetails();
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Profile updated")));
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LayoutApp(),
                            ),
                            (route) => false,
                          );
                        },
                      );
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
