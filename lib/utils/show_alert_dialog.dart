import 'package:flutter/material.dart';

showAlertDialog({
  context,
  required String content,
  required String txtYes,
  required VoidCallback onPressedYes,
  required String txtNo,
}) =>
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // backgroundColor: Theme.of(context).colorScheme.onPrimary,
          backgroundColor: const Color(0xff3B3C3E),
          titlePadding: const EdgeInsets.only(left: 20),
          actionsPadding: const EdgeInsets.only(
            bottom: 10,
            right: 10,
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: EdgeInsets.all(10),
          content: SizedBox(
            width: 450,
            child: Padding(
              padding: const EdgeInsets.only(top: 25, left: 20),
              child: Text(
                content,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                // style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    txtNo,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: onPressedYes,
                  child: Text(
                    txtYes,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
