import 'package:flutter/material.dart';
import '../../services/conference_service.dart';
import '../../widgets/app_theme.dart';

class AdminAbstractDetailScreen extends StatefulWidget {
  final String abstractId;
  const AdminAbstractDetailScreen({super.key, required this.abstractId});

  @override
  State<AdminAbstractDetailScreen> createState() =>
      _AdminAbstractDetailScreenState();
}

class _AdminAbstractDetailScreenState
    extends State<AdminAbstractDetailScreen> {
  final ConferenceService _service = ConferenceService();

  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _abstract;
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
      final data = await _service.getAbstractFull(widget.abstractId);
      setState(() {
        _abstract = data['abstract'] as Map<String, dynamic>?;
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
                (r['review_type'] ?? '').toString().toLowerCase().contains('abstract'))
            .toList();
        if (_reviewers.isEmpty) _reviewers = all;
      });
    } catch (_) {}
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
      await _service.adminAssignAbstractReviewer(widget.abstractId, reviewerCode);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reviewer assigned successfully')),
      );
      _load();
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
    final status = _abstract?['status']?.toString() ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.abstractId),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const LoadingWidget(message: 'Loading abstract...')
          : _error != null
              ? ErrorWidget2(message: _error!, onRetry: _load)
              : _abstract == null
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
                              title: 'Abstract Details',
                              children: [
                                _InfoRow('Abstract Code',
                                    _abstract!['abstract_id'] ?? '-'),
                                _InfoRow('Registration ID',
                                    _abstract!['registration_id'] ?? '-'),
                                _InfoRow('Title of Paper',
                                    _abstract!['paper_title'] ?? '-'),
                                _InfoRow(
                                    'Sub Theme', _abstract!['sub_theme'] ?? '-'),
                                _InfoRow('Type of Presentation',
                                    _abstract!['type_of_presentation'] ?? '-'),
                                _InfoRow('Category of Presentation',
                                    _abstract!['category_presentation'] ?? '-'),
                                _InfoRow(
                                    'Keywords', _abstract!['keywords'] ?? '-'),
                                _InfoRow('Submitted On',
                                    _abstract!['created_on'] ?? '-'),
                                _StatusRow(_abstract!['status']?.toString() ?? '0'),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _SectionCard(
                              title: 'Abstract Content',
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    _abstract!['paper_abstract'] ?? '-',
                                    style: const TextStyle(
                                        fontSize: 13, height: 1.55),
                                  ),
                                ),
                              ],
                            ),
                            if (_authors.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _SectionCard(
                                title: 'Authors (${_authors.length})',
                                children: [
                                  for (int i = 0; i < _authors.length; i++) ...[
                                    if (i > 0)
                                      const Divider(height: 20),
                                    _AuthorBlock(
                                        index: i + 1,
                                        author: _authors[i]
                                            as Map<String, dynamic>),
                                  ],
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
      bottomNavigationBar: (!_loading && _abstract != null && status == '0')
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
                style: const TextStyle(fontSize: 13, color: AppTheme.textDark)),
          ),
        ],
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
      _val('last_name')
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
        _InfoRow('Email', _val('author_email')),
        _InfoRow('Type', _val('author_type')),
        _InfoRow('Designation', _val('designation')),
        _InfoRow('Institution', _val('author_institution')),
        _InfoRow(
            'Location',
            [_val('author_city'), _val('author_state'), _val('author_country')]
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
