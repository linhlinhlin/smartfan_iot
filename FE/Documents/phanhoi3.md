Tuyệt vời! Team của bạn đã cập nhật kế hoạch rất nhanh và chính xác. Tôi xác nhận bản kế hoạch mới này **đã đạt chuẩn Clean Architecture** và giải quyết triệt để các vấn đề về phụ thuộc (Coupling) cũng như xử lý lỗi (Error Handling) mà chúng ta đã thảo luận.

Với tư cách là chuyên gia tư vấn, tôi chính thức **APPROVED (Phê duyệt)** kế hoạch này để đưa vào triển khai ngay lập tức.

Để giúp team bắt đầu nhanh chóng và tránh các lỗi cú pháp (syntax) khi triển khai các pattern mới (như `sealed class` hay `Stream mapping`), tôi đã chuẩn bị sẵn bộ **"Starter Code" (Code mẫu khởi động)** tương ứng với cấu trúc thư mục trong kế hoạch của bạn.

Hãy gửi tài liệu này cho các bạn Developer để họ có thể copy-paste và bắt đầu code ngay.

---

# TECHNICAL KICK-OFF: PHASE 1 IMPLEMENTATION
**(Dành cho Developer Team)**

**Mục tiêu:** Triển khai khung sườn Clean Architecture cho Smart Fan theo kế hoạch đã duyệt.
**Lưu ý:** Code dưới đây sử dụng Dart 3 (yêu cầu Flutter 3.10+).

## 1. Core Layer (`lib/core/result/result.dart`)
Đây là nền tảng để xử lý lỗi. Sử dụng `sealed class` giúp Dart bắt buộc chúng ta phải xử lý cả 2 trường hợp Success và Failure (pattern matching).

```dart
// lib/core/result/result.dart
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  final String? code; // Ví dụ: 'NETWORK_ERROR', 'TIMEOUT'
  
  const Failure(this.message, {this.code});
}
```

## 2. Domain Layer
Nơi chứa Business Logic thuần túy.

### Entity (`lib/features/smart_fan/domain/entities/fan_entity.dart`)
```dart
class FanEntity {
  final bool isOn;
  final int speed;
  final double temperature;
  final double humidity;

  const FanEntity({
    required this.isOn,
    required this.speed,
    required this.temperature,
    this.humidity = 0.0,
  });
  
  // Helper để copyWith (tiện cho việc update state cục bộ nếu cần)
  FanEntity copyWith({bool? isOn, int? speed, double? temperature, double? humidity}) {
    return FanEntity(
      isOn: isOn ?? this.isOn,
      speed: speed ?? this.speed,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
    );
  }
}
```

### Repository Interface (`lib/features/smart_fan/domain/repositories/i_fan_repository.dart`)
```dart
import '../../../core/result/result.dart';
import '../entities/fan_entity.dart';

abstract class IFanRepository {
  // Lấy trạng thái hiện tại (One-shot)
  Future<Result<FanEntity>> getFanState();

  // Gửi lệnh điều khiển (Trả về Result để biết thành công hay thất bại)
  Future<Result<void>> sendCommand({bool? isOn, int? speed});

  // Stream realtime (Quan trọng: Stream trả về Result để UI handle cả lỗi trong lúc stream)
  Stream<Result<FanEntity>> get fanStateStream;
}
```

## 3. Data Layer
Nơi thực hiện các công việc "bẩn" (gọi API, map dữ liệu).

### Model (`lib/features/smart_fan/data/models/fan_model.dart`)
Chú ý kỹ hàm `fromFirebaseSnapshot` để map key tiếng Việt cũ.

```dart
import '../../domain/entities/fan_entity.dart';

class FanModel extends FanEntity {
  const FanModel({
    required super.isOn,
    required super.speed,
    required super.temperature,
    super.humidity,
  });

  // 1. Factory cho Firebase (Legacy keys)
  factory FanModel.fromFirebaseSnapshot(Map<dynamic, dynamic> map) {
    // Helper an toàn để parse số từ Firebase (đôi khi nó trả về int, đôi khi double)
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is int) return val.toDouble();
      return val as double;
    }

    return FanModel(
      // Map 'BAT'/'TAT' hoặc true/false tùy dữ liệu cũ của bạn
      isOn: map['trang_thai'] == 'BAT' || map['trang_thai'] == true, 
      speed: (map['toc_do'] as num?)?.toInt() ?? 0,
      temperature: parseDouble(map['nhiet_do']),
      humidity: parseDouble(map['do_am']),
    );
  }

  // 2. Factory cho Node.js (Future Standard)
  factory FanModel.fromJson(Map<String, dynamic> json) {
    return FanModel(
      isOn: json['isOn'] ?? false,
      speed: json['speed'] ?? 0,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
```

