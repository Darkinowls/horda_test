import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';

import '../core/exceptions.dart';
import 'error_column.dart';
import 'horda_network_image.dart';

class ImagePlaceholder extends StatelessWidget {
  final Either<HordaException, String> result;

  const ImagePlaceholder({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return switch (result) {
      Left() => ErrorColumn(error: result.left),
      Right() => HordaNetworkImage(url: result.right),
    };
  }
}
