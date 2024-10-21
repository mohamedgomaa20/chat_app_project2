import 'package:chat_app_project/firebase/fire_auth.dart';
import 'package:chat_app_project/screens/auth/registration.dart';
import 'package:chat_app_project/widgets/custom_elevated_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../layout.dart';

import '../../utils/constants.dart';

import '../../utils/show_snack_bar.dart';
import '../../widgets/logo_app.dart';
import '../../widgets/text_form_field.dart';
import 'forget_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

final formKey = GlobalKey<FormState>();

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailCon = TextEditingController();
  TextEditingController passCon = TextEditingController();
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(50),
                const LogoApp(),
                const Gap(30),
                Text(
                  "Welcome back!",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  "Please login to your account to continue.",
                  style: Theme.of(context).textTheme.titleMedium,
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
                        text: 'Login',
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            signIn(email: emailCon.text, password: passCon.text)
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
                          const Text("don't have an account ?"),
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegistrationScreen(),
                                    ));
                              },
                              child: const Text('Register Now!'))
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

  Future signIn({required String email, required String password}) async {
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then(
        (value) {
          emailCon.clear();
          passCon.clear();
        },
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LayoutApp()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showSnackBar(
            context: context, message: 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showSnackBar(
            context: context,
            message: 'Wrong password provided for that user.');
      } else if (e.code == 'invalid-email') {
        showSnackBar(
            context: context,
            message: 'Invalid email: Please enter a valid email address.');
      } else if (e.code == 'user-disabled') {
        showSnackBar(
            context: context, message: 'This user account has been disabled.');
      } else if (e.code == 'too-many-requests') {
        showSnackBar(
            context: context,
            message: 'Too many login attempts. Please try again later.');
      } else if (e.code == 'network-request-failed') {
        showSnackBar(
            context: context,
            message:
                'Network error: Please check your connection and try again.');
      }
    } catch (e) {
      print("Failed to log in: $e");
    }
    setState(() {
      isLoading = false;
    });
  }
}
