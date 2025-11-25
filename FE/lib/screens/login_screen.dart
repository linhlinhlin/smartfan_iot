import 'package:flutter/material.dart';
import '../theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool loading = false;
  String? err;

  Future<void> _loginEmail() async {
    setState(() { loading = true; err = null; });
    try {
      // TODO: Firebase auth
      await Future.delayed(const Duration(seconds: 1)); // Simulate
    } catch (e) {
      err = e.toString();
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> _loginAnon() async {
    setState(() { loading = true; err = null; });
    try {
      // TODO: Firebase anonymous auth
      await Future.delayed(const Duration(seconds: 1)); // Simulate
    } catch (e) {
      err = e.toString();
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.cosmicMist,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.ac_unit,
                  size: 40,
                  color: AppTheme.iceBlueAccent,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Chào mừng',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.graphite700,
                    ),
              ),
              const SizedBox(height: 32),
              // Anonymous login button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: loading ? null : _loginAnon,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.iceBlueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.chipRadius),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Đăng nhập ẩn danh'),
                ),
              ),
              const SizedBox(height: 16),
              // Separator
              Row(
                children: [
                  Expanded(child: Divider(color: AppTheme.graphite500.withOpacity(0.3))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'hoặc',
                      style: TextStyle(color: AppTheme.graphite500),
                    ),
                  ),
                  Expanded(child: Divider(color: AppTheme.graphite500.withOpacity(0.3))),
                ],
              ),
              const SizedBox(height: 16),
              // Email field
              TextField(
                controller: email,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.chipRadius),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Password field
              TextField(
                controller: pass,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.chipRadius),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Email login button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: loading ? null : _loginEmail,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.iceBlueAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.chipRadius),
                    ),
                  ),
                  child: const Text('Đăng nhập'),
                ),
              ),
              if (err != null) ...[
                const SizedBox(height: 16),
                Text(
                  err!,
                  style: const TextStyle(color: AppTheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              // Footer
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: AppTheme.graphite500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}