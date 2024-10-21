import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewScreen extends StatefulWidget {
  const PhotoViewScreen({super.key, required this.image});

  final String image;

  @override
  State<PhotoViewScreen> createState() => _PhotoViewScreenState();
}

class _PhotoViewScreenState extends State<PhotoViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PhotoView(
        imageProvider: NetworkImage(widget.image),
        backgroundDecoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
    );
  }
}
