import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/conference_provider.dart';
import '../../services/conference_service.dart';
import '../../widgets/app_theme.dart';
import '../admin/admin_abstract_detail_screen.dart';

class ReviewerAbstractsScreen extends StatefulWidget {
  const ReviewerAbstractsScreen({super.key});

  @override
  State<ReviewerAbstractsScreen> createState() =>
      _ReviewerAbstractsScreenState();
}

class _ReviewerAbstractsScreenState extends State<ReviewerAbstractsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ConferenceProvider>().loadReviewerAbstracts());
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ConferenceProvider>();
    final list = prov.reviewerAssignedAbstracts;

    if (prov.loading) {
      return const LoadingWidget(message: 'Loading assigned abstracts...');
    }
    if (prov.error != null) {
      return ErrorWidget2(
        message: prov.error!,
        onRetry: () => context.read<ConferenceProvider>().loadReviewerAbstracts(),
      );
    }
    if (list.isEmpty) {
      return const Center(
        child: Text('No abstracts assigned',
            style: TextStyle(color: AppTheme.textGrey, fontSize: 15)),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          context.read<ConferenceProvider>().loadReviewerAbstracts(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: list.length,
        itemBuilder: (_, i) =>
            _AssignedAbstractCard(serial: i + 1, item: list[i]),
      ),
    );
  }
}

class _AssignedAbstractCard extends StatelessWidget {
  final int serial;
  final Map<String, dynamic> item;

  const _AssignedAbstractCard({required this.serial, required this.item});

  String _val(String key) => item[key]?.toString() ?? '-';

  bool get _isPending => (item['status']?.toString() ?? '0') == '0';

  @override
  Widget build(BuildContext context) {
    final abstractId = _val('abstract_id');
    final registrationId = _val('registration_id');
    final paperTitle = item['paper_title']?.toString() ?? '';
    final subTheme = item['sub_theme']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AdminAbstractDetailScreen(abstractId: abstractId),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Serial badge
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '$serial',
                        style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      abstractId,
                      style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                  _isPending
                      ? const StatusBadge(status: 'Submitted')
                      : const StatusBadge(status: 'Evaluated'),
                ],
              ),
              if (paperTitle.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  paperTitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (subTheme.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subTheme,
                  style: const TextStyle(
                      color: AppTheme.textGrey, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.badge_outlined,
                      size: 13, color: AppTheme.textGrey),
                  const SizedBox(width: 4),
                  Text(
                    'Reg: $registrationId',
                    style: const TextStyle(
                        color: AppTheme.textGrey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_isPending)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.rate_review_outlined, size: 18),
                    label: const Text('Evaluate'),
                    onPressed: () =>
                        _showEvaluateSheet(context, abstractId),
                  ),
                )
              else
                Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppTheme.success, size: 16),
                    const SizedBox(width: 6),
                    const Text('Evaluated',
                        style: TextStyle(
                            color: AppTheme.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AdminAbstractDetailScreen(abstractId: abstractId),
                        ),
                      ),
                      icon: const Icon(Icons.visibility_outlined, size: 16),
                      label: const Text('View'),
                      style: TextButton.styleFrom(
                          foregroundColor: AppTheme.accent),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEvaluateSheet(
      BuildContext context, String abstractId) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EvaluateSheet(
        abstractId: abstractId,
        onSubmit: (status, comment) async {
          final ok =
              await context.read<ConferenceProvider>().updateAbstractStatus(
                    abstractId,
                    status,
                    comment: comment,
                  );
          if (context.mounted) {
            if (ok) {
              context.read<ConferenceProvider>().loadReviewerAbstracts();
              context.read<ConferenceProvider>().loadReviewerDashboard();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Abstract evaluated successfully'),
                  backgroundColor: AppTheme.success,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to submit evaluation'),
                  backgroundColor: AppTheme.danger,
                ),
              );
            }
          }
        },
      ),
    );
  }
}

// ── Evaluate Sheet ────────────────────────────────────────────────────────

class _EvaluateSheet extends StatefulWidget {
  final String abstractId;
  final Future<void> Function(String status, String comment) onSubmit;
  const _EvaluateSheet({required this.abstractId, required this.onSubmit});

