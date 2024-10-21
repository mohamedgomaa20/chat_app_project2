import 'package:chat_app_project/utils/show_snack_bar.dart';
import 'package:chat_app_project/widgets/custom_elevated_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../utils/constants.dart';

import '../../widgets/logo_app.dart';
import '../../widgets/text_form_field.dart';

class ForgetScreen extends StatefulWidget {
  const ForgetScreen({super.key});

  @override
  State<ForgetScreen> createState() => _ForgetScreenState();
}

TextEditingController emailCon = TextEditingController();
final formKey = GlobalKey<FormState>();
bool isLoading = false;

class _ForgetScreenState extends State<ForgetScreen> {
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
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
                        resetPassword(email: emailCon.text);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future resetPassword({required email}) async {
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email).then(
        (value) {
          showSnackBar(
              context: context, message: "Email Sent! Check your email.");
          Navigator.pop(context);
        },
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showSnackBar(
            context: context, message: "No user found with this email.");
      } else if (e.code == 'invalid-email') {
        showSnackBar(
            context: context, message: "Invalid email address format.");
      }
    } catch (e) {
      showSnackBar(context: context, message: "An unexpected error occurred.");
    }
    setState(() {
      isLoading = false;
    });
  }
}
