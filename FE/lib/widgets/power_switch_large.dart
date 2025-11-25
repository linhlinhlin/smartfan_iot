import 'package:flutter/material.dart';
import '../theme.dart';

class PowerSwitchLarge extends StatelessWidget {
  final bool isOn;
  final VoidCallback? onToggle;
  final bool isLoading;

  const PowerSwitchLarge({
    super.key,
    required this.isOn,
    this.onToggle,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onToggle,
      child: Container(
        height: 68,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isOn ? AppTheme.baseWhite : AppTheme.cosmicMist,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: const Color(0x10000000),
            width: 1,
          ),
          boxShadow: isOn
              ? [
                  BoxShadow(
                    color: AppTheme.iceBlueAccent.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Fan icon with rotation animation
            Positioned(
              left: 20,
              top: 0,
              bottom: 0,
              child: AnimatedRotation(
                turns: isOn ? 0.1 : 0, // Slight rotation when on
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  Icons.ac_unit, // Fan-like icon
                  size: 28,
                  color: isOn ? AppTheme.iceBlueAccent : AppTheme.graphite500,
                ),
              ),
            ),
            // Labels
            Positioned(
              left: 60,
              top: 0,
              bottom: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nguồn',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.graphite700,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 20,
              top: 0,
              bottom: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isOn ? 'Bật' : 'Tắt',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isOn ? AppTheme.iceBlueAccent : AppTheme.graphite500,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            // Loading indicator
            if (isLoading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.baseWhite.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}