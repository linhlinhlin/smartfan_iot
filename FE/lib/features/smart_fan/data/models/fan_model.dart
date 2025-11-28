import '../../domain/entities/fan_entity.dart';

class FanModel extends FanEntity {
  const FanModel({
    required super.isOn,
    required super.speed,
    required super.isRotating,
    required super.isAuto,
    required super.temperature,
    super.humidity,
    super.timerExpiresAt,
  });

  // 1. Factory cho Firebase (Legacy keys)
  factory FanModel.fromFirebaseSnapshot(Map<dynamic, dynamic> map) {
    // Helper an toàn để parse số từ Firebase (đôi khi nó trả về int, đôi khi double)
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is int) return val.toDouble();
      return val as double;
    }

    // Helper to parse ISO 8601 timestamp string to DateTime
    DateTime? parseDateTime(dynamic val) {
      if (val == null) return null;
      if (val is String) {
        return DateTime.tryParse(val);
      }
      return null;
    }

    return FanModel(
      // Map 'BAT'/'TAT' hoặc true/false tùy dữ liệu cũ của bạn. 
      // Old code: data['dang_bat'] == true ? 1 : data['power']
      // Old code logic was weird. Let's assume standard boolean or 1/0.
      isOn: map['dang_bat'] == true || map['dang_bat'] == 1 || map['trang_thai'] == 'BAT', 
      speed: (map['power'] as num?)?.toInt() ?? (map['toc_do'] as num?)?.toInt() ?? 0,
      isRotating: map['dang_xoay'] == true || map['dang_xoay'] == 1 || map['rotation'] == 1,
      isAuto: map['che_do'] == 'tu_dong' || map['auto'] == 1,
      temperature: parseDouble(map['nhiet_do']),
      humidity: parseDouble(map['do_am']),
      timerExpiresAt: parseDateTime(map['timerExpiresAt']),
    );
  }

  // 2. Factory cho Node.js (Future Standard)
  factory FanModel.fromJson(Map<String, dynamic> json) {
    // Helper to parse ISO 8601 timestamp string to DateTime
    DateTime? parseDateTime(dynamic val) {
      if (val == null) return null;
      if (val is String) {
        return DateTime.tryParse(val);
      }
      return null;
    }

    return FanModel(
      isOn: json['isOn'] ?? false,
      speed: json['speed'] ?? 0,
      isRotating: json['isRotating'] ?? false,
      isAuto: json['isAuto'] ?? false,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 0.0,
      timerExpiresAt: parseDateTime(json['timerExpiresAt']),
    );
  }
}
