import 'package:chat_app_project/firebase/fire_auth.dart';

import 'package:chat_app_project/provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:iconsax/iconsax.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

import '../../utils/constants.dart';
import '../../utils/show_alert_dialog.dart';
import '../../utils/show_qr_code.dart';
import '../../utils/show_snack_bar.dart';

import '../auth/login_screen.dart';
import '../settings/my_profile.dart';

class SettingHomeScreen extends StatefulWidget {
  const SettingHomeScreen({super.key});

  @override
  State<SettingHomeScreen> createState() => _SettingHomeScreenState();
}

class _SettingHomeScreenState extends State<SettingHomeScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderApp>(context, listen: false);
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(kPadding),
          child: SingleChildScrollView(
            child: Column(children: [
              ListTile(
                minVerticalPadding: 30,
                leading: provider.me!.image == ""
                    ? const CircleAvatar(
                        radius: 30,
                        child: Icon(
                          Iconsax.user,
                          size: 30,
                        ),
                      )
                    : CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(provider.me!.image!),
                      ),
                title: Text(provider.me!.name!),
                subtitle: Text(provider.me!.email!),
                trailing: ShowQRCode(data: provider.me!.email!),
              ),
              Card(
                child: ListTile(
                  title: const Text("Profile"),
                  leading: const Icon(Iconsax.user),
                  trailing: const Icon(Iconsax.arrow_right_3),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      )),
                ),
              ),
              Card(
                child: ListTile(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: SingleChildScrollView(
                            child: BlockPicker(
                              pickerColor: Color(provider.mainColor),
                              onColorChanged: (value) {
                                print(value.toHexString());
                                provider.changeColor(value.value);
                              },
                            ),
                          ),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Done"))
                          ],
                        );
                      },
                    );
                  },
                  title: const Text("Theme"),
                  leading: const Icon(Iconsax.color_swatch),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text("Dark Mode"),

                  leading: Icon(provider.themeMode == ThemeMode.dark
                      ? Icons.nights_stay
                      : Icons.wb_sunny),
                  // leading: Icon(Icons.brightness_6),

                  trailing: Switch(
                    value: provider.themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      setState(() {
                        provider.changeMode(value);
                      });
                    },
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  onTap: () {
                    showAlertDialog(
                      context: context,
                      content: "Are you sure you want to log out?",
                      txtNo: "CANCEL",
                      txtYes: "LOG OUT",
                      onPressedYes: () async {
                        Navigator.pop(context);
                        setState(() {
                          isLoading = true;
                        });
                        setState(() {
                          FireAuth().updateActivate(online: false);
                        });
                        await FirebaseAuth.instance.signOut().then((value) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                          showSnackBar(
                              context: context,
                              message: "Logged out successfully!");
                        }).onError(
                          (error, stackTrace) {
                            showSnackBar(
                                context: context,
                                message:
                                    "An error occurred while logging out.");
                          },
                        );
                        setState(() {
                          isLoading = true;
                        });
                      },
                    );
                  },
                  title: const Text("Log Out"),
                  trailing: const Icon(Iconsax.logout_1),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
