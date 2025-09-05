import 'package:flutter/material.dart';
import 'package:focuspal/models/player.dart';
import 'package:focuspal/widgets/pet.dart';

// Map rewards to image asset paths and positions
const Map<String, Map<String, dynamic>> rewardImageMap = {
  "Cool Hat": {
    "image": "assets/images/hat.png",
    "left": 80.0,
    "top": 20.0,
    "width": 60.0,
    "height": 60.0,
  },
  "Golden Collar": {
    "image": "assets/images/collar.png",
    "left": 90.0,
    "top": 140.0,
    "width": 70.0,
    "height": 30.0,
  },
  "Magic Potion": {
    "image": "assets/images/potion.png",
    "left": 50.0,
    "top": 100.0,
    "width": 50.0,
    "height": 50.0,
  },
  "Rainbow Fur": {
    "image": "assets/images/rainbow.png",
    "left": 60.0,
    "top": 60.0,
    "width": 120.0,
    "height": 120.0,
  },
};

class PetScreen extends StatelessWidget {
  final Player player;

  const PetScreen({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    String petBase = 'assets/images/pet.png';

    // Get unlocked rewards with positions
    List<Map<String, dynamic>> accessories = player.unlockedRewards
        .map((reward) => rewardImageMap[reward])
        .where((data) => data != null)
        .cast<Map<String, dynamic>>()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Pet"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pet visualization with dynamic accessories
            AnimatedPet(
              petImagePath: petBase,
              accessories: accessories,
            ),
            const SizedBox(height: 20),
            Text(
              "Level: ${player.level}  |  Coins: ${player.coins}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}