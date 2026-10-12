import 'package:flutter/material.dart';

class CountdownScreen extends StatelessWidget {
  const CountdownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countdown')),
      body: const SizedBox.shrink(),
    );
  }
}
