
import 'package:flutter/material.dart';

class ErrorColumn extends StatelessWidget {
  final Object error;

  const ErrorColumn({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.error),
        const SizedBox(
          height: 25,
        ),
        Text(error.toString(), textAlign: TextAlign.center),
      ],
    );
  }
}
