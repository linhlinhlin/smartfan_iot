import 'package:flutter/material.dart';
import '../theme.dart';

class ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isEnabled;

  const ToggleRow({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.graphite700,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        Switch(
          value: value,
          onChanged: isEnabled ? onChanged : null,
          activeColor: AppTheme.iceBlueAccent,
          activeTrackColor: AppTheme.iceBlueAccent.withOpacity(0.3),
          inactiveThumbColor: AppTheme.graphite500,
          inactiveTrackColor: AppTheme.cosmicMist,
        ),
      ],
    );
  }
}