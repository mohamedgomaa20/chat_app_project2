import 'package:chat_app_project/widgets/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../firebase/fire_auth.dart';
import '../../layout.dart';

import '../../utils/constants.dart';

import '../../widgets/custom_elevated_button.dart';
import '../../widgets/logo_app.dart';

import 'forget_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

final formKey = GlobalKey<FormState>();

class _RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController emailCon = TextEditingController();
  TextEditingController passCon = TextEditingController();
  TextEditingController displayName = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(kPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // const LogoApp(),
                const Gap(50),
                const LogoApp(),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Create a new account to",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      "start your journey with us!",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      CustomTextFormField(
                        controller: emailCon,
                        label: "Email",
                        prefixIcon: Iconsax.direct,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      CustomTextFormField(
                        controller: displayName,
                        label: "Display Name",
                        prefixIcon: Iconsax.user,
                      ),
                      CustomTextFormField(
                        controller: passCon,
                        label: "Password",
                        prefixIcon: Iconsax.password_check,
                        isPassword: true,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        children: [
                          const Spacer(),
                          GestureDetector(
                            child: const Text("Forget Password?"),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ForgetScreen(),
                                  ));
                            },
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      CustomElevatedButton(
                        text: 'Register',
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            register(
                                    email: emailCon.text,
                                    password: passCon.text)
                                .then(
                              (value) {
                                setState(() {
                                  FireAuth().updateActivate(online: true);
                                });
                              },
                            );
                          }
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have account ?"),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Login Now!'))
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future register({required String email, required String password}) async {
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then(
        (value) {
          FirebaseAuth.instance.currentUser!
              .updateDisplayName(displayName.text)
              .then(
            (value) {
              FireAuth.createUser();
              emailCon.clear();
              displayName.clear();
              passCon.clear();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LayoutApp()),
                (route) => false,
              );
            },
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('The password provided is too weak.')));
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('The account already exists for that email.')));
      } else if (e.code == 'network-request-failed') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Network error: Please check your internet connection and try again.')));
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Invalid email: Please enter a valid email address.')));
      } else if (e.code == 'too-many-requests') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Too many requests: Please try again later.')));
      }
    } catch (e) {
      print("Failed to log in: $e");
    }
    setState(() {
      isLoading = false;
    });
  }
}
