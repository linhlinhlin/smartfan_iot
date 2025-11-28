import 'package:flutter/material.dart';
import '../theme.dart';

/// Timer button with cycle selection and binary hour indicators.
/// Tap to cycle through: 0 → 0.5h → 1h → 2h → 3h → 4h → 5h → 6h → 7h → 7.5h → 0
/// Shows indicators (0.5, 1, 2, 4) that light up based on binary representation.
/// Max timer: 7.5 hours (0.5 + 1 + 2 + 4)
class TimerButton extends StatelessWidget {
  /// Current timer duration in minutes (from expiresAt calculation)
  final int currentMinutes;
  
  /// Callback when timer value changes (minutes)
  final Function(int minutes) onTimerChanged;
  
  /// Whether the button is enabled
  final bool isEnabled;

  const TimerButton({
    super.key,
    required this.currentMinutes,
    required this.onTimerChanged,
    this.isEnabled = true,
  });

  /// Timer presets in minutes: 0, 30, 60, 120, 180, 240, 300, 360, 420, 450
  static const List<int> _presets = [0, 30, 60, 120, 180, 240, 300, 360, 420, 450];

  /// Get next preset value based on current minutes
  int _getNextPreset() {
    if (currentMinutes == 0) {
      return _presets[1]; // Start with 30 minutes
    }
    
    // Find the closest preset that is >= currentMinutes
    int currentIndex = 0;
    for (int i = 0; i < _presets.length; i++) {
      // Find preset that matches or is just below current
      if (_presets[i] <= currentMinutes + 5) { // +5 for tolerance (time passes)
        currentIndex = i;
      }
    }
    
    // Cycle to next preset
    int nextIndex = currentIndex + 1;
    if (nextIndex >= _presets.length) {
      nextIndex = 0; // Reset to 0 (cancel)
    }
    return _presets[nextIndex];
  }

  /// Calculate which indicators should be lit based on minutes
  /// Returns map of hour values to whether they're active
  Map<double, bool> _getActiveIndicators(int minutes) {
    // Convert to half-hours for easier calculation
    int halfHours = (minutes / 30).round();
    
    // Binary representation: 0.5h=1, 1h=2, 2h=4, 4h=8
    // So halfHours maps to: bit0=0.5h, bit1=1h, bit2=2h, bit3=4h
    return {
      0.5: (halfHours & 1) != 0,  // bit 0
      1.0: (halfHours & 2) != 0,  // bit 1
      2.0: (halfHours & 4) != 0,  // bit 2
      4.0: (halfHours & 8) != 0,  // bit 3
    };
  }

  String _formatDuration(int minutes) {
    if (minutes == 0) return 'Tắt';
    if (minutes < 60) return '${minutes}p';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '${hours}h';
    return '${hours}h${mins}p';
  }

  @override
  Widget build(BuildContext context) {
    final hasTimer = currentMinutes > 0;
    final indicators = _getActiveIndicators(currentMinutes);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main timer button
        GestureDetector(
          onTap: isEnabled ? () => onTimerChanged(_getNextPreset()) : null,
          onLongPress: isEnabled && hasTimer ? () => onTimerChanged(0) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: hasTimer 
                  ? AppTheme.iceBlueAccent.withOpacity(0.15)
                  : AppTheme.graphite500.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              border: Border.all(
                color: hasTimer 
                    ? AppTheme.iceBlueAccent.withOpacity(0.5)
                    : AppTheme.graphite500.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasTimer ? Icons.timer : Icons.timer_outlined,
                  color: hasTimer ? AppTheme.iceBlueAccent : AppTheme.graphite500,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  hasTimer ? _formatDuration(currentMinutes) : 'Hẹn giờ',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: hasTimer ? AppTheme.iceBlueAccent : AppTheme.graphite500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Hour indicators row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [0.5, 1.0, 2.0, 4.0].map((hours) {
            final isActive = indicators[hours] ?? false;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _HourIndicator(
                hours: hours,
                isActive: isActive,
              ),
            );
          }).toList(),
        ),
        if (hasTimer)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Giữ để hủy',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.graphite500.withOpacity(0.7),
              ),
            ),
          ),
      ],
    );
  }
}

class _HourIndicator extends StatelessWidget {
  final double hours;
  final bool isActive;

  const _HourIndicator({
    required this.hours,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 24,
      decoration: BoxDecoration(
        color: isActive 
            ? AppTheme.iceBlueAccent 
            : AppTheme.graphite500.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isActive 
              ? AppTheme.iceBlueAccent 
              : AppTheme.graphite500.withOpacity(0.3),
        ),
      ),
      child: Center(
        child: Text(
          hours == 0.5 ? '½' : '${hours.toInt()}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppTheme.graphite500,
          ),
        ),
      ),
    );
  }
}
