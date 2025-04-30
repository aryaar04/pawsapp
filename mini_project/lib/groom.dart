import 'package:flutter/material.dart';

class GroomPage extends StatelessWidget {
  const GroomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groom'),
        backgroundColor: const Color(0xFF95D2B3),
      ),
      body: const Center(
        child: Text(
          'Welcome to the Grooming Services!\nBook a grooming session for your pet.',
          style: TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