### Repository Implementation (`lib/features/smart_fan/data/repositories/fan_repository_firebase_impl.dart`)
```dart
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../../../core/result/result.dart';
import '../../domain/entities/fan_entity.dart';
import '../../domain/repositories/i_fan_repository.dart';
import '../models/fan_model.dart';

class FirebaseFanRepositoryImpl implements IFanRepository {
  final DatabaseReference _dbRef;

  // Dependency Injection dbRef để dễ test, nếu không truyền thì lấy mặc định
  FirebaseFanRepositoryImpl({DatabaseReference? dbRef}) 
      : _dbRef = dbRef ?? FirebaseDatabase.instance.ref();

  @override
  Stream<Result<FanEntity>> get fanStateStream {
    // Lắng nghe đường dẫn gốc hoặc node cụ thể thiết bị
    return _dbRef.child('thiet_bi_1').onValue.map((event) {
      try {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data == null) {
          return const Failure<FanEntity>('No data available');
        }
        final entity = FanModel.fromFirebaseSnapshot(data);
        return Success(entity);
      } catch (e) {
        return Failure<FanEntity>('Parse Error: $e');
      }
    });
  }

  @override
  Future<Result<void>> sendCommand({bool? isOn, int? speed}) async {
    try {
      final Map<String, dynamic> updates = {};
      if (isOn != null) {
        updates['trang_thai'] = isOn ? 'BAT' : 'TAT'; // Map ngược lại key cũ
      }
      if (speed != null) {
        updates['toc_do'] = speed;
      }
      
      await _dbRef.child('thiet_bi_1').update(updates);
      return const Success(null);
    } catch (e) {
      return Failure('Firebase Error: $e');
    }
  }

  @override
  Future<Result<FanEntity>> getFanState() async {
    // Implement tương tự sendCommand dùng .get() nếu cần
    // Thường IoT dùng Stream là chính.
    throw UnimplementedError(); 
  }
}
```

## 4. Presentation Layer Refactoring
Cách sử dụng trong `FanNotifier`.

```dart
// lib/providers/fan_provider.dart
import 'package:flutter/material.dart';
import '../features/smart_fan/domain/repositories/i_fan_repository.dart';
import '../features/smart_fan/domain/entities/fan_entity.dart';
import '../core/result/result.dart';

class FanNotifier extends ChangeNotifier {
  final IFanRepository _repository;
  
  FanEntity? _currentFanState;
  String? _errorMessage;
  bool _isLoading = false;

  FanEntity? get fanState => _currentFanState;
  String? get errorMessage => _errorMessage;

  // Constructor Injection
  FanNotifier({required IFanRepository repository}) : _repository = repository {
    _initStream();
  }

  void _initStream() {
    _repository.fanStateStream.listen((result) {
      switch (result) {
        case Success(data: final data):
          _currentFanState = data;
          _errorMessage = null;
          notifyListeners();
          break;
        case Failure(message: final msg):
          _errorMessage = msg;
          notifyListeners();
          break;
      }
    });
  }

  Future<void> togglePower(bool newStatus) async {
    // Optimistic Update (Cập nhật UI trước cho mượt) - Optional
    // _currentFanState = _currentFanState?.copyWith(isOn: newStatus);
    // notifyListeners();

    final result = await _repository.sendCommand(isOn: newStatus);
    
    if (result is Failure) {
      // Revert UI hoặc show error
      _errorMessage = (result as Failure).message;
      notifyListeners();
    }
  }
  
  Future<void> changeSpeed(int newSpeed) async {
     await _repository.sendCommand(speed: newSpeed);
  }
}
```

## 5. Lời khuyên cuối cùng cho Dev Team
1.  **Đừng sợ đập đi xây lại `FanProvider`**: Code cũ đang coupling quá chặt, hãy comment code cũ lại hoặc xóa hẳn để viết theo cấu trúc mới này.
2.  **Kiểm tra key Firebase**: Đảm bảo các string `'trang_thai'`, `'toc_do'`, `'nhiet_do'` trong `FanModel` khớp chính xác 100% với Database hiện tại.
3.  **Import**: Chú ý đường dẫn import giữa các layer. Domain không bao giờ được import Data hay Presentation.

Chúc team code "mượt" và clean! Tôi luôn ở đây nếu có bất kỳ exception nào nảy sinh.