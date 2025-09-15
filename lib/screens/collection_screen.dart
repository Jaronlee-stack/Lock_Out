import 'package:flutter/material.dart';
import 'package:focuspal/models/player.dart';
import 'package:focuspal/widgets/background.dart';

class CollectionScreen extends StatelessWidget {
  final Player player;

  const CollectionScreen({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    const shopItemImages = {
      'Cool Hat': 'assets/images/hat.png',
      'Black Tie': 'assets/images/collar.png',
      'Magic Potion': 'assets/images/potion.png',
      'Rainbow Fur': 'assets/images/rainbow.png',
    };

    final allItems = player.unlockedRewards.map((itemName) {
      return {
        'name': itemName,
        'icon': shopItemImages[itemName] ?? 'assets/images/reward.png',
      };
    }).toList();

    return BackgroundWrapper(
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.9,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: allItems.length,
        itemBuilder: (context, index) {
          final item = allItems[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(item['icon'] as String, width: 60, height: 60),
                const SizedBox(height: 10),
                Text(item['name'] as String, textAlign: TextAlign.center),
              ],
            ),
          );
        },
      ),
    );
  }
}
