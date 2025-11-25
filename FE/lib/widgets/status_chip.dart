import 'package:flutter/material.dart';
import '../theme.dart';

class StatusChip extends StatelessWidget {
  final bool isOnline;

  const StatusChip({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isOnline
            ? AppTheme.success.withOpacity(0.12)
            : const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(AppTheme.chipRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline ? Icons.circle : Icons.circle_outlined,
            size: 8,
            color: isOnline ? AppTheme.success : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? 'Hoạt động' : 'Mất kết nối',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isOnline ? AppTheme.success : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}