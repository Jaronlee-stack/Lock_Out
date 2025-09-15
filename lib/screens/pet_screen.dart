import 'package:flutter/material.dart';
import 'package:focuspal/models/player.dart';
import 'package:focuspal/widgets/pet.dart';
import 'package:focuspal/widgets/background.dart';

const Map<String, Map<String, dynamic>> rewardImageMap = {
  "Cool Hat": {
    "image": "assets/images/hat.png",
    "left": 80.0,
    "top": 20.0,
    "width": 60.0,
    "height": 60.0,
  },
  "Black Tie": {
    "image": "assets/images/collar.png",
    "left": 85.0,
    "top": 165.0,
    "width": 50.0,
    "height": 50.0,
  },
  "Magic Potion": {
    "image": "assets/images/potion.png",
    "left": 150.0,
    "top": 50.0,
    "width": 100.0,
    "height": 100.0,
  },
};

class PetScreen extends StatefulWidget {
  final Player player;

  const PetScreen({super.key, required this.player});

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<Offset> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _bounceAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.1),
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    _bounceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _bounceController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  double getPetScale(int level) {
    return (1.0 + level * 0.05).clamp(1.0, 2.0);
  }

  void _bouncePet() {
    _bounceController.forward(from: 0.0);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text("Your pet bounced happily!"), duration: Duration(seconds: 1)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final petBase = 'assets/images/pet.png';
    final hasRainbowAura = widget.player.unlockedRewards.contains("Rainbow Fur");

    final accessories = widget.player.unlockedRewards
        .where((reward) => rewardImageMap.containsKey(reward))
        .map((reward) => rewardImageMap[reward]!)
        .toList();

    final baseScale = getPetScale(widget.player.level);

    return BackgroundWrapper(
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SlideTransition(
              position: _bounceAnimation,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedPet(
                    petImagePath: petBase,
                    accessories: accessories,
                    showRainbowAura: hasRainbowAura,
                    scale: baseScale,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Level: ${widget.player.level}  |  Coins: ${widget.player.coins}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _bouncePet,
              icon: const Icon(Icons.play_arrow),
              label: const Text("Pet!"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
