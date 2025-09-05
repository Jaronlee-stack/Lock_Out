import 'package:flutter/material.dart';

class AnimatedPet extends StatefulWidget {
  final String petImagePath;
  final List<Map<String, dynamic>> accessories; // Now accepts positions too!

  const AnimatedPet({
    super.key,
    required this.petImagePath,
    this.accessories = const [],
  });

  @override
  State<AnimatedPet> createState() => _AnimatedPetState();
}

class _AnimatedPetState extends State<AnimatedPet>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _tapController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _tapAnimation;

  @override
  void initState() {
    super.initState();

    // Bounce controller (looping)
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    // Tap controller (plays once)
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _tapAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeOut),
    );

    _tapController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _tapController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!_tapController.isAnimating) {
      _tapController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_bounceController, _tapController]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _bounceAnimation.value),
            child: Transform.scale(
              scale: _tapAnimation.value,
              child: SizedBox(
                width: 250,
                height: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pet Image
                    Image.asset(
                      widget.petImagePath,
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),

                    // Accessories with adjustable positions
                    for (var accessory in widget.accessories)
                      Positioned(
                        left: accessory['left'] ?? 0.0,
                        top: accessory['top'] ?? 0.0,
                        child: Image.asset(
                          accessory['image'],
                          width: accessory['width'] ?? 50,
                          height: accessory['height'] ?? 50,
                          fit: BoxFit.contain,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
