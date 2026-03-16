import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/conference_provider.dart';
import '../../widgets/app_theme.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ConferenceProvider>().loadMyRegistration());
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final prov = context.watch<ConferenceProvider>();
    final reg = prov.registration;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false);
            },
          ),
        ],
      ),
      body: prov.loading
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      (user?.name ?? 'U').substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(user?.name ?? '',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(user?.email ?? '',
                      style: const TextStyle(color: AppTheme.textGrey)),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(user?.usertype.toUpperCase() ?? '',
                        style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 24),
                  if (reg != null) ...[
                    _sectionTitle('Registration Details'),
                    _infoCard([
                      _row('Reg. Code', reg.registrationCode),
                      _row('Delegate Type', reg.typeOfDelegate),
                      _row('Designation', reg.designation),
                      _row('Institution', reg.institution),
                      _row('City', reg.city),
                      _row('Country', reg.country),
                      _row('Phone', reg.phone),
                      _row('Status', reg.statusLabel),
                    ]),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text(t,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark))),
      );

  Widget _infoCard(List<Widget> rows) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: rows),
        ),
      );

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 120,
                child: Text(label,
                    style: const TextStyle(
                        color: AppTheme.textGrey,
                        fontWeight: FontWeight.w500))),
            Expanded(
                child: Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark))),
          ],
        ),
      );
}
