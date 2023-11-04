import 'package:flutter/material.dart';
import 'package:horda_test/widgets/error_column.dart';

class HordaNetworkImage extends StatelessWidget {
  final String url;

  const HordaNetworkImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      loadingBuilder: buildLoadingImage,
      errorBuilder: (_, __, ___) =>
          const ErrorColumn(error: "Failed to load image"),
    );
  }

  Widget buildLoadingImage(_, Widget child, ImageChunkEvent? progress) {
    if (progress == null) return child;
    return CircularProgressIndicator(
      value: progress.expectedTotalBytes != null
          ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
          : null,
    );
  }
}
