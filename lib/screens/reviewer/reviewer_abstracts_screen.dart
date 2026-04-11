import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/conference_provider.dart';
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
                        _showEvaluateDialog(context, abstractId),
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

  Future<void> _showEvaluateDialog(
      BuildContext context, String abstractId) async {
    final commentCtrl = TextEditingController();
    String selectedStatus = '2'; // default: Evaluated/Approved

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dCtx) => StatefulBuilder(
        builder: (_, setS) => AlertDialog(
          title: const Text('Evaluate Abstract'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Decision',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textGrey)),
              const SizedBox(height: 8),
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
                selected: {selectedStatus},
                onSelectionChanged: (s) => setS(() => selectedStatus = s.first),
              ),
              const SizedBox(height: 16),
              const Text('Comment (optional)',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textGrey)),
              const SizedBox(height: 8),
              TextField(
                controller: commentCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                    hintText: 'Enter review comment...'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dCtx, false),
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () => Navigator.pop(dCtx, true),
                child: const Text('Submit')),
          ],
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      final ok = await context.read<ConferenceProvider>().updateAbstractStatus(
            abstractId,
            selectedStatus,
            comment: commentCtrl.text.trim(),
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
    }
  }
}
