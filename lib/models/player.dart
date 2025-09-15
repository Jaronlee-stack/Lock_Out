import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Player {
  int xp = 0;
  int level = 1;
  int coins = 0;
  List<String> unlockedRewards = [];
  DateTime? lastSession; // <-- New field

  final Map<int, String> levelRewards = {
    1: 'Starter Pet',
    5: 'Accessories',
    10: 'More Shop Items',
    15: 'Accessories',
  };

  Player();

  /// Load Player from SharedPreferences
  static Future<Player> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final player = Player();
      player.level = prefs.getInt('level') ?? 1;
      player.xp = prefs.getInt('xp') ?? 0;
      player.coins = prefs.getInt('coins') ?? 0;
      player.unlockedRewards = prefs.getStringList('unlockedRewards') ?? [];

      final lastSessionStr = prefs.getString('lastSession');
      if (lastSessionStr != null) {
        player.lastSession = DateTime.tryParse(lastSessionStr);
      }

      return player;
    } catch (e, stack) {
      debugPrint("Player.load() failed: $e\n$stack");
      return Player();
    }
  }

  /// Get XP needed for next level
  int getXpForNextLevel() {
    if (level < 5) return 50;
    if (level < 10) return 100;
    if (level < 15) return 125;
    return 150; // level 15+
  }

  /// Add XP and coins (optional), return new rewards if level up
  Future<List<String>> addXp(int amount, {int coinsEarned = 0}) async {
    xp += amount;
    coins += coinsEarned;
    List<String> newRewards = [];

    while (xp >= getXpForNextLevel()) {
      xp -= getXpForNextLevel();
      level++;

      String? reward;
      if (levelRewards.containsKey(level)) {
        reward = levelRewards[level];
      } else if (level <= 20) {
        reward = 'Pet Upgrade Level $level';
      }

      if (reward != null) {
        newRewards.add(reward);
        unlockedRewards.add(reward);
      }
    }

    await save();
    return newRewards;
  }

  /// Spend coins
  bool spendCoins(int amount) {
    if (coins >= amount) {
      coins -= amount;
      save();
      return true;
    }
    return false;
  }

  /// XP progress
  double getXpProgress() => xp / getXpForNextLevel();

  /// Save all player data
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('level', level);
    await prefs.setInt('xp', xp);
    await prefs.setInt('coins', coins);
    await prefs.setStringList('unlockedRewards', unlockedRewards);
    await prefs.setString('lastSession', DateTime.now().toIso8601String()); // <-- Save timestamp
  }

  bool isDailyBonusEligible() {
    if (lastSession == null) return true;
    final now = DateTime.now();
    return now.difference(lastSession!).inHours >= 24;
  }
}
