import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyen_app/screens/conference_rooms_tabs.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_theme.dart';
import '../auth/login_screen.dart';
import 'abstract_list_screen.dart';
import 'preconference_list_screen.dart';
import 'workshop_list_screen.dart';
import 'certificates_screen.dart';
import 'profile_screen.dart';

class ParticipantDashboard extends StatefulWidget {
  const ParticipantDashboard({super.key});

  @override
  State<ParticipantDashboard> createState() => _ParticipantDashboardState();
}

class _ParticipantDashboardState extends State<ParticipantDashboard> {
  int _selectedIndex = 0;

  void setSelectedIndex(int index) => setState(() => _selectedIndex = index);

  final _pages = const [
    _HomeTab(),
    AbstractListScreen(),
    PreConferenceListScreen(),
    WorkshopListScreen(),
    CertificatesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VIDYEN'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.article_outlined), label: 'Abstracts'),
          NavigationDestination(
              icon: Icon(Icons.event_note_outlined), label: 'Pre-Conf'),
          NavigationDestination(
              icon: Icon(Icons.build_outlined), label: 'Workshop'),
          NavigationDestination(
              icon: Icon(Icons.card_membership), label: 'Certificates'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.accent],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome, ${user?.name ?? 'Participant'}!',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('VIDYEN International Conference',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),


          //conference rooms section

          const SizedBox(height: 24),
          const Text('Conference Rooms',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark
                  ),
                  ),

          const SizedBox(height: 12),
          const ConferenceRoomsCard(),


          
          const SizedBox(height: 24),
          const Text('Quick Actions',
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
            childAspectRatio: 1.2,
            children: [
              _actionCard(
                  context, 'Abstract\nSubmission', Icons.article_outlined, 1),
              _actionCard(context, 'Pre-Conference\nSubmission',
                  Icons.event_note_outlined, 2),
              _actionCard(
                  context, 'Workshop\nSubmission', Icons.build_outlined, 3),
              _actionCard(
                  context, 'My\nCertificates', Icons.card_membership, 4),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Conference Info',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark)),
          const SizedBox(height: 12),
          _infoCard(
              'Theme', 'Competency Based Dental Education: Beyond the Borders'),
          const SizedBox(height: 8),
          _infoCard('Venue', 'International Dental Conference 2026'),
          const SizedBox(height: 8),
          _infoCard('Registration ID', user?.userId ?? '-'),
        ],
      ),
    );
  }

  Widget _actionCard(
      BuildContext context, String label, IconData icon, int tabIndex) {
    return InkWell(
      onTap: () {
        final dash =
            context.findAncestorStateOfType<_ParticipantDashboardState>();
        dash?.setSelectedIndex(tabIndex);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: AppTheme.primary),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark)),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(title,
                style: const TextStyle(
                    color: AppTheme.textGrey, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 3,
            child: Text(value,
                style: const TextStyle(
                    color: AppTheme.textDark, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
