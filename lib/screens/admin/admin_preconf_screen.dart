import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/conference_provider.dart';
import '../../models/submission_models.dart';
import '../../widgets/app_theme.dart';
import 'admin_preconf_detail_screen.dart';

class AdminPreconfScreen extends StatefulWidget {
  const AdminPreconfScreen({super.key});

  @override
  State<AdminPreconfScreen> createState() => _AdminPreconfScreenState();
}

class _AdminPreconfScreenState extends State<AdminPreconfScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ConferenceProvider>().loadAllPreconferences());
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ConferenceProvider>();
    final all = prov.allPreconferences;
    final error = prov.error;

    final filtered = _search.isEmpty
        ? all
        : all.where((p) {
            final q = _search.toLowerCase();
            return p.preconferenceId.toLowerCase().contains(q) ||
                p.registrationId.toLowerCase().contains(q) ||
                p.paperTitle.toLowerCase().contains(q);
          }).toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search by pre-conf code, reg ID or title...',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _search = ''),
                      )
                    : null,
              ),
            ),
          ),
          if (prov.loading)
            const Expanded(
                child: LoadingWidget(
                    message: 'Loading pre-conference submissions...'))
          else if (error != null)
            Expanded(
                child: ErrorWidget2(
                    message: error,
                    onRetry: () => context
                        .read<ConferenceProvider>()
                        .loadAllPreconferences()))
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    context.read<ConferenceProvider>().loadAllPreconferences(),
                child: filtered.isEmpty
                    ? const Center(
                        child: Text('No pre-conference submissions found',
                            style: TextStyle(color: AppTheme.textGrey)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) =>
                            _PreconfAdminCard(serial: i + 1, preconf: filtered[i]),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PreconfAdminCard extends StatelessWidget {
  final int serial;
  final PreConferenceModel preconf;
  const _PreconfAdminCard({required this.serial, required this.preconf});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AdminPreconfDetailScreen(preconfId: preconf.preconferenceId),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Serial + Pre-conf ID + status chip
              Row(children: [
                _SerialBadge(serial),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(preconf.preconferenceId,
                      style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ),
                _StatusChip(status: preconf.status),
              ]),
              const SizedBox(height: 6),

              // Registration ID
              _IconRow(
                  icon: Icons.badge_outlined,
                  text: 'Reg: ${preconf.registrationId}'),
              const SizedBox(height: 4),

              // Paper title
              Text(preconf.paperTitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),

              // Subtheme
              if (preconf.subthemes.isNotEmpty)
                _IconRow(
                    icon: Icons.category_outlined, text: preconf.subthemes),

              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 6),

              // View button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('View', style: TextStyle(fontSize: 13)),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminPreconfDetailScreen(
                          preconfId: preconf.preconferenceId),
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

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SerialBadge extends StatelessWidget {
  final int serial;
  const _SerialBadge(this.serial);

  @override
  Widget build(BuildContext context) => Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text('$serial',
              style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11)),
        ),
      );
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    String label;
    switch (status) {
      case '2':
        bg = AppTheme.success;
        label = 'Reviewed';
        break;
      case '1':
        bg = AppTheme.warning;
        label = 'Assigned';
        break;
      default:
        bg = AppTheme.danger;
        label = 'Not Assigned';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold)),
    );
  }
}

class _IconRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _IconRow(
      {required this.icon,
      required this.text,
      this.color = AppTheme.textGrey});

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(text,
              style: TextStyle(color: color, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ]);
}

