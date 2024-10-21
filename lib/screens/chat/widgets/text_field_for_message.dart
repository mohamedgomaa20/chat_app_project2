import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../models/user_model.dart';

class TextFieldForMessage extends StatefulWidget {
  const TextFieldForMessage({
    super.key,

    required this.onPressed,
    required this.onPressedCamera,
    required this.onPressedGallery,
    required this.controller,
  });


  final VoidCallback onPressed;
  final VoidCallback onPressedCamera;
  final VoidCallback onPressedGallery;
  final TextEditingController controller;

  @override
  State<TextFieldForMessage> createState() => _TextFieldForMessageState();
}

class _TextFieldForMessageState extends State<TextFieldForMessage> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: TextField(
              controller: widget.controller,
              maxLines: 5,
              minLines: 1,
              decoration: InputDecoration(
                  suffixIcon: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: widget.onPressedGallery,
                        icon: const Icon(Iconsax.emoji_happy),
                      ),
                      IconButton(
                        onPressed: widget.onPressedCamera,
                        icon: const Icon(Iconsax.camera),
                      ),
                    ],
                  ),
                  border: InputBorder.none,
                  hintText: "Message",
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
            ),
          ),
        ),
        IconButton.filled(
            onPressed: widget.onPressed, icon: const Icon(Iconsax.send_1))
      ],
    );
  }
}
