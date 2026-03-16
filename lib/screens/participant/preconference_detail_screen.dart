import 'package:flutter/material.dart';
import '../../services/conference_service.dart';
import '../../widgets/app_theme.dart';

class PreConferenceDetailScreen extends StatefulWidget {
  final String preconferenceId;
  const PreConferenceDetailScreen({super.key, required this.preconferenceId});

  @override
  State<PreConferenceDetailScreen> createState() =>
      _PreConferenceDetailScreenState();
}

class _PreConferenceDetailScreenState
    extends State<PreConferenceDetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

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
      _data = await ConferenceService().getPreConfFull(widget.preconferenceId);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pre-Conference Details')),
      body: _loading
          ? const LoadingWidget()
          : _error != null
              ? ErrorWidget2(message: _error!, onRetry: _load)
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final preconf = _data!['preconference'] as Map<String, dynamic>;
    final authors = (_data!['authors'] as List<dynamic>);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(preconf['pre_confernce_id'] ?? '',
                          style: const TextStyle(color: AppTheme.textGrey)),
                      StatusBadge(
                          status: _statusLabel(preconf['status']?.toString())),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(preconf['title_paper'] ?? '',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const Divider(height: 24),
                  _infoRow('Registration ID', preconf['registration_id'] ?? '-'),
                  _infoRow('Sub-Theme', preconf['sub_theme'] ?? '-'),
                  _infoRow('Keywords', preconf['keywords'] ?? '-'),
                ],
              ),
            ),
          ),
          
          // Abstract Background
          if (preconf['abstract_background'] != null &&
              preconf['abstract_background'].toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionCard('Abstract Background', preconf['abstract_background']),
          ],

          // Abstract Rationale
          if (preconf['abstract_rationale'] != null &&
              preconf['abstract_rationale'].toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionCard('Abstract Rationale', preconf['abstract_rationale']),
          ],

          // Abstract Objective
          if (preconf['abstract_objective'] != null &&
              preconf['abstract_objective'].toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionCard('Abstract Objective', preconf['abstract_objective']),
          ],

          // Abstract Outcome
          if (preconf['abstract_outcome'] != null &&
              preconf['abstract_outcome'].toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionCard('Abstract Outcome', preconf['abstract_outcome']),
          ],

          // Abstract Structure
          if (preconf['abstract_structure'] != null &&
              preconf['abstract_structure'].toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionCard('Abstract Structure', preconf['abstract_structure']),
          ],

          // Abstract Description
          if (preconf['abstract_description'] != null &&
              preconf['abstract_description'].toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionCard('Abstract Description', preconf['abstract_description']),
          ],

          // Participants
          if (preconf['participant'] != null &&
              preconf['participant'].toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionCard('Participants', preconf['participant']),
          ],

          // Participant Description
          if (preconf['participant_description'] != null &&
              preconf['participant_description'].toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionCard(
                'Participant Description', preconf['participant_description']),
          ],

          // Max Participants
          if (preconf['max_participants'] != null &&
              preconf['max_participants'].toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionCard(
                'Maximum Participants', preconf['max_participants']),
          ],

          // Workshop Overview
          if (preconf['workshop_overview'] != null &&
              preconf['workshop_overview'].toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionCard('Workshop Overview', preconf['workshop_overview']),
          ],

          // Authors Section
          if (authors.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Author(s) and Affiliations',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...authors.map((a) => _authorCard(a as Map<String, dynamic>)),
          ],
        ],
      ),
    );
  }

  Widget _sectionCard(String title, dynamic content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                    fontSize: 15)),
            const SizedBox(height: 8),
            Text(content?.toString() ?? '',
                style: const TextStyle(fontSize: 14, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 120,
                child: Text('$label:',
                    style: const TextStyle(color: AppTheme.textGrey))),
            Expanded(
                child: Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
      );

  Widget _authorCard(Map<String, dynamic> a) {
    final name =
        '${a['prefix'] ?? ''} ${a['first_name'] ?? ''} ${a['middle_name'] ?? ''} ${a['last_name'] ?? ''}'
            .trim();
    final location = [
      a['city'],
      a['state'],
      a['country'],
    ].where((e) => e != null && e.toString().isNotEmpty).join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                    backgroundColor: AppTheme.primary,
                    child: Icon(Icons.person, color: Colors.white, size: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (a['email'] != null && a['email'].toString().isNotEmpty)
                        Text(a['email'].toString(),
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.textGrey)),
                    ],
                  ),
                ),
                if (a['author_type'] != null &&
                    a['author_type'].toString().isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(a['author_type'].toString(),
                        style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500)),
                  ),
              ],
            ),
            if (a['designation'] != null &&
                a['designation'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.work_outline, size: 14, color: AppTheme.textGrey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(a['designation'].toString(),
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textGrey)),
                  ),
                ],
              ),
            ],
            if (a['institution'] != null &&
                a['institution'].toString().isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.business, size: 14, color: AppTheme.textGrey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(a['institution'].toString(),
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textGrey)),
                  ),
                ],
              ),
            ],
            if (location.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: AppTheme.textGrey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(location,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textGrey)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _statusLabel(String? s) {
    switch (s) {
      case '2':
        return 'Evaluated';
      case '1':
        return 'Under Review';
      default:
        return 'Submitted';
    }
  }
}
