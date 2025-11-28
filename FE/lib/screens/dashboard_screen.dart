import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fan_provider.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/status_chip.dart';
import '../widgets/stat_card.dart';
import '../widgets/hero_power_button.dart';
import '../widgets/control_button.dart';
import '../widgets/timer_picker_dialog.dart';
import '../theme.dart';

const deviceId = 'quat_thong_minh_2';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _formatLastSeen(int? lastSeenMs) {
    if (lastSeenMs == null) return 'Chưa có dữ liệu';
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - lastSeenMs;
    if (diff < 60000) return 'Vừa cập nhật';
    final minutes = (diff / 60000).floor();
    return 'Cập nhật $minutes phút trước';
  }

  void _showTimerPicker(BuildContext context, FanNotifier fanNotifier, int currentMinutes) {
    debugPrint('[Dashboard] Opening timer picker with currentMinutes: $currentMinutes');
    showDialog(
      context: context,
      builder: (dialogContext) => TimerPickerDialog(
        initialMinutes: currentMinutes,
        onConfirm: (minutes) {
          debugPrint('[Dashboard] Timer confirmed: $minutes minutes');
          fanNotifier.sendTimerCommand(minutes);
        },
      ),
    );
  }

  int _calculateRemainingMinutes(DateTime? expiresAt) {
    if (expiresAt == null) return 0;
    final remaining = expiresAt.difference(DateTime.now());
    if (remaining.isNegative) return 0;
    return remaining.inMinutes;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FanNotifier>(
      builder: (context, fanNotifier, child) {
        final fanState = fanNotifier.state;
        final isOn = fanState.power == 1;
        final timerMinutes = _calculateRemainingMinutes(fanState.timerExpiresAt);
        final hasTimer = isOn && timerMinutes > 0;

        return CosmicBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Text('Quạt Phòng Khách'),
              actions: [
                StatusChip(isOnline: fanState.isOnline),
                const SizedBox(width: 16),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    // Sensor Cards Row
                    Row(
                      children: [
                        StatCard(
                          title: 'Nhiệt độ',
                          value: fanState.temperature?.toStringAsFixed(1) ?? '--',
                          unit: '°C',
                          subtitle: _formatLastSeen(fanState.lastSeenMs),
                          icon: Icons.thermostat,
                        ),
                        const SizedBox(width: 12),
                        StatCard(
                          title: 'Độ ẩm',
                          value: fanState.humidity?.toString() ?? '--',
                          unit: '%',
                          subtitle: 'Ổn định',
                          icon: Icons.water_drop,
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Main Controls Section
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Power Button with timer ring
                        HeroPowerButton(
                          currentSpeed: isOn ? (fanState.mode ?? 0) + 1 : 0,
                          isLoading: fanNotifier.isLoading,
                          timerExpiresAt: isOn ? fanState.timerExpiresAt : null,
                          timerTotalMinutes: timerMinutes > 0 ? timerMinutes + 1 : null,
                          onSpeedChanged: (newSpeed) {
                            if (newSpeed == 0) {
                              fanNotifier.sendCommand('power', 0);
                            } else {
                              if (!isOn) {
                                fanNotifier.sendCommand('power', 1);
                              }
                              fanNotifier.sendCommand('mode', newSpeed - 1);
                            }
                          },
                          onLongPress: () => fanNotifier.sendCommand('power', 0),
                        ),

                        const SizedBox(height: 24),

                        // Secondary Control Buttons Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Timer Button - disabled when OFF
                            ControlButton(
                              icon: hasTimer ? Icons.timer : Icons.timer_outlined,
                              label: 'Hẹn giờ',
                              isActive: hasTimer,
                              isEnabled: isOn && !fanNotifier.isLoading,
                              onTap: () => _showTimerPicker(context, fanNotifier, timerMinutes),
                              onLongPress: hasTimer ? () => fanNotifier.sendTimerCommand(0) : null,
                            ),

                            const SizedBox(width: 24),

                            // Rotate Button - disabled when OFF
                            ControlButton(
                              icon: Icons.sync,
                              label: 'Xoay',
                              isActive: fanState.rotate == 1,
                              isEnabled: isOn && !fanNotifier.isLoading,
                              onTap: () => fanNotifier.sendCommand('rotate', fanState.rotate == 1 ? 0 : 1),
                            ),

                            const SizedBox(width: 24),

                            // Auto Button - disabled when OFF
                            ControlButton(
                              icon: Icons.auto_mode,
                              label: 'Tự động',
                              isActive: fanState.auto == 1,
                              isEnabled: isOn && !fanNotifier.isLoading,
                              onTap: () => fanNotifier.sendCommand('auto', fanState.auto == 1 ? 0 : 1),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Footer
                    Text(
                      _formatLastSeen(fanState.lastSeenMs),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.graphite500,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                // TODO: Show voice sheet
              },
              backgroundColor: AppTheme.techRay,
              child: const Icon(Icons.mic),
            ),
          ),
        );
      },
    );
  }
}