  @override
  State<_EvaluateSheet> createState() => _EvaluateSheetState();
}

class _EvaluateSheetState extends State<_EvaluateSheet> {
  final ConferenceService _service = ConferenceService();
  final TextEditingController _commentCtrl = TextEditingController();

  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _abstract;
  List<dynamic> _authors = [];
  String _selectedStatus = '2';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadAbstract();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAbstract() async {
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

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await widget.onSubmit(_selectedStatus, _commentCtrl.text.trim());
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  const Text('Evaluate Abstract',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(_error!,
                              style:
                                  const TextStyle(color: AppTheme.danger)),
                        ))
                      : ListView(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.all(16),
                          children: [
                            _SheetSection(
                              title: 'Abstract Details',
                              children: [
                                _SheetRow('Abstract Code',
                                    _abstract!['abstract_id'] ?? '-'),
                                _SheetRow('Registration ID',
                                    _abstract!['registration_id'] ?? '-'),
                                _SheetRow(
                                    'Title', _abstract!['paper_title'] ?? '-'),
                                _SheetRow('Sub Theme',
                                    _abstract!['sub_theme'] ?? '-'),
                                _SheetRow('Type',
                                    _abstract!['type_of_presentation'] ?? '-'),
                                _SheetRow('Category',
                                    _abstract!['category_presentation'] ?? '-'),
                                _SheetRow(
                                    'Keywords', _abstract!['keywords'] ?? '-'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _SheetSection(
                              title: 'Abstract Content',
                              children: [
                                Text(
                                  _abstract!['paper_abstract']
                                              ?.toString()
                                              .trim()
                                              .isNotEmpty ==
                                          true
                                      ? _abstract!['paper_abstract'].toString()
                                      : '-',
                                  style: const TextStyle(
                                      fontSize: 13, height: 1.55),
                                ),
                              ],
                            ),
                            if (_authors.isNotEmpty) ...[

                              const SizedBox(height: 12),
                              _SheetSection(
                                title: 'Authors (${_authors.length})',
                                children: [
                                  for (int i = 0;
                                      i < _authors.length;
                                      i++) ...[

                                    if (i > 0) const Divider(height: 20),
                                    _AuthorInfo(
                                        index: i + 1,
                                        author: _authors[i]
                                            as Map<String, dynamic>),
                                  ],
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 8),
                            const Text('Decision',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textGrey)),
                            const SizedBox(height: 10),
                            SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(
                                    value: '2',
                                    label: Text('Approve'),
                                    icon: Icon(Icons.check_circle_outline)),
                                ButtonSegment(
                                    value: '1',
                                    label: Text('Revise'),
                                    icon: Icon(Icons.edit_note_outlined)),
                              ],
                              selected: {_selectedStatus},
                              onSelectionChanged: (s) =>
                                  setState(() => _selectedStatus = s.first),
                            ),
                            const SizedBox(height: 16),
                            const Text('Comment (optional)',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textGrey)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _commentCtrl,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                hintText: 'Enter review comment...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(48),
                              ),
                              onPressed: _submitting ? null : _submit,
                              icon: _submitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white))
                                  : const Icon(Icons.send),
                              label: Text(_submitting
                                  ? 'Submitting…'
                                  : 'Submit Evaluation'),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────

class _SheetSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SheetSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppTheme.primary)),
            const Divider(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  final String label;
  final String value;
  const _SheetRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
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

class _AuthorInfo extends StatelessWidget {
  final int index;
  final Map<String, dynamic> author;
  const _AuthorInfo({required this.index, required this.author});

  String _v(String key) => author[key]?.toString().trim() ?? '';

  String get fullName {
    final parts =
        [_v('prefix'), _v('first_name'), _v('middle_name'), _v('last_name')]
            .where((s) => s.isNotEmpty)
            .join(' ');
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
        _SheetRow('Name', fullName),
        _SheetRow('Email', _v('author_email')),
        _SheetRow('Type', _v('author_type')),
        _SheetRow('Designation', _v('designation')),
        _SheetRow('Institution', _v('author_institution')),
        _SheetRow(
            'Location',
            [_v('author_city'), _v('author_state'), _v('author_country')]
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
