import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key, required this.imageProvider});

  final ImageProvider imageProvider;

  @override
  Widget build(BuildContext context) {
    return PhotoView(imageProvider: imageProvider);
  }
}
