import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/conference_provider.dart';
import '../../widgets/app_theme.dart';
import '../auth/login_screen.dart';
import 'participants_screen.dart';
import 'admin_abstracts_screen.dart';
import 'admin_messages_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ConferenceProvider>().loadAdminDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _AdminHomeTab(),
      const ParticipantsScreen(),
      const AdminAbstractsScreen(),
      const AdminMessagesScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('VIDYEN Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.people_outline), label: 'Participants'),
          NavigationDestination(
              icon: Icon(Icons.article_outlined), label: 'Abstracts'),
          NavigationDestination(
              icon: Icon(Icons.message_outlined), label: 'Messages'),
        ],
      ),
    );
  }
}

class _AdminHomeTab extends StatelessWidget {
  const _AdminHomeTab();

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ConferenceProvider>();
    final stats = prov.adminStats;
    final user = context.watch<AuthProvider>().user;

    if (prov.loading)
      return const LoadingWidget(message: 'Loading dashboard...');
    if (stats == null)
      return ErrorWidget2(
          message: prov.error ?? 'Failed to load',
          onRetry: () =>
              context.read<ConferenceProvider>().loadAdminDashboard());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.accent]),
              borderRadius: BorderRadius.circular(16),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Welcome, ${user?.name ?? 'Admin'}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Admin Control Panel',
                  style: TextStyle(color: Colors.white70)),
            ]),
          ),
          const SizedBox(height: 24),
          const Text('Overview',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              StatCard(
                  label: 'Total Registrations',
                  value: '${stats['total_registrations'] ?? 0}',
                  icon: Icons.people,
                  color: AppTheme.primary),
              StatCard(
                  label: 'Active Participants',
                  value: '${stats['active_participants'] ?? 0}',
                  icon: Icons.person_outline,
                  color: AppTheme.success),
              StatCard(
                  label: 'Pending Approval',
                  value: '${stats['pending_approval'] ?? 0}',
                  icon: Icons.pending_outlined,
                  color: AppTheme.warning),
              StatCard(
                  label: 'Total Abstracts',
                  value: '${stats['total_abstracts'] ?? 0}',
                  icon: Icons.article_outlined,
                  color: AppTheme.accent),
              StatCard(
                  label: 'Evaluated Abstracts',
                  value: '${stats['evaluated_abstracts'] ?? 0}',
                  icon: Icons.check_circle_outline,
                  color: AppTheme.success),
              StatCard(
                  label: 'Pre-Conference',
                  value: '${stats['total_preconference'] ?? 0}',
                  icon: Icons.event_note_outlined,
                  color: AppTheme.primary),
              StatCard(
                  label: 'Workshops',
                  value: '${stats['total_workshops'] ?? 0}',
                  icon: Icons.build_outlined,
                  color: AppTheme.accent),
            ],
          ),
        ],
      ),
    );
  }
}
