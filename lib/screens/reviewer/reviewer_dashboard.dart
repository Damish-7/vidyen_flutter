import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/conference_provider.dart';
import '../../widgets/app_theme.dart';
import '../auth/login_screen.dart';
import 'reviewer_abstracts_screen.dart';

class ReviewerDashboard extends StatefulWidget {
  const ReviewerDashboard({super.key});

  @override
  State<ReviewerDashboard> createState() => _ReviewerDashboardState();
}

class _ReviewerDashboardState extends State<ReviewerDashboard> {
  int _selectedIndex = 0;

  static const _navItems = [
    _NavItem(Icons.dashboard_outlined, 'Dashboard'),
    _NavItem(Icons.article_outlined, 'Abstracts'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ConferenceProvider>().loadReviewerDashboard());
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 1:
        return const ReviewerAbstractsScreen();
      default:
        return _ReviewerHomeBody(onGoToAbstracts: () {
          setState(() => _selectedIndex = 1);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final title = _navItems[_selectedIndex].label;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: _ReviewerDrawer(
        selectedIndex: _selectedIndex,
        navItems: _navItems,
        user: user,
        onSelect: (i) {
          setState(() => _selectedIndex = i);
          Navigator.pop(context);
        },
      ),
      body: _buildPage(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.article_outlined), label: 'Abstracts'),
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

class _ReviewerDrawer extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> navItems;
  final dynamic user;
  final ValueChanged<int> onSelect;

  const _ReviewerDrawer({
    required this.selectedIndex,
    required this.navItems,
    required this.user,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
                    child: Icon(Icons.rate_review, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?.name ?? 'Reviewer',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: navItems.length,
              itemBuilder: (_, i) {
                final item = navItems[i];
                final selected = i == selectedIndex;
                return ListTile(
                  leading: Icon(item.icon,
                      color: selected ? AppTheme.primary : AppTheme.textGrey),
                  title: Text(item.label,
                      style: TextStyle(
                          color: selected ? AppTheme.primary : AppTheme.textDark,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal)),
                  selected: selected,
                  selectedTileColor: AppTheme.primary.withOpacity(0.08),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  onTap: () => onSelect(i),
                );
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.danger),
            title: const Text('Logout', style: TextStyle(color: AppTheme.danger)),
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

class _ReviewerHomeBody extends StatelessWidget {
  final VoidCallback onGoToAbstracts;

  const _ReviewerHomeBody({required this.onGoToAbstracts});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ConferenceProvider>();
    final stats = prov.reviewerStats;
    final user = context.watch<AuthProvider>().user;

    if (prov.loading) return const LoadingWidget(message: 'Loading dashboard...');
    if (stats == null) {
      return ErrorWidget2(
        message: prov.error ?? 'Failed to load dashboard',
        onRetry: () => context.read<ConferenceProvider>().loadReviewerDashboard(),
      );
    }

    final reviewType = stats['review_type'] as String? ?? '';
    final total    = '${stats['total']    ?? 0}';
    final pending  = '${stats['pending']  ?? 0}';
    final reviewed = '${stats['reviewed'] ?? 0}';

    String itemLabel;
    if (reviewType.contains('PreConference') || reviewType.contains('Pre-Conference')) {
      itemLabel = 'Pre-Conference';
    } else if (reviewType.contains('Workshop')) {
      itemLabel = 'Workshop';
    } else {
      itemLabel = 'Abstract';
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ConferenceProvider>().loadReviewerDashboard(),
      child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
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
                Text(
                  'Welcome, ${user?.name ?? 'Reviewer'}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  reviewType.isNotEmpty ? reviewType : 'Reviewer Panel',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Overview',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark),
          ),
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
                label: 'Total $itemLabel',
                value: total,
                icon: Icons.assignment_outlined,
                color: AppTheme.primary,
              ),
              StatCard(
                label: 'Pending $itemLabel',
                value: pending,
                icon: Icons.pending_outlined,
                color: AppTheme.warning,
              ),
              StatCard(
                label: 'Reviewed $itemLabel',
                value: reviewed,
                icon: Icons.check_circle_outline,
                color: AppTheme.success,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.article_outlined),
              label: const Text('View Assigned Abstracts'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: onGoToAbstracts,
            ),
          ),
        ],
      ),
    ),
    );
  }
}

