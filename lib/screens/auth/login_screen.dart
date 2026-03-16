import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_theme.dart';
import '../participant/participant_dashboard.dart';
import '../admin/admin_dashboard.dart';
import '../reviewer/reviewer_dashboard.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success =
        await auth.login(_usernameCtrl.text.trim(), _passwordCtrl.text.trim());

    if (!mounted) return;

    if (success) {
      final user = auth.user!;
      Widget dest;
      if (user.isAdmin)
        dest = const AdminDashboard();
      else if (user.isReviewer)
        dest = const ReviewerDashboard();
      else
        dest = const ParticipantDashboard();

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => dest));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Login failed'),
          backgroundColor: AppTheme.danger,
        ),
      );
      print('Login failed: ${auth.error}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().loading;

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo / Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.medical_services_rounded,
                    size: 64, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text('VIDYEN',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3)),
              const SizedBox(height: 6),
              Text('Conference Portal',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 15)),
              const SizedBox(height: 40),
              // Card
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Sign In',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark)),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _usernameCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email / Username',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Enter your email'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Enter your password'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: AppTheme.primary))
                            : ElevatedButton(
                                onPressed: _login,
                                child: const Text('SIGN IN'),
                              ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          ),
                          child: const Text(
                            "Don't have an account? Register",
                            style: TextStyle(color: AppTheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
