class FanEntity {
  final bool isOn;
  final int speed;
  final bool isRotating;
  final bool isAuto;
  final double temperature;
  final double humidity;

  const FanEntity({
    required this.isOn,
    required this.speed,
    required this.isRotating,
    required this.isAuto,
    required this.temperature,
    this.humidity = 0.0,
  });
  
  // Helper để copyWith (tiện cho việc update state cục bộ nếu cần)
  FanEntity copyWith({
    bool? isOn, 
    int? speed, 
    bool? isRotating,
    bool? isAuto,
    double? temperature, 
    double? humidity
  }) {
    return FanEntity(
      isOn: isOn ?? this.isOn,
      speed: speed ?? this.speed,
      isRotating: isRotating ?? this.isRotating,
      isAuto: isAuto ?? this.isAuto,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
    );
  }
}
