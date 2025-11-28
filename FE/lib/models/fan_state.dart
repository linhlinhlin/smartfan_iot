import 'package:flutter/material.dart';

class FanState {
  final int? power; // 0 or 1
  final int? mode; // 0, 1, 2
  final int? rotate; // 0 or 1
  final int? auto; // 0 or 1
  final double? temperature;
  final int? humidity;
  final int? lastSeenMs;
  final DateTime? timerExpiresAt;

  const FanState({
    this.power,
    this.mode,
    this.rotate,
    this.auto,
    this.temperature,
    this.humidity,
    this.lastSeenMs,
    this.timerExpiresAt,
  });

  FanState copyWith({
    int? power,
    int? mode,
    int? rotate,
    int? auto,
    double? temperature,
    int? humidity,
    int? lastSeenMs,
    DateTime? timerExpiresAt,
  }) {
    return FanState(
      power: power ?? this.power,
      mode: mode ?? this.mode,
      rotate: rotate ?? this.rotate,
      auto: auto ?? this.auto,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      lastSeenMs: lastSeenMs ?? this.lastSeenMs,
      timerExpiresAt: timerExpiresAt ?? this.timerExpiresAt,
    );
  }

  bool get isOnline {
    if (lastSeenMs == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - lastSeenMs!) < 30000; // 30 seconds
  }

  String get statusText => isOnline ? 'Hoạt động' : 'Mất kết nối';
  Color get statusColor => isOnline ? Colors.green : Colors.grey;

  /// Returns formatted remaining time as HH:mm:ss, or null if no active timer
  String? get formattedRemainingTime {
    if (timerExpiresAt == null) return null;
    final remaining = timerExpiresAt!.difference(DateTime.now());
    if (remaining.isNegative) return null;

    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Returns true if there is an active timer that hasn't expired yet
  bool get hasActiveTimer {
    if (timerExpiresAt == null) return false;
    return timerExpiresAt!.isAfter(DateTime.now());
  }
}