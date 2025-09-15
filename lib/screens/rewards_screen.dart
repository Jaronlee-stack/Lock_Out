import 'package:flutter/material.dart';
import 'package:focuspal/models/player.dart';
import 'package:focuspal/widgets/background.dart';

class Reward {
  final String name;
  final int points; // XP required to unlock
  final int requiredLevel;
  final bool isAccessory;

  Reward({
    required this.name,
    required this.points,
    required this.requiredLevel,
    this.isAccessory = false,
  });
}

class RewardsScreen extends StatelessWidget {
  final Player player;

  const RewardsScreen({super.key, required this.player});

  List<Reward> _generateRewards() {
    List<Reward> rewardsList = [];

    final baseRewards = {
      1: 'Starter Pet',
      5: 'Accessory Pack',
      10: 'More Shop Items',
      15: 'Accessory Pack',
    };

    for (int level = 1; level <= 20; level++) {
      String name;
      if (baseRewards.containsKey(level)) {
        name = baseRewards[level]!;
      } else {
        name = 'Pet Upgrade Level $level';
      }

      // Calculate points: total XP required to reach this level
      int points = 0;
      Player tempPlayer = Player();
      for (int l = 1; l < level; l++) {
        points += tempPlayer.getXpForNextLevel();
        tempPlayer.level++;
      }

      rewardsList.add(Reward(
        name: name,
        points: points,
        requiredLevel: level,
        isAccessory: !baseRewards.containsKey(level),
      ));
    }

    return rewardsList;
  }

  @override
  Widget build(BuildContext context) {
    final allRewards = _generateRewards();

    return BackgroundWrapper(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Level: ${player.level} | XP: ${player.xp}/${player.getXpForNextLevel()}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: allRewards.length,
              itemBuilder: (context, index) {
                final reward = allRewards[index];
                final unlocked = player.level >= reward.requiredLevel;

                return ListTile(
                  title: Text(
                    reward.name,
                    style: TextStyle(
                      color: unlocked ? Colors.black : Colors.grey,
                      fontWeight: unlocked ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    "Level ${reward.requiredLevel} | ${reward.points} XP",
                    style: TextStyle(color: unlocked ? Colors.black : Colors.grey),
                  ),
                  leading: Icon(
                    reward.isAccessory ? Icons.pets : Icons.card_giftcard,
                    color: unlocked ? Colors.blue : Colors.grey,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
