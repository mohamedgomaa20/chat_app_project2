import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

import '../../layout.dart';
import '../../provider/provider.dart';
import '../../utils/colors.dart';
import '../../widgets/logo.dart';
import '../../widgets/text_field.dart';
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
    final formKey = GlobalKey<FormState>();
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // const LogoApp(),
                const Gap(50),
                Image.asset(
                  "assets/te2.png",
                  height: 150,
                  color: kPrimaryColor,
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Welcome Back",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                // Text(
                //   "Material Chat App With Mohamed Gomaa",
                //   style: Theme.of(context).textTheme.bodyLarge,
                // ),

                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      CustomField(
                        controller: emailCon,
                        lable: "Email",
                        icon: Iconsax.direct,
                      ),
                      CustomField(
                        controller: passCon,
                        lable: "Password",
                        icon: Iconsax.password_check,
                        isPass: true,
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
                                    builder: (context) => ForgetScreen(),
                                  ));
                            },
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            signIn(
                                email: emailCon.text, password: passCon.text);
                            // await FirebaseAuth.instance
                            //     .signInWithEmailAndPassword(
                            //         email: emailCon.text, password: passCon.text)
                            //     .then(
                            //   (value) {
                            //     print("---------- Login Done -------------");
                            //   },
                            // ).onError(
                            //   (error, stackTrace) {
                            //     ScaffoldMessenger.of(context).showSnackBar(
                            //       SnackBar(content: Text(error.toString())),
                            //     );
                            //   },
                            // );
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
                            "Login".toUpperCase(),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      // ElevatedButton(
                      //   onPressed: () async {
                      //     if (formKey.currentState!.validate()) {
                      //       // Sign out any currently logged-in user before creating a new one.
                      //       await FirebaseAuth.instance.signOut();
                      //
                      //       await FirebaseAuth.instance
                      //           .createUserWithEmailAndPassword(
                      //           email: emailCon.text, password: passCon.text)
                      //           .then((value) {
                      //         emailCon.clear();
                      //         passCon.clear();
                      //       }).onError(
                      //             (error, stackTrace) {
                      //           ScaffoldMessenger.of(context).showSnackBar(
                      //             SnackBar(content: Text(error.toString())),
                      //           );
                      //         },
                      //       );
                      //     }
                      //   },
                      //   style: ElevatedButton.styleFrom(
                      //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      //     backgroundColor: kPrimaryColor,
                      //     padding: const EdgeInsets.all(16),
                      //   ),
                      //   child: Center(
                      //     child: Text(
                      //       "Create Account".toUpperCase(),
                      //       style: const TextStyle(color: Colors.black),
                      //     ),
                      //   ),
                      // ),

                      OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.all(16),
                          ),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                      email: emailCon.text,
                                      password: passCon.text)
                                  .then((value) {
                                emailCon.clear();
                                passCon.clear();
                              }).onError(
                                (error, stackTrace) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error.toString())),
                                  );
                                },
                              );
                            }
                          },
                          child: Center(
                            child: Text(
                              "Create Account".toUpperCase(),
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                          )),
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
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LayoutApp()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No user found for that email.')));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Wrong password provided for that user.')));
      }
    } catch (e) {
      print("Failed to log in: $e");
    }
    setState(() {
      isLoading = false;
    });
  }

// Future<void> createAccount(String email, String password, String name) async {
//   try {
//     UserCredential userCredential =
//         await FirebaseAuth.instance.createUserWithEmailAndPassword(
//       email: email,
//       password: password,
//     );
//
//     await userCredential.user?.updateProfile(displayName: name);
//
//     Provider.of<ProviderApp>(context, listen: false)
//         .setUser(userCredential.user);
//
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => LayoutApp()),
//     );
//   } catch (e) {
//     print("Failed to create account: $e");
//   }
// }
}
