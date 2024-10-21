import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TextFieldForMessage extends StatefulWidget {
  const TextFieldForMessage({
    super.key,
    required this.onPressed,
    required this.onPressedCamera,
    required this.onPressedGallery,
    required this.controller,
    this.isEditing = false,
  });

  final VoidCallback onPressed;
  final VoidCallback onPressedCamera;
  final VoidCallback onPressedGallery;
  final TextEditingController controller;
  final bool isEditing;

  @override
  State<TextFieldForMessage> createState() => _TextFieldForMessageState();
}

class _TextFieldForMessageState extends State<TextFieldForMessage> {
  bool isArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_checkText);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_checkText);
    super.dispose();
  }

  void _checkText() {
    setState(() {
      _hasText = widget.controller.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: TextField(
              controller: widget.controller,
              autofocus: widget.isEditing,
              maxLines: 5,
              minLines: 1,
              decoration: InputDecoration(
                suffixIcon: _hasText
                    ? null
                    : Row(
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
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              textDirection: isArabic(widget.controller.text)
                  ? TextDirection.rtl
                  : TextDirection.ltr,
            ),
          ),
        ),
        IconButton.filled(
          onPressed: widget.onPressed,
          icon: const Icon(Iconsax.send_1),
        ),
      ],
    );
  }
}
