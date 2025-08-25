import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../models/reward.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rewards = [
      Reward(name: '5-min Break', points: 50),
      Reward(name: 'Watch YouTube', points: 100),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('FocusPal - Rewards')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: rewards.length,
              itemBuilder: (context, index) {
                final reward = rewards[index];
                return ListTile(
                  title: Text(reward.name),
                  subtitle: Text('${reward.points} points'),
                );
              },
            ),
          ),
          CustomButton(
            label: 'Back to Home',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
