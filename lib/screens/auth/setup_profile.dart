import 'package:chat_app_project/firebase/fire_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../utils/colors.dart';
import '../../widgets/text_field.dart';

class SetupProfile extends StatefulWidget {
  const SetupProfile({super.key});

  @override
  State<SetupProfile> createState() => _SetupProfileState();
}

final formKey = GlobalKey<FormState>();

class _SetupProfileState extends State<SetupProfile> {
  TextEditingController nameCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              icon: Icon(Iconsax.logout_1))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Welcome,",
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                Text(
                  "Chat App With Mohamed Gomaa",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  "Please Enter Your Name",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                CustomField(
                  controller: nameCon,
                  lable: "Name",
                  icon: Iconsax.user,
                ),
                const SizedBox(
                  height: 16,
                ),
                // ElevatedButton(
                //   onPressed: () async {
                //     if (formKey.currentState!.validate()) {
                //       // Check if a new user is signed in before updating their display name.
                //       if (FirebaseAuth.instance.currentUser != null) {
                //         await FirebaseAuth.instance.currentUser!
                //             .updateDisplayName(nameCon.text)
                //             .then(
                //           (value) {
                //             FireAuth.createUser();
                //             nameCon.clear();
                //           },
                //         );
                //       }
                //     }
                //   },
                //   style: ElevatedButton.styleFrom(
                //     shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(12)),
                //     backgroundColor: kPrimaryColor,
                //     padding: const EdgeInsets.all(16),
                //   ),
                //   child: Center(
                //     child: Text(
                //       "Continue".toUpperCase(),
                //       style: const TextStyle(color: Colors.black),
                //     ),
                //   ),
                // ),

                ElevatedButton(
                  onPressed: () async {
                    // if (nameCon.text.isNotEmpty) {
                    if (formKey.currentState!.validate()) {
                      await FirebaseAuth.instance.currentUser!
                          .updateDisplayName(nameCon.text)
                          .then(
                        (value) {
                          FireAuth.createUser();
                          nameCon.clear();
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    backgroundColor: kPrimaryColor,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: Center(
                    child: Text(
                      "Continue".toUpperCase(),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
