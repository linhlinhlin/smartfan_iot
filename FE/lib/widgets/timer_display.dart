import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';

/// Widget that displays countdown timer in HH:mm:ss format.
/// Uses Timer.periodic for 1-second updates and properly disposes resources.
/// Requirements: 1.2, 1.4, 6.1, 6.2
class TimerDisplay extends StatefulWidget {
  /// Timer expiration timestamp
  final DateTime? expiresAt;
  
  /// Optional callback when timer expires
  final VoidCallback? onExpired;

  const TimerDisplay({
    super.key,
    this.expiresAt,
    this.onExpired,
  });

  @override
  State<TimerDisplay> createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<TimerDisplay> {
  Timer? _timer;
  String _displayTime = '00:00:00';
  bool _hasExpired = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(TimerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart timer if expiresAt changed
    if (widget.expiresAt != oldWidget.expiresAt) {
      _hasExpired = false;
      _startTimer();
    }
  }

  @override
  void dispose() {
    // Cancel timer to prevent memory leaks (Requirement 6.1, 6.2)
    _cancelTimer();
    super.dispose();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _startTimer() {
    _cancelTimer();
    
    if (widget.expiresAt == null) {
      setState(() {
        _displayTime = '00:00:00';
      });
      return;
    }

    // Update immediately
    _updateDisplay();

    // Start periodic timer for 1-second updates (Requirement 1.4)
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateDisplay();
    });
  }

  void _updateDisplay() {
    if (widget.expiresAt == null) {
      setState(() {
        _displayTime = '00:00:00';
      });
      return;
    }

    final remaining = widget.expiresAt!.difference(DateTime.now());
    
    if (remaining.isNegative) {
      _cancelTimer();
      setState(() {
        _displayTime = '00:00:00';
      });
      
      // Notify expiration only once
      if (!_hasExpired) {
        _hasExpired = true;
        widget.onExpired?.call();
      }
      return;
    }

    // Format as HH:mm:ss (Requirement 1.2)
    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    
    setState(() {
      _displayTime = '$hours:$minutes:$seconds';
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveTimer = widget.expiresAt != null && 
        widget.expiresAt!.isAfter(DateTime.now());

    if (!hasActiveTimer) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppTheme.iceBlueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(
          color: AppTheme.iceBlueAccent.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            color: AppTheme.iceBlueAccent,
            size: 20,
          ),
          const SizedBox(width: AppTheme.spacingXs),
          Text(
            'Tắt sau ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.graphite500,
            ),
          ),
          Text(
            _displayTime,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.iceBlueAccent,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
