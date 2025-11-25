import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/dashboard_screen.dart';
import 'providers/fan_provider.dart';
import 'features/smart_fan/data/repositories/fan_repository_nodejs_impl.dart';

void main() {
  runApp(const SmartFanApp());
}

class SmartFanApp extends StatelessWidget {
  const SmartFanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FanNotifier(
            // Sử dụng Backend trên Cloud (Render)
            repository: NodeJsFanRepositoryImpl(
              baseUrl: 'https://smartfan-iot.onrender.com/api',
              socketUrl: 'https://smartfan-iot.onrender.com',
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
