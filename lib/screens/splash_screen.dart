import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_theme.dart';
import 'auth/login_screen.dart';
import 'participant/participant_dashboard.dart';
import 'admin/admin_dashboard.dart';
import 'reviewer/reviewer_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    await auth.tryRestoreSession();

    if (!mounted) return;

    Widget dest;
    if (!auth.isLoggedIn) {
      dest = const LoginScreen();
    } else {
      final user = auth.user!;
      if (user.isAdmin)
        dest = const AdminDashboard();
      else if (user.isReviewer)
        dest = const ReviewerDashboard();
      else
        dest = const ParticipantDashboard();
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => dest));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.medical_services_rounded,
                  size: 80, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text('VIDYEN',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4)),
            const SizedBox(height: 8),
            Text('Conference Management',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8), fontSize: 16)),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}
