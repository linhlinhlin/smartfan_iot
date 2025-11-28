import 'package:flutter/material.dart';
import '../theme.dart';

/// Widget for selecting timer duration with preset options.
/// Displays preset options (30min, 1h, 2h, 4h, 8h) and shows current timer status.
/// Requirements: 1.1, 2.1
class TimerSelector extends StatelessWidget {
  /// Current timer expiration timestamp, null if no active timer
  final DateTime? currentExpiresAt;
  
  /// Callback when user selects a timer duration (in minutes)
  final Function(int minutes) onTimerSet;
  
  /// Callback when user cancels the timer
  final VoidCallback onTimerCancel;
  
  /// Whether the selector is enabled
  final bool isEnabled;

  const TimerSelector({
    super.key,
    this.currentExpiresAt,
    required this.onTimerSet,
    required this.onTimerCancel,
    this.isEnabled = true,
  });

  /// Preset timer options in minutes
  static const List<int> presets = [30, 60, 120, 240, 480];

  /// Get display label for preset duration
  static String _getPresetLabel(int minutes) {
    if (minutes < 60) {
      return '${minutes}p';
    } else {
      final hours = minutes ~/ 60;
      return '${hours}h';
    }
  }

  /// Check if timer is currently active
  bool get hasActiveTimer {
    if (currentExpiresAt == null) return false;
    return currentExpiresAt!.isAfter(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with title and status
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hẹn giờ tắt',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (hasActiveTimer)
              _buildActiveTimerBadge(context),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMd),
        
        // Preset options
        Wrap(
          spacing: AppTheme.spacingXs,
          runSpacing: AppTheme.spacingXs,
          children: presets.map((minutes) => _buildPresetChip(context, minutes)).toList(),
        ),
        
        // Cancel button when timer is active
        if (hasActiveTimer) ...[
          const SizedBox(height: AppTheme.spacingMd),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isEnabled ? onTimerCancel : null,
              icon: const Icon(Icons.timer_off, size: 18),
              label: const Text('Hủy hẹn giờ'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.error,
                side: const BorderSide(color: AppTheme.error),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActiveTimerBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingXs,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.chipRadius),
        border: Border.all(color: AppTheme.success.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 14,
            color: AppTheme.success,
          ),
          const SizedBox(width: 4),
          Text(
            'Đang hoạt động',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.success,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(BuildContext context, int minutes) {
    return ActionChip(
      label: Text(_getPresetLabel(minutes)),
      onPressed: isEnabled ? () => onTimerSet(minutes) : null,
      backgroundColor: AppTheme.cosmicWhite,
      side: BorderSide(color: AppTheme.iceBlueAccent.withOpacity(0.5)),
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: isEnabled ? AppTheme.iceBlueAccent : AppTheme.graphite500,
      ),
    );
  }
}
