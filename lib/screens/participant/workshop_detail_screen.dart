import 'package:flutter/material.dart';
import '../../services/conference_service.dart';
import '../../widgets/app_theme.dart';

class WorkshopDetailScreen extends StatefulWidget {
  final String workshopId;
  const WorkshopDetailScreen({super.key, required this.workshopId});

  @override
  State<WorkshopDetailScreen> createState() => _WorkshopDetailScreenState();
}

class _WorkshopDetailScreenState extends State<WorkshopDetailScreen> {
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
      _data = await ConferenceService().getWorkshopFull(widget.workshopId);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workshop Details')),
      body: _loading
          ? const LoadingWidget()
          : _error != null
              ? ErrorWidget2(message: _error!, onRetry: _load)
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final workshop = _data!['workshop'] as Map<String, dynamic>;
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
                      Text(workshop['workshop_id'] ?? '',
                          style: const TextStyle(color: AppTheme.textGrey)),
                      StatusBadge(
                          status: _statusLabel(workshop['status']?.toString())),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(workshop['title_paper'] ?? '',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const Divider(height: 24),
                  _infoRow('Registration ID', workshop['registration_id'] ?? '-'),
                  _infoRow('Sub-Theme', workshop['sub_theme'] ?? '-'),
                  _infoRow('Keywords', workshop['keywords'] ?? '-'),
                ],
              ),
            ),
          ),
          
          // Abstract Background
          if (workshop['abstract_background'] != null &&
              workshop['abstract_background'].toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionCard('Abstract Background', workshop['abstract_background']),
          ],

          // Abstract Rationale
          if (workshop['abstract_rationale'] != null &&
              workshop['abstract_rationale'].toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionCard('Abstract Rationale', workshop['abstract_rationale']),
          ],

          // Abstract Objective
          if (workshop['abstract_objective'] != null &&
              workshop['abstract_objective'].toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionCard('Abstract Objective', workshop['abstract_objective']),
          ],

          // Abstract Outcome
          if (workshop['abstract_outcome'] != null &&
              workshop['abstract_outcome'].toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionCard('Abstract Outcome', workshop['abstract_outcome']),
          ],

          // Abstract Structure
          if (workshop['abstract_structure'] != null &&
              workshop['abstract_structure'].toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionCard('Abstract Structure', workshop['abstract_structure']),
          ],

          // Abstract Description
          if (workshop['abstract_description'] != null &&
              workshop['abstract_description'].toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionCard('Abstract Description', workshop['abstract_description']),
          ],

          // Participants
          if (workshop['participant'] != null &&
              workshop['participant'].toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionCard('Participants', workshop['participant']),
          ],

          // Participant Description
          if (workshop['participant_description'] != null &&
              workshop['participant_description'].toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionCard(
                'Participant Description', workshop['participant_description']),
          ],

          // Max Participants
          if (workshop['max_participants'] != null &&
              workshop['max_participants'].toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionCard(
                'Maximum Participants', workshop['max_participants']),
          ],

          // Workshop Overview
          if (workshop['workshop_overview'] != null &&
              workshop['workshop_overview'].toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionCard('Workshop Overview', workshop['workshop_overview']),
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
