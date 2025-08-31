import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Player {
  int xp = 0;
  int level = 1;
  List<String> unlockedRewards = [];

  final Map<int, String> rewards = {
    1: 'Starter Pet',
    5: 'Accessories',
    10: 'Upgrade Pet',
    15: 'Accessories',
  };

  Player();

  /// Initialize Player from saved data
  static Future<Player> load() async {
    try {
    final prefs = await SharedPreferences.getInstance();
    final player = Player();
    player.level = prefs.getInt('level') ?? 1;
    player.xp = prefs.getInt('xp') ?? 0;
    player.unlockedRewards = prefs.getStringList('unlockedRewards') ?? [];
    return player;
  } catch (e, stack) {
    debugPrint("⚠️ Player.load() failed: $e\n$stack");
    return Player(); // fallback, so app still runs
  }
}

  int getXpForNextLevel() {
    if (level < 5) return 50;
    if (level < 10) return 100;
    if (level < 15) return 125;
    return 150; // level 15+
  }

  /// Adds XP, returns reward if level-up unlocks one
  Future<List<String>> addXp(int amount) async {
  xp += amount;
  List<String> newRewards = [];

  while (xp >= getXpForNextLevel()) {
    xp -= getXpForNextLevel();
    level++;
    
    String? reward;
    if (rewards.containsKey(level)) {
      reward = rewards[level];
    } else if (level <= 20) {
      reward = 'Pet Accessory Level $level';
    }

    if (reward != null) {
      newRewards.add(reward);
      unlockedRewards.add(reward); // store it persistently
    }
  }
  await save();
  return newRewards;
}

  double getXpProgress() => xp / getXpForNextLevel();

  /// Save player data to SharedPreferences
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('level', level);
    await prefs.setInt('xp', xp);
    await prefs.setStringList('unlockedRewards', unlockedRewards);
  }
}