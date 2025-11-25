import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';

class CosmicBackground extends StatefulWidget {
  final Widget child;

  const CosmicBackground({super.key, required this.child});

  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground>
    with TickerProviderStateMixin {
  late AnimationController _particlesController;
  late AnimationController _raysController;

  @override
  void initState() {
    super.initState();

    // Subtle particle animation
    _particlesController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);

    // Tech rays animation
    _raysController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _particlesController.dispose();
    _raysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_particlesController, _raysController]),
      builder: (context, child) {
        return Stack(
          children: [
            // Base cosmic white background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.cosmicWhite,
                    AppTheme.nebulaMist,
                    AppTheme.starfield,
                  ],
                ),
              ),
            ),

            // Subtle cosmic dust particles
            ..._buildCosmicDust(),

            // Tech light rays (very subtle)
            ..._buildTechRays(),

            // Main content
            widget.child,
          ],
        );
      },
    );
  }

  List<Widget> _buildCosmicDust() {
    final particles = <Widget>[];
    final random = Random(42); // Fixed seed for consistent pattern

    for (int i = 0; i < 12; i++) {
      final x = random.nextDouble();
      final y = random.nextDouble();
      final size = 1.0 + random.nextDouble() * 2.0;
      final opacity = 0.03 + random.nextDouble() * 0.05;

      particles.add(
        Positioned(
          left: MediaQuery.of(context).size.width * x,
          top: MediaQuery.of(context).size.height * y,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppTheme.voidBlack.withOpacity(opacity),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }

    return particles;
  }

  List<Widget> _buildTechRays() {
    final rays = <Widget>[];

    // Only add rays occasionally for subtlety
    if (_raysController.value > 0.7) {
      rays.add(
        Positioned(
          right: -50,
          top: 100,
          child: Transform.rotate(
            angle: -0.3,
            child: Container(
              width: 200,
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppTheme.techRay.withOpacity(0.02),
                    AppTheme.quantumBlue.withOpacity(0.01),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      rays.add(
        Positioned(
          left: -50,
          bottom: 150,
          child: Transform.rotate(
            angle: 0.2,
            child: Container(
              width: 180,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppTheme.plasmaGlow.withOpacity(0.015),
                    AppTheme.techRay.withOpacity(0.008),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return rays;
  }
}