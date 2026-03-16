import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/conference_provider.dart';
import '../../models/abstract_model.dart';
import '../../widgets/app_theme.dart';
import '../auth/login_screen.dart';

class ReviewerDashboard extends StatefulWidget {
  const ReviewerDashboard({super.key});

  @override
  State<ReviewerDashboard> createState() => _ReviewerDashboardState();
}

class _ReviewerDashboardState extends State<ReviewerDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ConferenceProvider>().loadAllAbstracts());
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final prov = context.watch<ConferenceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('VIDYEN Reviewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppTheme.primary.withValues(alpha: 0.08),
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Hello, ${user?.name ?? 'Reviewer'}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              const Text('Review assigned abstracts below.',
                  style: TextStyle(color: AppTheme.textGrey)),
            ]),
          ),
          Expanded(
            child: prov.loading
                ? const LoadingWidget(message: 'Loading abstracts...')
                : prov.error != null
                    ? ErrorWidget2(
                        message: prov.error!,
                        onRetry: () => context
                            .read<ConferenceProvider>()
                            .loadAllAbstracts())
                    : prov.allAbstracts.isEmpty
                        ? const Center(
                            child: Text('No abstracts assigned',
                                style: TextStyle(color: AppTheme.textGrey)))
                        : RefreshIndicator(
                            onRefresh: () => context
                                .read<ConferenceProvider>()
                                .loadAllAbstracts(),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: prov.allAbstracts.length,
                              itemBuilder: (_, i) => _ReviewAbstractCard(
                                  abstract: prov.allAbstracts[i]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _ReviewAbstractCard extends StatelessWidget {
  final AbstractModel abstract;
  const _ReviewAbstractCard({required this.abstract});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text(abstract.abstractId,
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13))),
            StatusBadge(status: abstract.statusLabel),
          ]),
          const SizedBox(height: 6),
          Text(abstract.paperTitle,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(abstract.subTheme,
              style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          Row(children: [
            _btn(context, 'Approve', AppTheme.success, '2'),
            const SizedBox(width: 8),
            _btn(context, 'Request Revision', AppTheme.warning, '1'),
          ]),
        ]),
      ),
    );
  }

  Widget _btn(BuildContext ctx, String label, Color color, String status) =>
      OutlinedButton(
        style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
        onPressed: () async {
          await ctx
              .read<ConferenceProvider>()
              .updateAbstractStatus(abstract.abstractId, status);
          if (ctx.mounted) {
            ctx.read<ConferenceProvider>().loadAllAbstracts();
          }
        },
        child: Text(label, style: const TextStyle(fontSize: 12)),
      );
}
