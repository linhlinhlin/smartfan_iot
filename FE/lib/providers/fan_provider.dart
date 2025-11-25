import 'dart:async';
import 'package:flutter/material.dart';
import '../features/smart_fan/domain/repositories/i_fan_repository.dart';
import '../features/smart_fan/domain/entities/fan_entity.dart';
import 'package:holilihu_fan/core/result/result.dart';
import '../models/fan_state.dart';

class FanNotifier extends ChangeNotifier {
  final IFanRepository _repository;
  
  FanState _state = const FanState();
  FanState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Constructor Injection
  FanNotifier({required IFanRepository repository}) : _repository = repository {
    _initStream();
  }

  void _initStream() {
    _repository.fanStateStream.listen((result) {
      switch (result) {
        case Success(data: final entity):
          print('Notifier: Received entity: $entity');
          _updateStateFromEntity(entity);
          _errorMessage = null;
          break;
        case Failure(message: final msg):
          _errorMessage = msg;
          debugPrint('FanNotifier Error: $msg');
          break;
      }
      notifyListeners();
    });
  }

  void _updateStateFromEntity(FanEntity entity) {
    _state = _state.copyWith(
      power: entity.isOn ? 1 : 0,
      mode: entity.speed,
      rotate: entity.isRotating ? 1 : 0,
      auto: entity.isAuto ? 1 : 0,
      temperature: entity.temperature,
      humidity: entity.humidity.toInt(),
      lastSeenMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> sendCommand(String type, int value) async {
    // Optimistic Update: Cập nhật UI ngay lập tức
    final previousState = _state;
    
    switch (type) {
      case 'power':
        _state = _state.copyWith(power: value);
        break;
      case 'mode':
        _state = _state.copyWith(mode: value);
        break;
      case 'rotate':
        _state = _state.copyWith(rotate: value);
        break;
      case 'auto':
        _state = _state.copyWith(auto: value);
        break;
    }
    notifyListeners();

    Result<void> result;

    switch (type) {
      case 'power':
        result = await _repository.sendCommand(isOn: value == 1);
        break;
      case 'mode':
        result = await _repository.sendCommand(speed: value);
        break;
      case 'rotate':
        result = await _repository.sendCommand(isRotating: value == 1);
        break;
      case 'auto':
        result = await _repository.sendCommand(isAuto: value == 1);
        break;
      default:
        result = const Failure('Unknown command type');
    }

    if (result is Failure) {
      // Rollback nếu lỗi
      _state = previousState;
      _errorMessage = (result as Failure).message;
      debugPrint('Command Error: $_errorMessage');
      notifyListeners();
    }
  }
}