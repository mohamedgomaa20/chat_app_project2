import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final String imageUrl;
  final bool online;
  final double radius;

  const UserAvatar({
    super.key,
    this.radius = 30,
    required this.name,
    required this.imageUrl,
    required this.online,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: radius,
      backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
      child: imageUrl.isEmpty ? Text(name.characters.first) : null,
    );

    return online
        ? Stack(
            clipBehavior: Clip.none,
            children: [
              avatar,
              Positioned(
                right: radius == 30 ? 1 : 0,
                bottom: radius == 30 ? 4 : 2,
                child: CircleAvatar(
                  radius: radius == 30 ? 7 : 6,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: radius == 30 ? 6 : 5,
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
            ],
          )
        : avatar;
  }
}
