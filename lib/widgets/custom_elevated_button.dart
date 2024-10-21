import 'package:flutter/material.dart';

import '../utils/colors.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,

  });

  final String text;
  final VoidCallback? onPressed;


  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer),
      child: Center(
        child: Text(
          text.toUpperCase(),
        ),
      ),
    );
  }
}
