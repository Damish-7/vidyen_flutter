import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/conference_provider.dart';
import '../../models/registration_model.dart';
import '../../widgets/app_theme.dart';

// ── Certificate type definitions ─────────────────────────────────────────────

const _certTypes = [
  _CertType('preconference_item_analysis', 'Pre-Conference Item Analysis'),
  _CertType('mindful_map', 'Pre-Conference Workshop - Mindful Map'),
  _CertType('sage', 'Pre-Conference SAGE'),
  _CertType('itlm', 'Pre-Conference Interactive Teaching Learning Methods'),
  _CertType('workshop_bridging',
      'Workshop Course - Bridging Mind Building Care'),
  _CertType('workshop_proms_prems',
      'Enhancing Health Care Using PROMs, PREMs, and Experiences in Dentistry'),
  _CertType('workshop_microteaching', 'Microteaching Workshop'),
  _CertType('first_place_paper', '1st Place Paper Award'),
  _CertType('second_place_paper', '2nd Place Paper Award'),
  _CertType('first_place_poster', '1st Place Poster Award'),
  _CertType('second_place_poster', '2nd Place Poster Award'),
  _CertType('first_place_yenvision', '1st Place YenVision Award'),
  _CertType('second_place_yenvision', '2nd Place YenVision Award'),
];

class _CertType {
  final String value;
  final String label;
  const _CertType(this.value, this.label);
}

// ── Screen ────────────────────────────────────────────────────────────────────

class AdminGenerateCertsScreen extends StatefulWidget {
  const AdminGenerateCertsScreen({super.key});

  @override
  State<AdminGenerateCertsScreen> createState() =>
      _AdminGenerateCertsScreenState();
}

class _AdminGenerateCertsScreenState extends State<AdminGenerateCertsScreen> {
  String? _selectedType;
  String _search = '';
  final Set<String> _selected = {};
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConferenceProvider>().loadAllRegistrations();
      context.read<ConferenceProvider>().loadAllGeneratedCerts();
    });
  }

  List<RegistrationModel> _filtered(List<RegistrationModel> all) {
    if (_search.isEmpty) return all;
    final q = _search.toLowerCase();
    return all
        .where((r) =>
            r.registrationCode.toLowerCase().contains(q) ||
            r.fullName.toLowerCase().contains(q) ||
            r.email.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _generate() async {
    if (_selectedType == null || _selected.isEmpty) return;

    final certLabel = _certTypes
        .firstWhere((c) => c.value == _selectedType)
        .label;
    final count = _selected.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Generation'),
        content: Text(
            'Generate "$certLabel" certificate for $count participant(s)?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Generate')),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _generating = true);

    final ok = await context.read<ConferenceProvider>().generateCertificates(
          _selectedType!,
          _selected.toList(),
        );

    if (!mounted) return;
    setState(() => _generating = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Certificates generated for $count participant(s)'
            : context.read<ConferenceProvider>().error ?? 'Generation failed'),
        backgroundColor: ok ? AppTheme.success : AppTheme.danger,
      ),
    );

    if (ok) setState(() => _selected.clear());
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ConferenceProvider>();
    final all = prov.allRegistrations;
    final filtered = _filtered(all);
    final canGenerate =
        _selectedType != null && _selected.isNotEmpty && !_generating;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(filtered.length, all.length),
          if (prov.loading && all.isEmpty)
            const Expanded(
                child: LoadingWidget(message: 'Loading participants...'))
          else if (prov.error != null && all.isEmpty)
            Expanded(
                child: ErrorWidget2(
                    message: prov.error!,
                    onRetry: () =>
                        context.read<ConferenceProvider>().loadAllRegistrations()))
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    context.read<ConferenceProvider>().loadAllRegistrations(),
                child: _ParticipantTable(
                  rows: filtered,
                  selected: _selected,
                  certType: _selectedType,
                  onToggle: (code) {
                    setState(() {
                      _selected.contains(code)
                          ? _selected.remove(code)
                          : _selected.add(code);
                    });
                  },
                ),
              ),
            ),
          _buildFooter(canGenerate),
        ],
      ),
    );
  }

  Widget _buildHeader(int visible, int total) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Certificate type dropdown
          DropdownButtonFormField<String>(
            value: _selectedType,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Select Certificate Type',
              isDense: true,
            ),
            items: _certTypes
                .map((c) => DropdownMenuItem(
                    value: c.value,
                    child: Text(c.label,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (v) => setState(() => _selectedType = v),
          ),
          const SizedBox(height: 10),
          // Search bar
          TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Search by code, name or email...',
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
          const SizedBox(height: 8),
          // Select all / deselect / count row
          Row(
            children: [
              _SmallButton(
                label: 'Select All',
                onTap: () => setState(() {
                  _selected.addAll(context
                      .read<ConferenceProvider>()
                      .allRegistrations
                      .map((r) => r.registrationCode));
                }),
              ),
              const SizedBox(width: 8),
              _SmallButton(
                label: 'Select Visible',
                onTap: () => setState(() {
                  final filtered = _filtered(
                      context.read<ConferenceProvider>().allRegistrations);
                  _selected.addAll(filtered.map((r) => r.registrationCode));
                }),
              ),
              const SizedBox(width: 8),
              _SmallButton(
                label: 'Deselect All',
                onTap: () => setState(() => _selected.clear()),
              ),
              const Spacer(),
              Text(
                '${_selected.length} selected  •  $visible/$total shown',
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textGrey),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildFooter(bool canGenerate) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                canGenerate ? AppTheme.primary : AppTheme.textGrey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          icon: _generating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.workspace_premium_outlined),
          label: Text(_generating
              ? 'Generating...'
              : 'Generate Certificates (${_selected.length})'),
          onPressed: canGenerate ? _generate : null,
        ),
      ),
    );
  }
}

