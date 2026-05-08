import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/conference_provider.dart';
import '../../widgets/app_theme.dart';
import '../auth/login_screen.dart';
import 'participants_screen.dart';
import 'admin_abstracts_screen.dart';
import 'admin_preconf_screen.dart';
import 'admin_workshop_screen.dart';
import 'admin_messages_screen.dart';
import 'admin_reviewers_screen.dart';
import 'admin_conference_rooms_screen.dart';
import 'admin_generate_certs_screen.dart';
import 'admin_view_certs_screen.dart';
import '../conference_rooms_tabs.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  static const _navItems = [
    _NavItem(Icons.dashboard_outlined, 'Dashboard'),
    _NavItem(Icons.people_outline, 'Participants'),
    _NavItem(Icons.article_outlined, 'Abstracts'),
    _NavItem(Icons.event_note_outlined, 'Pre-Conference'),
    _NavItem(Icons.workspaces_outlined, 'Workshop'),
    _NavItem(Icons.rate_review_outlined, 'Reviewers'),
    _NavItem(Icons.meeting_room_outlined, 'Conference Rooms'),
    _NavItem(Icons.message_outlined, 'Messages'),
    _NavItem(Icons.workspace_premium_outlined, 'Generate Certificates'),
    _NavItem(Icons.list_alt_outlined, 'View Generated List'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ConferenceProvider>().loadAdminDashboard());
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 1:
        return const ParticipantsScreen();
      case 2:
        return const AdminAbstractsScreen();
      case 3:
        return const AdminPreconfScreen();
      case 4:
        return const AdminWorkshopScreen();
      case 5:
        return const AdminReviewersScreen();
      case 6:
        return const AdminConferenceRoomsScreen();
      case 7:
        return const AdminMessagesScreen();
      case 8:
        return const AdminGenerateCertsScreen();
      case 9:
        return const AdminViewCertsScreen();
      default:
        return const _AdminHomeTab();
    }
  }

  // Indices in _navItems that appear in the bottom nav bar
  static const _bottomNavIndices = [0, 2, 3, 4];

  @override
  Widget build(BuildContext context) {
    final title = _navItems[_selectedIndex].label;
    // Bottom nav selected index = position within _bottomNavIndices (-1 if not in bottom nav)
    final bottomIndex = _bottomNavIndices.indexOf(_selectedIndex);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: _AdminDrawer(
        selectedIndex: _selectedIndex,
        navItems: _navItems,
        onSelect: (i) {
          setState(() => _selectedIndex = i);
          Navigator.pop(context);
        },
      ),
      body: _buildPage(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: bottomIndex < 0 ? 0 : bottomIndex,
        onDestinationSelected: (i) =>
            setState(() => _selectedIndex = _bottomNavIndices[i]),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.article_outlined), label: 'Abstracts'),
          NavigationDestination(
              icon: Icon(Icons.event_note_outlined), label: 'Pre-Conf'),
          NavigationDestination(
              icon: Icon(Icons.workspaces_outlined), label: 'Workshop'),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

class _AdminDrawer extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> navItems;
  final ValueChanged<int> onSelect;

  const _AdminDrawer({
    required this.selectedIndex,
    required this.navItems,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.admin_panel_settings,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 10),
                  Text(user?.name ?? 'Admin',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  Text(user?.email ?? '',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (int i = 0; i < navItems.length; i++) ...[
                  // Insert "Certificates" section header before index 8
                  if (i == 8)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Row(children: [
                        const Icon(Icons.workspace_premium_outlined,
                            size: 15, color: AppTheme.textGrey),
                        const SizedBox(width: 6),
                        const Text('Certificates',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textGrey,
                                letterSpacing: 0.8)),
                        const Expanded(child: Divider(indent: 8)),
                      ]),
                    ),
                  Builder(builder: (_) {
                    final item = navItems[i];
                    final selected = i == selectedIndex;
                    // sub-items are indented
                    final isSubItem = i >= 8;
                    return ListTile(
                      leading: Icon(item.icon,
                          size: isSubItem ? 20 : 22,
                          color:
                              selected ? AppTheme.primary : AppTheme.textGrey),
                      title: Text(item.label,
                          style: TextStyle(
                              fontSize: isSubItem ? 13 : 14,
                              color: selected
                                  ? AppTheme.primary
                                  : AppTheme.textDark,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                      selected: selected,
                      selectedTileColor: AppTheme.primary.withOpacity(0.08),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: isSubItem ? 28 : 16, vertical: 2),
                      onTap: () => onSelect(i),
                    );
                  }),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.danger),
            title:
                const Text('Logout', style: TextStyle(color: AppTheme.danger)),
            onTap: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
          const SizedBox(height: 8),
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
          const Text('Conference Rooms',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark)),
          const SizedBox(height: 12),
          const ConferenceRoomsTabs(),
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
