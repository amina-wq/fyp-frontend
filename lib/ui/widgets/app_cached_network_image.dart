// Programmer Name: Rakhmatullayeva Amina
// Program Name: FoodTrack
// Description: Cached network image widget with a fallback icon.
// First Written on: Monday, 22-Jun-2026
// Edited on: Sunday, 12-Jul-2026
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppCachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget fallback;
  final double? width;
  final double? height;

  const AppCachedNetworkImage({
    super.key,
    required this.imageUrl,
    required this.fallback,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 180),
      fadeOutDuration: const Duration(milliseconds: 80),
      placeholder: (context, url) {
        return fallback;
      },
      errorWidget: (context, url, error) {
        return fallback;
      },
    );
  }
}
