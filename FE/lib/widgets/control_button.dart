import 'package:flutter/material.dart';
import '../theme.dart';

/// Circular control button with icon, similar style to power button but smaller.
/// Used for Timer, Rotate, Auto controls.
class ControlButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final bool isActive;
  final bool isEnabled;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double size;

  const ControlButton({
    super.key,
    required this.icon,
    this.label,
    this.isActive = false,
    this.isEnabled = true,
    this.onTap,
    this.onLongPress,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveEnabled = isEnabled && (onTap != null || onLongPress != null);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: effectiveEnabled ? onTap : null,
          onLongPress: effectiveEnabled ? onLongPress : null,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isActive
                    ? [
                        AppTheme.iceBlueAccent.withOpacity(0.7),
                        AppTheme.iceBlueAccent.withOpacity(0.5),
                        AppTheme.tealIce.withOpacity(0.3),
                      ]
                    : [
                        AppTheme.cosmicMist,
                        AppTheme.cosmicMist.withOpacity(0.8),
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: isActive
                      ? AppTheme.iceBlueAccent.withOpacity(0.3)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? AppTheme.baseWhite.withOpacity(0.15)
                    : AppTheme.baseWhite,
                border: Border.all(
                  color: isActive
                      ? AppTheme.iceBlueAccent.withOpacity(0.3)
                      : AppTheme.graphite500.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                size: size * 0.4,
                color: effectiveEnabled
                    ? (isActive ? AppTheme.baseWhite : AppTheme.graphite500)
                    : AppTheme.graphite500.withOpacity(0.4),
              ),
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 6),
          Text(
            label!,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isActive ? AppTheme.iceBlueAccent : AppTheme.graphite500,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
