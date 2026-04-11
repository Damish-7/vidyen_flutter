import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/conference_provider.dart';
import '../../widgets/app_theme.dart';

const _certTypeLabels = <String, String>{
  'preconference_item_analysis': 'Pre-Conference Item Analysis',
  'mindful_map': 'Pre-Conference Workshop - Mindful Map',
  'sage': 'Pre-Conference SAGE',
  'itlm': 'Pre-Conference Interactive Teaching Learning Methods',
  'workshop_bridging': 'Workshop Course - Bridging Mind Building Care',
  'workshop_proms_prems':
      'Enhancing Health Care Using PROMs, PREMs, and Experiences in Dentistry',
  'workshop_microteaching': 'Microteaching Workshop',
  'first_place_paper': '1st Place Paper Award',
  'second_place_paper': '2nd Place Paper Award',
  'first_place_poster': '1st Place Poster Award',
  'second_place_poster': '2nd Place Poster Award',
  'first_place_yenvision': '1st Place YenVision Award',
  'second_place_yenvision': '2nd Place YenVision Award',
};

class AdminViewCertsScreen extends StatefulWidget {
  const AdminViewCertsScreen({super.key});

  @override
  State<AdminViewCertsScreen> createState() => _AdminViewCertsScreenState();
}

class _AdminViewCertsScreenState extends State<AdminViewCertsScreen> {
  String _search = '';
  String? _filterType; // null = all

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ConferenceProvider>().loadAllGeneratedCerts());
  }

  List<Map<String, dynamic>> _filtered(List<Map<String, dynamic>> all) {
    return all.where((c) {
      // type filter
      if (_filterType != null &&
          c['certificate_type']?.toString() != _filterType) return false;
      // search filter
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        final code = (c['registration_code'] ?? '').toString().toLowerCase();
        final name = (c['full_name'] ?? '').toString().toLowerCase();
        final email = (c['email'] ?? '').toString().toLowerCase();
        if (!code.contains(q) && !name.contains(q) && !email.contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ConferenceProvider>();
    final all = prov.allGeneratedCerts;
    final filtered = _filtered(all);

    return Scaffold(
      body: Column(
        children: [
          _buildFilters(all),
          if (prov.loading && all.isEmpty)
            const Expanded(
                child: LoadingWidget(message: 'Loading certificates...'))
          else if (prov.error != null && all.isEmpty)
            Expanded(
                child: ErrorWidget2(
                    message: prov.error!,
                    onRetry: () =>
                        context.read<ConferenceProvider>().loadAllGeneratedCerts()))
          else ...[
            _buildStatsRow(all),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    context.read<ConferenceProvider>().loadAllGeneratedCerts(),
                child: filtered.isEmpty
                    ? ListView(
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(top: 64),
                            child: Center(
                              child: Text('No certificates found',
                                  style: TextStyle(color: AppTheme.textGrey)),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _CertCard(
                          serial: i + 1,
                          cert: filtered[i],
                          onRevoke: () => _confirmRevoke(context, filtered[i]),
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilters(List<Map<String, dynamic>> all) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        children: [
          // Type filter dropdown
          DropdownButtonFormField<String>(
            value: _filterType,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Filter by Certificate Type',
              isDense: true,
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Types')),
              ..._certTypeLabels.entries.map((e) => DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis),
                  )),
            ],
            onChanged: (v) => setState(() => _filterType = v),
          ),
          const SizedBox(height: 8),
          // Search bar
          TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Search by name, email or registration code...',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => setState(() => _search = ''),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 6),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildStatsRow(List<Map<String, dynamic>> all) {
    // Count per type
    final counts = <String, int>{};
    for (final c in all) {
      final t = c['certificate_type']?.toString() ?? 'unknown';
      counts[t] = (counts[t] ?? 0) + 1;
    }

    return Container(
      color: AppTheme.primary.withOpacity(0.04),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _StatChip(label: 'Total', value: all.length, color: AppTheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: counts.entries.map((e) {
                  final label = _certTypeLabels[e.key] ?? e.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _StatChip(
                        label: _shortLabel(label),
                        value: e.value,
                        color: AppTheme.accent),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _shortLabel(String label) {
    const limit = 18;
    return label.length > limit ? '${label.substring(0, limit)}…' : label;
  }

  Future<void> _confirmRevoke(
      BuildContext context, Map<String, dynamic> cert) async {
    final name =
        '${cert['honorofic'] ?? ''} ${cert['full_name'] ?? ''}'.trim();
    final type = _certTypeLabels[cert['certificate_type']?.toString()] ??
        cert['certificate_type']?.toString() ??
        '';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Revoke Certificate'),
        content: Text(
            'Revoke "$type" certificate for $name?\n\nThe participant will no longer be able to download it.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final ok = await context
        .read<ConferenceProvider>()
        .revokeCertificate(cert['id']?.toString() ?? '');

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Certificate revoked' : 'Failed to revoke'),
      backgroundColor: ok ? AppTheme.success : AppTheme.danger,
    ));
    if (ok) context.read<ConferenceProvider>().loadAllGeneratedCerts();
  }
}

class _CertCard extends StatelessWidget {
  final int serial;
  final Map<String, dynamic> cert;
  final VoidCallback onRevoke;

  const _CertCard(
      {required this.serial, required this.cert, required this.onRevoke});

  String _val(String key) => cert[key]?.toString() ?? '-';

  String get _fullName {
    final title = cert['honorofic']?.toString() ?? '';
    final name = cert['full_name']?.toString() ?? '';
    return '$title $name'.trim().isEmpty ? '-' : '$title $name'.trim();
  }

  String get _typeLabel =>
      _certTypeLabels[cert['certificate_type']?.toString()] ??
      cert['certificate_type']?.toString() ??
      '-';

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Serial
              Container(
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
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Reg code + name
                      Row(children: [
                        Text(_val('registration_code'),
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_fullName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                      const SizedBox(height: 2),
                      // Email
                      Text(_val('email'),
                          style: const TextStyle(
                              color: AppTheme.textGrey, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Certificate type badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _typeLabel,
              style: const TextStyle(
                  color: AppTheme.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 12, color: AppTheme.textGrey),
              const SizedBox(width: 4),
              Text(
                _val('generated_on'),
                style:
                    const TextStyle(color: AppTheme.textGrey, fontSize: 11),
              ),
              const Spacer(),
              TextButton.icon(
                style: TextButton.styleFrom(
                    foregroundColor: AppTheme.danger,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                icon: const Icon(Icons.delete_outline, size: 15),
                label: const Text('Revoke',
                    style: TextStyle(fontSize: 12)),
                onPressed: onRevoke,
              ),
            ],
          ),
        ]),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(10)),
          child: Text('$value',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }
}
