import 'package:holilihu_fan/core/result/result.dart';
import '../entities/fan_entity.dart';

abstract class IFanRepository {
  // Lấy trạng thái hiện tại (One-shot)
  Future<Result<FanEntity>> getFanState();

  // Gửi lệnh điều khiển (Trả về Result để biết thành công hay thất bại)
  Future<Result<void>> sendCommand({
    bool? isOn, 
    int? speed,
    bool? isRotating,
    bool? isAuto,
  });

  // Stream realtime (Quan trọng: Stream trả về Result để UI handle cả lỗi trong lúc stream)
  Stream<Result<FanEntity>> get fanStateStream;
}
