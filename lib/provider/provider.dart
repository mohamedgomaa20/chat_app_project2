import 'package:chat_app_project/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProviderApp with ChangeNotifier {
  ThemeMode themeMode = ThemeMode.dark;
  int mainColor = 0xffF44336;
  ChatUser? me;

  getUserDetails() async {
    String myId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(myId).get().then(
      (value) {
        me = ChatUser.fromJson(value.data()!);
      },
    );
    notifyListeners();
  }

  changeMode(bool dark) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    sharedPreferences.setBool('dark', themeMode == ThemeMode.dark);
    notifyListeners();
  }

  changeColor(int color) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    mainColor = color;
    sharedPreferences.setInt('color', mainColor);
    notifyListeners();
  }

  getValuesFromPref() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    bool isDark = sharedPreferences.getBool('dark') ?? false;
    themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    mainColor = sharedPreferences.getInt('color') ?? 0xffF44336;
    notifyListeners();
  }
}
