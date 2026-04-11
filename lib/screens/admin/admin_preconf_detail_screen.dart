import 'package:flutter/material.dart';
import '../../services/conference_service.dart';
import '../../widgets/app_theme.dart';

class AdminPreconfDetailScreen extends StatefulWidget {
  final String preconfId;
  const AdminPreconfDetailScreen({super.key, required this.preconfId});

  @override
  State<AdminPreconfDetailScreen> createState() =>
      _AdminPreconfDetailScreenState();
}

class _AdminPreconfDetailScreenState extends State<AdminPreconfDetailScreen> {
  final ConferenceService _service = ConferenceService();

  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _preconf;
  List<dynamic> _authors = [];
  List<Map<String, dynamic>> _reviewers = [];
  bool _assigning = false;

  @override
  void initState() {
    super.initState();
    _load();
    _loadReviewers();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.getPreConfFull(widget.preconfId);
      setState(() {
        _preconf = data['preconference'] as Map<String, dynamic>?;
        _authors = data['authors'] as List<dynamic>? ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _loadReviewers() async {
    try {
      final all = await _service.adminGetReviewers();
      setState(() {
        _reviewers = all
            .where((r) =>
                (r['review_type'] ?? '').toString().toLowerCase().contains('preconference') ||
                (r['review_type'] ?? '').toString().toLowerCase().contains('pre-conference') ||
                (r['review_type'] ?? '').toString().toLowerCase().contains('pre conference'))
            .toList();
        // Fall back to all reviewers if none tagged as PreConference
        if (_reviewers.isEmpty) _reviewers = all;
      });
    } catch (_) {
      // Non-critical — button simply won't appear if list fails
    }
  }

  Future<void> _showAssignDialog() async {
    if (_reviewers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No reviewers available')),
      );
      return;
    }

    String? selected;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: const Text('Assign Reviewer'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _reviewers.length,
              itemBuilder: (_, i) {
                final r = _reviewers[i];
                final code = r['reviewer_code']?.toString() ?? '';
                return RadioListTile<String>(
                  value: code,
                  groupValue: selected,
                  onChanged: (v) => setDlg(() => selected = v),
                  title: Text(r['name']?.toString() ?? code,
                      style: const TextStyle(fontSize: 13)),
                  subtitle: Text(r['designation']?.toString() ?? '',
                      style: const TextStyle(fontSize: 11)),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white),
              onPressed: selected == null
                  ? null
                  : () async {
                      Navigator.pop(ctx);
                      await _assignReviewer(selected!);
                    },
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _assignReviewer(String reviewerCode) async {
    setState(() => _assigning = true);
    try {
      await _service.adminAssignPreconfReviewer(widget.preconfId, reviewerCode);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reviewer assigned successfully')),
      );
      _load(); // Refresh status
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _assigning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _preconf?['status']?.toString() ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.preconfId),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const LoadingWidget(message: 'Loading submission...')
          : _error != null
              ? ErrorWidget2(message: _error!, onRetry: _load)
              : _preconf == null
                  ? const Center(child: Text('No data found'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionCard(
                              title: 'Pre-Conference Details',
                              children: [
                                _InfoRow('Pre-Conference Code',
                                    _preconf!['pre_confernce_id'] ?? '-'),
                                _InfoRow('Registration ID',
                                    _preconf!['registration_id'] ?? '-'),
                                _InfoRow('Title of Paper',
                                    _preconf!['title_paper'] ?? '-'),
                                _InfoRow('Sub Theme',
                                    _preconf!['sub_theme'] ?? '-'),
                                _InfoRow('Keywords',
                                    _preconf!['keywords'] ?? '-'),
                                _InfoRow('Submitted On',
                                    _preconf!['created_on'] ?? '-'),
                                _StatusRow(
                                    _preconf!['status']?.toString() ?? '0'),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _SectionCard(
                              title: 'Abstract / Background',
                              children: [
                                _TextBlock(_preconf!['abstract_background']),
                              ],
                            ),
                            if (_nonEmpty(_preconf!['abstract_rationale'])) ...[
                              const SizedBox(height: 16),
                              _SectionCard(
                                title: 'Rationale',
                                children: [
                                  _TextBlock(_preconf!['abstract_rationale']),
                                ],
                              ),
                            ],
                            if (_nonEmpty(_preconf!['abstract_objective'])) ...[
                              const SizedBox(height: 16),
                              _SectionCard(
                                title: 'Objective',
                                children: [
                                  _TextBlock(_preconf!['abstract_objective']),
                                ],
                              ),
                            ],
                            if (_nonEmpty(_preconf!['abstract_outcome'])) ...[
                              const SizedBox(height: 16),
                              _SectionCard(
                                title: 'Outcome',
                                children: [
                                  _TextBlock(_preconf!['abstract_outcome']),
                                ],
                              ),
                            ],
                            if (_nonEmpty(_preconf!['abstract_structure'])) ...[
                              const SizedBox(height: 16),
                              _SectionCard(
                                title: 'Structure',
                                children: [
                                  _TextBlock(_preconf!['abstract_structure']),
                                ],
                              ),
                            ],
                            if (_nonEmpty(
                                _preconf!['abstract_description'])) ...[
                              const SizedBox(height: 16),
                              _SectionCard(
                                title: 'Description',
                                children: [
                                  _TextBlock(_preconf!['abstract_description']),
                                ],
                              ),
                            ],
                            if (_nonEmpty(_preconf!['workshop_overview'])) ...[
                              const SizedBox(height: 16),
                              _SectionCard(
                                title: 'Workshop Overview',
                                children: [
                                  _TextBlock(_preconf!['workshop_overview']),
                                ],
                              ),
                            ],
                            if (_nonEmpty(_preconf!['participant']) ||
                                _nonEmpty(
                                    _preconf!['participant_description'])) ...[
                              const SizedBox(height: 16),
                              _SectionCard(
                                title: 'Participant Info',
                                children: [
                                  if (_nonEmpty(_preconf!['participant']))
                                    _InfoRow('Participant',
                                        _preconf!['participant']),
                                  if (_nonEmpty(
                                      _preconf!['participant_description']))
                                    _InfoRow('Description',
                                        _preconf!['participant_description']),
                                  if (_nonEmpty(_preconf!['max_participants']))
                                    _InfoRow('Max Participants',
                                        _preconf!['max_participants'].toString()),
                                ],
                              ),
                            ],
                            if (_authors.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _SectionCard(
                                title: 'Authors (${_authors.length})',
                                children: [
                                  for (int i = 0;
                                      i < _authors.length;
                                      i++) ...[
                                    if (i > 0) const Divider(height: 20),
                                    _AuthorBlock(
                                        index: i + 1,
                                        author: _authors[i]
                                            as Map<String, dynamic>),
                                  ],
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
      bottomNavigationBar: (!_loading && _preconf != null && status == '0')
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: _assigning ? null : _showAssignDialog,
                  icon: _assigning
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.person_add_alt_1),
                  label: Text(_assigning ? 'Assigning…' : 'Assign Reviewer'),
                ),
              ),
            )
          : null,
    );
  }

  bool _nonEmpty(dynamic v) =>
      v != null && v.toString().trim().isNotEmpty && v.toString() != '-';
}

// ── Widgets ────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.primary)),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textGrey,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style:
                    const TextStyle(fontSize: 13, color: AppTheme.textDark)),
          ),
        ],
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  final dynamic value;
  const _TextBlock(this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        value?.toString().trim().isNotEmpty == true
            ? value.toString()
            : '-',
        style: const TextStyle(fontSize: 13, height: 1.55),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String status;
  const _StatusRow(this.status);

  String get label {
    switch (status) {
      case '2':
        return 'Evaluated';
      case '1':
        return 'Under Review';
      default:
        return 'Submitted';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 170,
            child: Text('Status',
                style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textGrey,
                    fontWeight: FontWeight.w500)),
          ),
          StatusBadge(status: label),
        ],
      ),
    );
  }
}

class _AuthorBlock extends StatelessWidget {
  final int index;
  final Map<String, dynamic> author;
  const _AuthorBlock({required this.index, required this.author});

  String _val(String key) => author[key]?.toString().trim() ?? '';

  String get fullName {
    final parts = [
      _val('prefix'),
      _val('first_name'),
      _val('middle_name'),
      _val('last_name'),
    ].where((s) => s.isNotEmpty).join(' ');
    return parts.isEmpty ? '-' : parts;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Author $index',
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppTheme.textDark)),
        const SizedBox(height: 6),
        _InfoRow('Name', fullName),
        _InfoRow('Email', _val('email')),
        _InfoRow('Type', _val('author_type')),
        _InfoRow('Designation', _val('designation')),
        _InfoRow('Institution', _val('institution')),
        _InfoRow(
            'Location',
            [_val('city'), _val('state'), _val('country')]
                .where((s) => s.isNotEmpty)
                .join(', ')
                .let((s) => s.isEmpty ? '-' : s)),
      ],
    );
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T) block) => block(this);
}
