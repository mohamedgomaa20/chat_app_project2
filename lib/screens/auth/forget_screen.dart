import 'package:chat_app_project/utils/show_snack_bar.dart';
import 'package:chat_app_project/widgets/custom_elevated_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

import '../../utils/constants.dart';

import '../../widgets/logo_app.dart';
import '../../widgets/text_form_field.dart';

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
          padding: const EdgeInsets.all(kPadding),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(50),
                const LogoApp(),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Reset Password",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  "Please Enter Your Email",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                CustomTextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailCon,
                  label: "Email",
                  prefixIcon: Iconsax.direct,
                ),
                const Gap(16),
                CustomElevatedButton(
                    text: "Send Email",
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        await FirebaseAuth.instance
                            .sendPasswordResetEmail(email: emailCon.text)
                            .then(
                          (value) {
                            showSnackBar(
                                context: context,
                                message: "Email Sent Check You Email.");

                            Navigator.pop(context);
                          },
                        ).onError(
                          (error, stackTrace) {
                            showSnackBar(
                                context: context, message: error.toString());
                          },
                        );
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
