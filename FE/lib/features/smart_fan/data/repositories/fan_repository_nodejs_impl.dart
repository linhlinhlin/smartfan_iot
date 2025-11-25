import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:holilihu_fan/core/result/result.dart';
import '../../domain/entities/fan_entity.dart';
import '../../domain/repositories/i_fan_repository.dart';
import '../models/fan_model.dart';

class NodeJsFanRepositoryImpl implements IFanRepository {
  final String baseUrl; // e.g., 'http://192.168.1.x:3000/api'
  final String socketUrl; // e.g., 'http://192.168.1.x:3000'
  final String deviceId;

  late IO.Socket _socket;
  final _streamController = StreamController<Result<FanEntity>>.broadcast();

  NodeJsFanRepositoryImpl({
    required this.baseUrl,
    required this.socketUrl,
    this.deviceId = 'quat_thong_minh_2',
  }) {
    _initSocket();
  }

  void _initSocket() {
    _socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket.onConnect((_) {
      print('Socket connected');
      _socket.emit('join_device', deviceId);
    });

    _socket.on('device_update', (data) {
      print('Repository: Received data from socket: $data');
      try {
        if (data != null) {
          final entity = FanModel.fromJson(Map<String, dynamic>.from(data));
          _streamController.add(Success(entity));
        }
      } catch (e) {
        print('Repository Parse Error: $e');
        _streamController.add(Failure('Parse Error: $e'));
      }
    });

    _socket.onDisconnect((_) => print('Socket disconnected'));
    
    _socket.onError((e) => _streamController.add(Failure('Socket Error: $e')));
  }

  @override
  Stream<Result<FanEntity>> get fanStateStream => _streamController.stream;

  @override
  Future<Result<void>> sendCommand({
    bool? isOn,
    int? speed,
    bool? isRotating,
    bool? isAuto,
  }) async {
    try {
      // Helper to send individual command
      Future<void> send(String command, dynamic value) async {
        final response = await http.post(
          Uri.parse('$baseUrl/devices/$deviceId/command'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'command': command,
            'value': value,
          }),
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to send command: ${response.body}');
        }
      }

      if (isOn != null) await send('POWER', isOn ? 1 : 0);
      if (speed != null) await send('MODE', speed);
      if (isRotating != null) await send('ROTATION', isRotating ? 1 : 0);
      if (isAuto != null) await send('AUTO', isAuto ? 1 : 0);

      return const Success(null);
    } catch (e) {
      return Failure('API Error: $e');
    }
  }

  @override
  Future<Result<FanEntity>> getFanState() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/devices/$deviceId/state'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final entity = FanModel.fromJson(data);
        return Success(entity);
      } else {
        return Failure('Failed to fetch state: ${response.statusCode}');
      }
    } catch (e) {
      return Failure('Network Error: $e');
    }
  }

  void dispose() {
    _socket.dispose();
    _streamController.close();
  }
}
