import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';

class HeroPowerButton extends StatefulWidget {
  final bool isOn;
  final int currentSpeed; // 0-3 (0 = off, 1-3 = speed levels)
  final VoidCallback? onPressed;
  final bool isLoading;

  const HeroPowerButton({
    super.key,
    required this.isOn,
    required this.currentSpeed,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  State<HeroPowerButton> createState() => _HeroPowerButtonState();
}

class _HeroPowerButtonState extends State<HeroPowerButton>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pressController;
  late AnimationController _lightningController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _lightningAnimation;

  @override
  void initState() {
    super.initState();

    // Rotation animation for fan
    _rotationController = AnimationController(
      duration: Duration(seconds: widget.currentSpeed > 0 ? 4 - widget.currentSpeed : 10),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // Press effect animation
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));

    // Lightning effect animation
    _lightningController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _lightningAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _lightningController,
      curve: Curves.easeInOut,
    ));

    _updateAnimations();
  }

  @override
  void didUpdateWidget(HeroPowerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isOn != widget.isOn ||
        oldWidget.currentSpeed != widget.currentSpeed) {
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    if (widget.isOn && widget.currentSpeed > 0) {
      _rotationController.repeat();
    } else {
      _rotationController.stop();
      _rotationController.reset();
    }

    if (widget.isOn && !widget.isLoading) {
      _lightningController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pressController.dispose();
    _lightningController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onPressed != null && !widget.isLoading) {
      _pressController.forward().then((_) => _pressController.reverse());
      widget.onPressed!();
    }
  }

  void _handleDoubleTap() {
    if (widget.onPressed != null && !widget.isLoading) {
      _pressController.forward().then((_) => _pressController.reverse());
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onDoubleTap: _handleDoubleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _rotationAnimation,
          _scaleAnimation,
          _lightningAnimation,
        ]),
        builder: (context, child) {
          return Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.isOn
                    ? [
                        AppTheme.iceBlueAccent.withOpacity(0.8),
                        AppTheme.iceBlueAccent.withOpacity(0.6),
                        AppTheme.tealIce.withOpacity(0.4),
                      ]
                    : [
                        AppTheme.cosmicMist,
                        AppTheme.cosmicMist.withOpacity(0.8),
                      ],
              ),
              boxShadow: [
                // Main shadow for 3D effect
                BoxShadow(
                  color: widget.isOn
                      ? AppTheme.iceBlueAccent.withOpacity(0.4)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
                // Inner glow
                BoxShadow(
                  color: widget.isOn
                      ? AppTheme.iceBlueAccent.withOpacity(0.2)
                      : Colors.white.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: -5,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle with subtle pattern
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isOn
                        ? AppTheme.baseWhite.withOpacity(0.1)
                        : AppTheme.baseWhite,
                    border: Border.all(
                      color: widget.isOn
                          ? AppTheme.iceBlueAccent.withOpacity(0.3)
                          : AppTheme.graphite500.withOpacity(0.1),
                      width: 2,
                    ),
                  ),
                ),

                // Lightning arcs (blockchain theme)
                if (widget.isOn && _lightningAnimation.value > 0)
                  ..._buildLightningArcs(),

                // Main fan icon with rotation
                AnimatedRotation(
                  turns: widget.isOn ? _rotationAnimation.value : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.ac_unit, // Fan-like icon
                    size: 48,
                    color: widget.isOn
                        ? AppTheme.baseWhite
                        : AppTheme.graphite500,
                  ),
                ),

                // Power indicator dot
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isOn ? AppTheme.success : AppTheme.graphite500,
                      boxShadow: [
                        BoxShadow(
                          color: widget.isOn
                              ? AppTheme.success.withOpacity(0.6)
                              : AppTheme.graphite500.withOpacity(0.3),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),

                // Loading indicator
                if (widget.isLoading)
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.baseWhite.withOpacity(0.9),
                    ),
                    child: const CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),

                // Speed indicator
                if (widget.isOn && widget.currentSpeed > 0)
                  Positioned(
                    bottom: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.baseWhite.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.iceBlueAccent.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${widget.currentSpeed}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.iceBlueAccent,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildLightningArcs() {
    final arcs = <Widget>[];
    final arcCount = 3;

    for (int i = 0; i < arcCount; i++) {
      final angle = (2 * pi * i) / arcCount;
      final opacity = _lightningAnimation.value * (0.3 + Random(i).nextDouble() * 0.4);

      arcs.add(
        Positioned(
          left: 70 + 50 * cos(angle),
          top: 70 + 50 * sin(angle),
          child: Container(
            width: 20,
            height: 3,
            decoration: BoxDecoration(
              color: AppTheme.iceBlueAccent.withOpacity(opacity),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.iceBlueAccent.withOpacity(opacity * 0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return arcs;
  }
}