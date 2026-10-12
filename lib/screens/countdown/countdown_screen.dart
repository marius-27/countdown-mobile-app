import 'package:flutter/material.dart';

import '../../models/countdown_event.dart';

class CountdownScreen extends StatelessWidget {
  const CountdownScreen({super.key, required this.event});

  final CountdownEvent event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: const SizedBox.shrink(),
    );
  }
}
