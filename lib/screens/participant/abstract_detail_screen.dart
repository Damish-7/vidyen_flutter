import 'package:flutter/material.dart';
// unused imports removed
import '../../services/conference_service.dart';
import '../../widgets/app_theme.dart';

class AbstractDetailScreen extends StatefulWidget {
  final String abstractId;
  const AbstractDetailScreen({super.key, required this.abstractId});

  @override
  State<AbstractDetailScreen> createState() => _AbstractDetailScreenState();
}

class _AbstractDetailScreenState extends State<AbstractDetailScreen> {
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
      _data = await ConferenceService().getAbstractFull(widget.abstractId);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Abstract Details')),
      body: _loading
          ? const LoadingWidget()
          : _error != null
              ? ErrorWidget2(message: _error!, onRetry: _load)
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final abstract = _data!['abstract'] as Map<String, dynamic>;
    final authors = (_data!['authors'] as List<dynamic>);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(abstract['abstract_id'] ?? '',
                          style: const TextStyle(color: AppTheme.textGrey)),
                      StatusBadge(
                          status: _statusLabel(abstract['status']?.toString())),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(abstract['paper_title'] ?? '',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const Divider(height: 24),
                  _infoRow('Sub-Theme', abstract['sub_theme'] ?? '-'),
                  _infoRow(
                      'Presentation', abstract['type_of_presentation'] ?? '-'),
                  _infoRow(
                      'Category', abstract['category_presentation'] ?? '-'),
                  _infoRow('Keywords', abstract['keywords'] ?? '-'),
                  const SizedBox(height: 12),
                  const Text('Abstract:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary)),
                  const SizedBox(height: 6),
                  Text(abstract['paper_abstract'] ?? '',
                      style: const TextStyle(fontSize: 14, height: 1.5)),
                ],
              ),
            ),
          ),
          if (authors.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Author(s)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...authors.map((a) => _authorCard(a as Map<String, dynamic>)),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 110,
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
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
            backgroundColor: AppTheme.primary,
            child: Icon(Icons.person, color: Colors.white)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
            '${a['designation'] ?? ''} · ${a['author_institution'] ?? a['institution'] ?? ''}',
            style: const TextStyle(fontSize: 12)),
        trailing: Text(a['author_type'] ?? '',
            style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
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
