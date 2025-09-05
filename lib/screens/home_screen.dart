import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'package:focuspal/models/player.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int) onNavigate;
  final Player player;

  const HomeScreen({super.key, required this.onNavigate, required this.player});

  @override
  Widget build(BuildContext context) {
    double progress = player.xp / player.getXpForNextLevel();

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Level, XP, Coins
            Text(
              'Level: ${player.level}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
            ),
            const SizedBox(height: 4),
            Text('${player.xp}/${player.getXpForNextLevel()} XP'),
            const SizedBox(height: 4),
            Text('Coins: ${player.coins}', style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 40),

            // Navigation buttons
            CustomButton(
              label: 'Start Focus Timer',
              onPressed: () => onNavigate(1),
            ),
            const SizedBox(height: 10),
            CustomButton(
              label: 'View Rewards',
              onPressed: () => onNavigate(2),
            ),
            const SizedBox(height: 10),
            CustomButton(
              label: 'Shop',
              onPressed: () => onNavigate(3),
            ),
            const SizedBox(height: 10),
            CustomButton(
              label: 'Collection',
              onPressed: () => onNavigate(4),
            ),
            const SizedBox(height: 10),
            CustomButton(
              label: 'View your pet',
              onPressed: () => onNavigate(5),
            ),
            const SizedBox(height: 10),
            CustomButton(
              label: 'Settings',
              onPressed: () => onNavigate(6),
            ),
          ],
        ),
      ),
    );
  }
}