import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedPet extends StatefulWidget {
  final String petImagePath;
  final List<Map<String, dynamic>> accessories;
  final bool showRainbowAura;
  final double scale;

  const AnimatedPet({
    super.key,
    required this.petImagePath,
    this.accessories = const [],
    this.showRainbowAura = false,
    this.scale = 1.0,
  });

  @override
  State<AnimatedPet> createState() => _AnimatedPetState();
}

class _AnimatedPetState extends State<AnimatedPet>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _tapController;
  late AnimationController _auraController;

  late Animation<double> _bounceAnimation;
  late Animation<double> _tapAnimation;
  late Animation<double> _auraRotation;

  @override
  void initState() {
    super.initState();

    // Bounce animation
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

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

    // Aura rotation animation
    _auraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _auraRotation = Tween<double>(begin: 0, end: 2 * pi).animate(_auraController);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _tapController.dispose();
    _auraController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!_tapController.isAnimating) {
      _tapController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final combinedScale = _tapAnimation.value * widget.scale;

    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_bounceController, _tapController, _auraController]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _bounceAnimation.value),
            child: Transform.scale(
              scale: combinedScale,
              child: SizedBox(
                width: 240 * widget.scale,
                height: 240 * widget.scale,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    if (widget.showRainbowAura)
                      SizedBox(
                        width: 240 * widget.scale,
                        height: 240 * widget.scale,
                        child: CustomPaint(
                          painter: RainbowAuraPainter(angle: _auraRotation.value),
                        ),
                      ),
                    Image.asset(
                      widget.petImagePath,
                      width: 200 * widget.scale,
                      height: 200 * widget.scale,
                    ),
                    for (var accessory in widget.accessories)
                      Positioned(
                        left: (accessory['left'] as double) * widget.scale,
                        top: (accessory['top'] as double) * widget.scale,
                        child: Image.asset(
                          accessory['image'],
                          width: (accessory['width'] as double) * widget.scale,
                          height: (accessory['height'] as double) * widget.scale,
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

class RainbowAuraPainter extends CustomPainter {
  final double angle;

  RainbowAuraPainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: Offset(radius, radius), radius: radius);

    final paint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * pi,
        colors: [
          const Color.fromARGB(255, 253, 70, 57),
          const Color.fromARGB(255, 255, 168, 37),
          Colors.yellow,
          Colors.green,
          Colors.blue,
          Colors.purple,
          Colors.red,
        ],
        transform: GradientRotation(angle),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawCircle(Offset(radius, radius), radius - 6, paint);
  }

  @override
  bool shouldRepaint(covariant RainbowAuraPainter oldDelegate) {
    return oldDelegate.angle != angle;
  }
}