// ── Participant table ─────────────────────────────────────────────────────────

class _ParticipantTable extends StatelessWidget {
  final List<RegistrationModel> rows;
  final Set<String> selected;
  final String? certType;
  final ValueChanged<String> onToggle;

  const _ParticipantTable({
    required this.rows,
    required this.selected,
    required this.certType,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const Center(
          child: Text('No participants found',
              style: TextStyle(color: AppTheme.textGrey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      itemCount: rows.length,
      itemBuilder: (_, i) {
        final r = rows[i];
        final isSelected = selected.contains(r.registrationCode);
        return _ParticipantTile(
          serial: i + 1,
          reg: r,
          isSelected: isSelected,
          certType: certType,
          onToggle: () => onToggle(r.registrationCode),
        );
      },
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  final int serial;
  final RegistrationModel reg;
  final bool isSelected;
  final String? certType;
  final VoidCallback onToggle;

  const _ParticipantTile({
    required this.serial,
    required this.reg,
    required this.isSelected,
    required this.certType,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      color: isSelected
          ? AppTheme.primary.withOpacity(0.06)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                activeColor: AppTheme.primary,
                onChanged: (_) => onToggle(),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          reg.registrationCode,
                          style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${reg.title} ${reg.fullName}'.trim(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reg.email,
                      style: const TextStyle(
                          color: AppTheme.textGrey, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (certType != null) ...[
                const SizedBox(width: 8),
                _CertStatusBadge(
                    regCode: reg.registrationCode, certType: certType!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Checks if a cert was already generated for this participant, using the
/// allGeneratedCerts already loaded in the provider.
class _CertStatusBadge extends StatelessWidget {
  final String regCode;
  final String certType;

  const _CertStatusBadge(
      {required this.regCode, required this.certType});

  @override
  Widget build(BuildContext context) {
    final certs = context.watch<ConferenceProvider>().allGeneratedCerts;
    // Check if we have entries loaded; if list is empty treat as unknown
    if (certs.isEmpty) return const SizedBox.shrink();

    final match = certs.cast<Map<String, dynamic>?>().firstWhere(
      (c) =>
          c!['registration_code']?.toString() == regCode &&
          c['certificate_type']?.toString() == certType,
      orElse: () => null,
    );
    final already = match != null;
    final date = already ? (match['generated_date']?.toString() ?? '') : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: already
            ? AppTheme.success.withOpacity(0.12)
            : AppTheme.warning.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        already
            ? (date.isNotEmpty ? 'Generated on $date' : 'Generated')
            : 'Pending',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: already ? AppTheme.success : AppTheme.warning,
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SmallButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SmallButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primary,
        side: const BorderSide(color: AppTheme.primary),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(fontSize: 12),
      ),
      onPressed: onTap,
      child: Text(label),
    );
  }
}
