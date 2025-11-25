import 'package:flutter/material.dart';
import '../theme.dart';

class ModeSegmented extends StatelessWidget {
  final int? selectedMode;
  final ValueChanged<int>? onModeChanged;
  final bool isEnabled;

  const ModeSegmented({
    super.key,
    this.selectedMode,
    this.onModeChanged,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.baseWhite,
        borderRadius: BorderRadius.circular(AppTheme.chipRadius),
        border: Border.all(
          color: const Color(0x10000000),
          width: 1,
        ),
      ),
      child: Row(
        children: List.generate(3, (index) {
          final isSelected = selectedMode == index;
          return Expanded(
            child: GestureDetector(
              onTap: isEnabled && onModeChanged != null
                  ? () => onModeChanged!(index)
                  : null,
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.iceBlueAccent.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.chipRadius - 2),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.iceBlueAccent.withOpacity(0.2),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isSelected
                              ? AppTheme.iceBlueAccent
                              : AppTheme.graphite500,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}