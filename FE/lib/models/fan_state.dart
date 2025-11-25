import 'package:flutter/material.dart';

class FanState {
  final int? power; // 0 or 1
  final int? mode; // 0, 1, 2
  final int? rotate; // 0 or 1
  final int? auto; // 0 or 1
  final double? temperature;
  final int? humidity;
  final int? lastSeenMs;

  const FanState({
    this.power,
    this.mode,
    this.rotate,
    this.auto,
    this.temperature,
    this.humidity,
    this.lastSeenMs,
  });

  FanState copyWith({
    int? power,
    int? mode,
    int? rotate,
    int? auto,
    double? temperature,
    int? humidity,
    int? lastSeenMs,
  }) {
    return FanState(
      power: power ?? this.power,
      mode: mode ?? this.mode,
      rotate: rotate ?? this.rotate,
      auto: auto ?? this.auto,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      lastSeenMs: lastSeenMs ?? this.lastSeenMs,
    );
  }

  bool get isOnline {
    if (lastSeenMs == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - lastSeenMs!) < 30000; // 30 seconds
  }

  String get statusText => isOnline ? 'Hoạt động' : 'Mất kết nối';
  Color get statusColor => isOnline ? Colors.green : Colors.grey;
}