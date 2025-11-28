import 'package:flutter/material.dart';
import '../theme.dart';

/// Dialog for selecting timer duration with presets and slider.
class TimerPickerDialog extends StatefulWidget {
  final int initialMinutes;
  final Function(int minutes) onConfirm;

  const TimerPickerDialog({
    super.key,
    this.initialMinutes = 0,
    required this.onConfirm,
  });

  @override
  State<TimerPickerDialog> createState() => _TimerPickerDialogState();
}

class _TimerPickerDialogState extends State<TimerPickerDialog> {
  late double _sliderValue; // in minutes (0-480)
  
  static const List<int> _presets = [30, 60, 120, 240, 480]; // minutes

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.initialMinutes.toDouble().clamp(0, 480);
  }

  String _formatDuration(int minutes) {
    if (minutes == 0) return '0 phút';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours == 0) return '$mins phút';
    if (mins == 0) return '$hours giờ';
    return '$hours giờ $mins phút';
  }

  String _getPresetLabel(int minutes) {
    if (minutes < 60) return '${minutes}p';
    return '${minutes ~/ 60}h';
  }

  @override
  Widget build(BuildContext context) {
    final selectedMinutes = _sliderValue.round();

    return Dialog(
      backgroundColor: AppTheme.cosmicWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Row(
              children: [
                Icon(Icons.timer, color: AppTheme.iceBlueAccent),
                const SizedBox(width: 8),
                Text(
                  'Hẹn giờ tắt',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),

            // Current selection display
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: AppTheme.iceBlueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.iceBlueAccent.withOpacity(0.3)),
              ),
              child: Text(
                _formatDuration(selectedMinutes),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.iceBlueAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Preset buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _presets.map((minutes) {
                final isSelected = selectedMinutes == minutes;
                return ChoiceChip(
                  label: Text(_getPresetLabel(minutes)),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _sliderValue = minutes.toDouble()),
                  selectedColor: AppTheme.iceBlueAccent,
                  backgroundColor: AppTheme.cosmicMist,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.graphite500,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Slider
            Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppTheme.iceBlueAccent,
                    inactiveTrackColor: AppTheme.graphite500.withOpacity(0.2),
                    thumbColor: AppTheme.iceBlueAccent,
                    overlayColor: AppTheme.iceBlueAccent.withOpacity(0.2),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    value: _sliderValue,
                    min: 0,
                    max: 480,
                    divisions: 96, // 5-minute increments
                    onChanged: (value) => setState(() => _sliderValue = value),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0', style: TextStyle(color: AppTheme.graphite500, fontSize: 12)),
                      Text('8 giờ', style: TextStyle(color: AppTheme.graphite500, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.graphite500,
                      side: BorderSide(color: AppTheme.graphite500.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedMinutes > 0
                        ? () {
                            debugPrint('[TimerPickerDialog] Confirm pressed with $selectedMinutes minutes');
                            widget.onConfirm(selectedMinutes);
                            Navigator.pop(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.iceBlueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      disabledBackgroundColor: AppTheme.graphite500.withOpacity(0.3),
                    ),
                    child: const Text('Hẹn giờ'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
