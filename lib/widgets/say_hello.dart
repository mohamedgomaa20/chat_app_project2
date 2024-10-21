import 'package:flutter/material.dart';


class SayAssalamuAlaikum extends StatelessWidget {
  const SayAssalamuAlaikum({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "👋",
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  "Say Assalamu Alaikum",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
