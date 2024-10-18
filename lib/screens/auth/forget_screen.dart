import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

import '../../utils/colors.dart';
import '../../widgets/logo.dart';
import '../../widgets/text_field.dart';

class ForgetScreen extends StatefulWidget {
  const ForgetScreen({super.key});

  @override
  State<ForgetScreen> createState() => _ForgetScreenState();
}

final formKey = GlobalKey<FormState>();
TextEditingController emailCon = TextEditingController();

class _ForgetScreenState extends State<ForgetScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const LogoApp(),
                Gap(50),
                Image.asset(
                  "assets/te2.png",
                  height: 150,
                  color: kPrimaryColor,
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Reset Password,",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  "Please Enter Your Email",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                CustomField(
                  controller: emailCon,
                  lable: "Email",
                  icon: Iconsax.direct,
                ),
                const SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await FirebaseAuth.instance
                          .sendPasswordResetEmail(email: emailCon.text)
                          .then(
                        (value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("Email Sent Check You Email.")),
                          );
                          Navigator.pop(context);
                        },
                      ).onError(
                        (error, stackTrace) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.toString())),
                          );
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
                      "Send Email".toUpperCase(),
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
