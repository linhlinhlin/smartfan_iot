import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fan_provider.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/status_chip.dart';
import '../widgets/stat_card.dart';
import '../widgets/hero_power_button.dart';
import '../widgets/mode_segmented.dart';
import '../widgets/toggle_row.dart';
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

  @override
  Widget build(BuildContext context) {
    return Consumer<FanNotifier>(
      builder: (context, fanNotifier, child) {
        final fanState = fanNotifier.state;

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
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sensor Cards
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
                  const SizedBox(height: 32),
                  // Hero Power Button - Central Focus
                  Center(
                    child: HeroPowerButton(
                      isOn: fanState.power == 1,
                      currentSpeed: fanState.power == 1 ? (fanState.mode ?? 0) + 1 : 0,
                      isLoading: fanNotifier.isLoading,
                      onPressed: () => fanNotifier.sendCommand('power', fanState.power == 1 ? 0 : 1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      fanState.power == 1 ? 'Quạt đang hoạt động' : 'Quạt đã tắt',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: fanState.power == 1 ? AppTheme.iceBlueAccent : AppTheme.graphite500,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Secondary Controls Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Điều khiển nâng cao',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 20),
                          // Mode Segmented
                          Text(
                            'Tốc độ',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(height: 8),
                          ModeSegmented(
                            selectedMode: fanState.mode,
                            isEnabled: fanState.auto != 1 && !fanNotifier.isLoading,
                            onModeChanged: (mode) => fanNotifier.sendCommand('mode', mode),
                          ),
                          if (fanState.auto == 1)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.iceBlueAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppTheme.chipRadius),
                                border: Border.all(
                                  color: AppTheme.iceBlueAccent.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Chế độ tự động đang bật - tốc độ có thể được điều chỉnh tự động',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.iceBlueAccent,
                                      fontWeight: FontWeight.w500,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          const SizedBox(height: 20),
                          // Toggles
                          ToggleRow(
                            label: '↻ Xoay',
                            value: fanState.rotate == 1,
                            isEnabled: !fanNotifier.isLoading,
                            onChanged: (value) => fanNotifier.sendCommand('rotate', value ? 1 : 0),
                          ),
                          const SizedBox(height: 12),
                          ToggleRow(
                            label: 'A Tự động',
                            value: fanState.auto == 1,
                            isEnabled: !fanNotifier.isLoading,
                            onChanged: (value) => fanNotifier.sendCommand('auto', value ? 1 : 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Last updated
                  Center(
                    child: Text(
                      _formatLastSeen(fanState.lastSeenMs),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.graphite500,
                          ),
                    ),
                  ),
                ],
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