import 'package:chat_app_project/provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../auth/login_screen.dart';
import '../settings/profile.dart';
import '../settings/qr_code.dart';

class SettingHomeScreen extends StatefulWidget {
  const SettingHomeScreen({super.key});

  @override
  State<SettingHomeScreen> createState() => _SettingHomeScreenState();
}

class _SettingHomeScreenState extends State<SettingHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderApp>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        FirebaseMessaging.instance.requestPermission();
        FirebaseMessaging.instance.getToken().then((value) {
          print(value);

        },);

      }

      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(children: [
            ListTile(
              minVerticalPadding: 30,
              leading: provider.me!.image == ""
                  ? CircleAvatar(
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
              title: Text(provider.me!.name.toString()),
              subtitle: Text(provider.me!.email.toString()),
              trailing: IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QrCodeScreen(),
                        ));
                  },
                  icon: Icon(Iconsax.scan_barcode)),
            ),
            Card(
              child: ListTile(
                title: const Text("Profile"),
                leading: Icon(Iconsax.user),
                trailing: Icon(Iconsax.arrow_right_3),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(),
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
                              child: Text("Done"))
                        ],
                      );
                    },
                  );
                },
                title: Text("Theme"),
                leading: Icon(Iconsax.color_swatch),
              ),
            ),
            Card(
              child: ListTile(
                title: Text("Dark Mode"),
                leading: Icon(Iconsax.user),
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
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        actionsAlignment: MainAxisAlignment.center,
                        title: Center(
                          child: Text(
                            "Are You Sure ?",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        titlePadding: EdgeInsets.all(30),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              // await FirebaseAuth.instance.signOut().then(
                              //   (value) {
                              //     Navigator.pop(context);
                              //     ScaffoldMessenger.of(context).showSnackBar(
                              //       SnackBar(content: Text("Sign out Done")),
                              //     );
                              //   },
                              // ).onError(
                              //   (error, stackTrace) {
                              //     ScaffoldMessenger.of(context).showSnackBar(
                              //       SnackBar(content: Text("Sign out Done")),
                              //     );
                              //   },
                              // );

                              await FirebaseAuth.instance
                                  .signOut()
                                  .then((value) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginScreen()),
                                  (route) => false,
                                );
                              });
                            },
                            child: Text("Yes"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("No"),
                          ),
                        ],
                      );
                    },
                  );
                },
                title: Text("Signout"),
                trailing: Icon(Iconsax.logout_1),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
