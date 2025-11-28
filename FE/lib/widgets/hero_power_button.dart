import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';

class HeroPowerButton extends StatefulWidget {
  final int currentSpeed; // 0 = off, 1-3 = speed levels
  final ValueChanged<int>? onSpeedChanged;
  final VoidCallback? onLongPress; // Long press to turn off
  final DateTime? timerExpiresAt; // Timer expiration for countdown ring
  final int? timerTotalMinutes; // Total timer duration for progress calculation
  final bool isLoading;

  const HeroPowerButton({
    super.key,
    required this.currentSpeed,
    this.onSpeedChanged,
    this.onLongPress,
    this.timerExpiresAt,
    this.timerTotalMinutes,
    this.isLoading = false,
  });

  bool get isOn => currentSpeed > 0;

  @override
  State<HeroPowerButton> createState() => _HeroPowerButtonState();
}

class _HeroPowerButtonState extends State<HeroPowerButton>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  
  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _updateCountdown();
  }

  void _initAnimations() {
    _rotationController = AnimationController(
      duration: Duration(seconds: widget.currentSpeed > 0 ? 4 - widget.currentSpeed : 10),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(CurvedAnimation(parent: _rotationController, curve: Curves.linear));

    _updateAnimations();
  }

  @override
  void didUpdateWidget(HeroPowerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isOn != widget.isOn || oldWidget.currentSpeed != widget.currentSpeed) {
      _updateAnimations();
    }
    if (oldWidget.timerExpiresAt != widget.timerExpiresAt) {
      _updateCountdown();
    }
  }

  void _updateAnimations() {
    if (widget.isOn) {
      _rotationController.duration = Duration(
        milliseconds: widget.currentSpeed > 0 ? (4000 ~/ widget.currentSpeed) : 4000,
      );
      _rotationController.repeat();
    } else {
      _rotationController.stop();
      _rotationController.reset();
    }
  }

  void _updateCountdown() {
    _countdownTimer?.cancel();
    
    // Only show timer when fan is ON
    if (widget.timerExpiresAt == null || !widget.isOn) {
      setState(() {
        _remainingTime = Duration.zero;
        _totalDuration = Duration.zero;
      });
      return;
    }

    // Calculate total duration from timerTotalMinutes or estimate from remaining
    if (widget.timerTotalMinutes != null && widget.timerTotalMinutes! > 0) {
      _totalDuration = Duration(minutes: widget.timerTotalMinutes!);
    } else {
      // Estimate: use remaining time as total (first time)
      final remaining = widget.timerExpiresAt!.difference(DateTime.now());
      if (remaining.inSeconds > 0) {
        _totalDuration = remaining;
      }
    }

    void updateRemaining() {
      if (!widget.isOn) {
        setState(() => _remainingTime = Duration.zero);
        _countdownTimer?.cancel();
        return;
      }
      
      final remaining = widget.timerExpiresAt!.difference(DateTime.now());
      setState(() {
        _remainingTime = remaining.isNegative ? Duration.zero : remaining;
      });
      
      if (remaining.isNegative) {
        _countdownTimer?.cancel();
      }
    }

    updateRemaining();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => updateRemaining());
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onSpeedChanged != null && !widget.isLoading) {
      final nextSpeed = (widget.currentSpeed + 1) % 4;
      widget.onSpeedChanged!(nextSpeed);
    }
  }

  void _handleLongPress() {
    if (widget.onLongPress != null && !widget.isLoading && widget.isOn) {
      widget.onLongPress!();
    }
  }

  String _formatRemainingTime() {
    if (_remainingTime.inSeconds <= 0) return '';
    final hours = _remainingTime.inHours;
    final minutes = _remainingTime.inMinutes % 60;
    final seconds = _remainingTime.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double _getTimerProgress() {
    if (!widget.isOn || _totalDuration.inSeconds <= 0 || _remainingTime.inSeconds <= 0) {
      return 0;
    }
    return (_remainingTime.inSeconds / _totalDuration.inSeconds).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    // Only show timer when fan is ON
    final hasTimer = widget.isOn && widget.timerExpiresAt != null && _remainingTime.inSeconds > 0;
    final timerProgress = _getTimerProgress();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _handleTap,
          onLongPress: _handleLongPress,
          child: AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return SizedBox(
                width: 160,
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Timer countdown ring (outer) - only when ON and has timer
                    if (hasTimer)
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: Transform.rotate(
                          angle: -pi / 2, // Start from top
                          child: CircularProgressIndicator(
                            value: timerProgress,
                            strokeWidth: 6,
                            backgroundColor: AppTheme.graphite500.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.iceBlueAccent.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ),

                    // Main button
                    Container(
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
                          BoxShadow(
                            color: widget.isOn
                                ? AppTheme.iceBlueAccent.withOpacity(0.4)
                                : Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Inner circle
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

                          // Fan icon with rotation
                          AnimatedRotation(
                            turns: widget.isOn ? _rotationAnimation.value : 0,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              Icons.ac_unit,
                              size: 48,
                              color: widget.isOn ? AppTheme.baseWhite : AppTheme.graphite500,
                            ),
                          ),

                          // Power indicator
                          Positioned(
                            top: 16,
                            right: 16,
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

                          // Speed indicator
                          if (widget.isOn && widget.currentSpeed > 0)
                            Positioned(
                              bottom: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.baseWhite.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.iceBlueAccent.withOpacity(0.4),
                                  ),
                                ),
                                child: Text(
                                  '${widget.currentSpeed}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.iceBlueAccent,
                                  ),
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
                              child: const CircularProgressIndicator(strokeWidth: 3),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Timer remaining time display - only when ON and has timer
        const SizedBox(height: 8),
        SizedBox(
          height: 20,
          child: hasTimer
              ? Text(
                  _formatRemainingTime(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.iceBlueAccent,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
