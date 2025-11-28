import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/dashboard_screen.dart';
import 'providers/fan_provider.dart';
import 'features/smart_fan/data/repositories/fan_repository_nodejs_impl.dart';

// Toggle này để switch giữa local và cloud backend
const bool useLocalBackend = true; // Đổi thành false để dùng cloud

void main() {
  runApp(const SmartFanApp());
}

class SmartFanApp extends StatelessWidget {
  const SmartFanApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Local: http://localhost:3000 (web/desktop) hoặc http://10.0.2.2:3000 (Android emulator)
    // Cloud: https://smartfan-iot.onrender.com
    final baseUrl = useLocalBackend 
        ? 'http://localhost:3000/api'  // Dùng localhost cho web/desktop
        : 'https://smartfan-iot.onrender.com/api';
    final socketUrl = useLocalBackend 
        ? 'http://localhost:3000'
        : 'https://smartfan-iot.onrender.com';

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FanNotifier(
            repository: NodeJsFanRepositoryImpl(
              baseUrl: baseUrl,
              socketUrl: socketUrl,
            ),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Smart Fan',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFFF5F6FA),
          useMaterial3: true,
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
