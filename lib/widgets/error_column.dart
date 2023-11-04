
import 'package:flutter/material.dart';

class ErrorColumn extends StatelessWidget {
  final Object error;

  const ErrorColumn({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.error),
          const SizedBox(
            height: 25,
          ),
          Text(error.toString(), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
