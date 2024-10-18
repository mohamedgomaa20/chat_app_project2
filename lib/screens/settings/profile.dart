import 'dart:io';

import 'package:chat_app_project/firebase/fire_database.dart';
import 'package:chat_app_project/firebase/fire_storage.dart';
import 'package:chat_app_project/layout.dart';
import 'package:chat_app_project/models/user_model.dart';
import 'package:chat_app_project/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

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
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _image == ''
                        ? me!.image == ""
                            ? const CircleAvatar(
                                radius: 80,
                      child: Icon(Iconsax.user,size: 60,),
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
              SizedBox(
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
                      icon: Icon(Iconsax.edit)),
                  title: TextField(
                    controller: nameCon,
                    enabled: nameEdit,
                    decoration: InputDecoration(
                      labelText: "Name",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Iconsax.information),
                  trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          aboutEdit = true;
                        });
                      },
                      icon: Icon(Iconsax.edit)),
                  title: TextField(
                    controller: aboutCon,
                    enabled: aboutEdit,
                    maxLines: 4,
                    minLines: 1,
                    decoration: InputDecoration(
                      labelText: "About",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                    leading: Icon(Iconsax.direct),
                    title: Text("Email"),
                    subtitle: Text(me!.email!)),
              ),
              Card(
                child: ListTile(
                    leading: Icon(Iconsax.timer_1),
                    title: Text("Joined On"),
                    subtitle: Text(me!.createdAt!)),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
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
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  padding: const EdgeInsets.all(16),
                ),
                child: Center(
                  child: Text(
                    "Save".toUpperCase(),
                    // style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
