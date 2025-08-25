import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FocusPal - Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              label: 'Start Focus Timer',
              onPressed: () => Navigator.pushNamed(context, '/timer'),
            ),
            const SizedBox(height: 10),
            CustomButton(
              label: 'View Rewards',
              onPressed: () => Navigator.pushNamed(context, '/rewards'),
            ),
            const SizedBox(height: 10),
            CustomButton(
              label: 'Settings',
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
      ),
    );
  }
}