import 'package:chat_app_project/firebase/fire_auth.dart';
import 'package:chat_app_project/provider/provider.dart';
import 'package:chat_app_project/screens/home/chat_home_screen.dart';
import 'package:chat_app_project/screens/home/contact_home_screen.dart';
import 'package:chat_app_project/screens/home/group_home_screen.dart';
import 'package:chat_app_project/screens/home/setting_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class LayoutApp extends StatefulWidget {
  const LayoutApp({super.key});

  @override
  State<LayoutApp> createState() => _LayoutAppState();
}

class _LayoutAppState extends State<LayoutApp> {
  int currentIndex = 0;
  PageController pageController = PageController();

  @override
  void initState() {
    Provider.of<ProviderApp>(context, listen: false).getValuesFromPref();
    Provider.of<ProviderApp>(context, listen: false).getUserDetails();
    SystemChannels.lifecycle.setMessageHandler(
      (message) {
        if (message == 'AppLifecycleState.resumed') {
          FireAuth().updateActivate(online: true);
        } else if (message == 'AppLifecycleState.inactive' ||
            message == 'AppLifecycleState.paused' ||
            message == 'AppLifecycleState.detached') {
          FireAuth().updateActivate(online: false);
        }
        print(message);
        return Future.value(message);
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        onPageChanged: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        controller: pageController,
        children: const [
          ChatHomeScreen(),
          GroupHomeScreen(),
          ContactHomeScreen(),
          SettingHomeScreen()
        ],
      ),
      bottomNavigationBar: NavigationBar(
        elevation: 0,
        selectedIndex: currentIndex,
        onDestinationSelected: (value) {
          setState(() {
            currentIndex = value;
            pageController.jumpToPage(value);
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Iconsax.message), label: "Chats"),
          NavigationDestination(icon: Icon(Iconsax.messages), label: "Groups"),
          NavigationDestination(icon: Icon(Iconsax.user), label: "Contacts"),
          NavigationDestination(icon: Icon(Iconsax.setting), label: "Settings"),
        ],
      ),
    );
  }
}
