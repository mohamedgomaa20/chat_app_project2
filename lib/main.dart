import 'package:chat_app_project/provider/provider.dart';
import 'package:chat_app_project/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDark = prefs.getBool('dark') ?? false;
  int color = prefs.getInt('color') ?? 0xffF44336;

  runApp(MyApp(isDark: isDark, mainColor: color));
}

class MyApp extends StatelessWidget {
  final bool isDark;
  final int mainColor;

  const MyApp({super.key, required this.isDark, required this.mainColor});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProviderApp()
        ..themeMode = isDark ? ThemeMode.dark : ThemeMode.light
        ..mainColor = mainColor,
      child: Consumer<ProviderApp>(
        builder: (context, providerApp, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: providerApp.themeMode,
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: Color(providerApp.mainColor),
                brightness: Brightness.dark),
          ),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: Color(providerApp.mainColor),
                brightness: Brightness.light),
            useMaterial3: true,
          ),
          home: StreamBuilder(
            stream: FirebaseAuth.instance.userChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return const LayoutApp();
              } else {
                return const LoginScreen();
              }
            },
          ),
        ),
      ),
    );
  }
}
