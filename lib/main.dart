import 'package:chat_app_project/layout.dart';
import 'package:chat_app_project/provider/provider.dart';
import 'package:chat_app_project/screens/auth/login_screen.dart';
import 'package:chat_app_project/screens/auth/setup_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProviderApp(),
      child: Consumer<ProviderApp>(
        builder: (context, providerApp, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: providerApp.themeMode,
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: Color(providerApp.mainColor), brightness: Brightness.dark),
          ),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor:  Color(providerApp.mainColor), brightness: Brightness.light),
            useMaterial3: true,
          ),
          home: StreamBuilder(
            stream: FirebaseAuth.instance.userChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (FirebaseAuth.instance.currentUser!.displayName == "" ||
                    FirebaseAuth.instance.currentUser!.displayName == null) {
                  return SetupProfile();
                } else {
                  return LayoutApp();
                }
              } else {
                return LoginScreen();
              }
            },
          ),
        ),
      ),
    );
  }
}
