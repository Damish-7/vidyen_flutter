import 'package:flutter/material.dart';
import '../../services/conference_service.dart';
import '../../widgets/app_theme.dart';

class AdminWorkshopDetailScreen extends StatefulWidget {
  final String workshopId;
  const AdminWorkshopDetailScreen({super.key, required this.workshopId});

  @override
  State<AdminWorkshopDetailScreen> createState() =>
      _AdminWorkshopDetailScreenState();
}

class _AdminWorkshopDetailScreenState
    extends State<AdminWorkshopDetailScreen> {
  final ConferenceService _service = ConferenceService();

  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _workshop;
  List<dynamic> _authors = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.getWorkshopFull(widget.workshopId);
      setState(() {
        _workshop = data['workshop'] as Map<String, dynamic>?;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workshopId),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const LoadingWidget(message: 'Loading submission...')
          : _error != null
              ? ErrorWidget2(message: _error!, onRetry: _load)
              : _workshop == null
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
                              title: 'Workshop Details',
                              children: [
                                _InfoRow('Workshop Code',
                                    _workshop!['workshop_id'] ?? '-'),
                                _InfoRow('Registration ID',
                                    _workshop!['registration_id'] ?? '-'),
                                _InfoRow('Title of Paper',
                                    _workshop!['title_paper'] ?? '-'),
                                _InfoRow(
                                    'Sub Theme', _workshop!['sub_theme'] ?? '-'),
                                _InfoRow(
                                    'Keywords', _workshop!['keywords'] ?? '-'),
                                _InfoRow('Submitted On',
                                    _workshop!['created_on'] ?? '-'),
                                _StatusRow(
                                    _workshop!['status']?.toString() ?? '0'),
                              ],
                            ),
                            if (_nonEmpty(_workshop!['abstract_background'])) ...[
                              const SizedBox(height: 16),
                              _SectionCard(
                                title: 'Abstract / Background',
                                children: [
                                  _TextBlock(_workshop!['abstract_background']),
                                ],
                              ),
                            ],
                            if (_nonEmpty(_workshop!['abstract_rationale'])) ...[
                              const SizedBox(height: 16),
                              _SectionCard(
                                title: 'Rationale',
                                children: [
                                  _TextBlock(_workshop!['abstract_rationale']),
                                ],
                              ),
                            ],
                            if (_nonEmpty(_workshop!['abstract_objective'])) ...[
                              const SizedBox(height: 16),
                              _SectionCard(
                                title: 'Objective',
                                children: [
                                  _TextBlock(_workshop!['abstract_objective']),
                                ],
                              ),
                            ],
                            if (_nonEmpty(_workshop!['abstract_outcome'])) ...[
                              const SizedBox(height: 16),
                              _SectionCard(
                                title: 'Outcome',
                                children: [
                                  _TextBlock(_workshop!['abstract_outcome']),
                                ],
                              ),
                            ],
                            if (_nonEmpty(_workshop!['abstract_structure'])) ...[
                              const SizedBox(height: 16),
                              _SectionCard(
                                title: 'Structure',
                                children: [
                                  _TextBlock(_workshop!['abstract_structure']),
                                ],
                              ),
                            ],
                            if (_nonEmpty(
                                _workshop!['abstract_description'])) ...[
                              const SizedBox(height: 16),
                              _SectionCard(
                                title: 'Description',
                                children: [
                                  _TextBlock(_workshop!['abstract_description']),
                                ],
                              ),
                            ],
                            if (_nonEmpty(_workshop!['workshop_overview'])) ...[
                              const SizedBox(height: 16),
                              _SectionCard(
                                title: 'Workshop Overview',
                                children: [
                                  _TextBlock(_workshop!['workshop_overview']),
                                ],
                              ),
                            ],
                            if (_nonEmpty(_workshop!['participant']) ||
                                _nonEmpty(
                                    _workshop!['participant_description'])) ...[
                              const SizedBox(height: 16),
                              _SectionCard(
                                title: 'Participant Info',
                                children: [
                                  if (_nonEmpty(_workshop!['participant']))
                                    _InfoRow(
                                        'Participant', _workshop!['participant']),
                                  if (_nonEmpty(
                                      _workshop!['participant_description']))
                                    _InfoRow('Description',
                                        _workshop!['participant_description']),
                                  if (_nonEmpty(_workshop!['max_participants']))
                                    _InfoRow(
                                        'Max Participants',
                                        _workshop!['max_participants']
                                            .toString()),
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
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textDark)),
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
