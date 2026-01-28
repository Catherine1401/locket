import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: const Locket()));
}

class Locket extends StatelessWidget {
  const Locket({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text("hello wolrd"),
        ),
      ),
    );
  }
}