import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/conference_provider.dart';
import '../../models/abstract_model.dart';
import '../../widgets/app_theme.dart';

class AdminAbstractsScreen extends StatefulWidget {
  const AdminAbstractsScreen({super.key});

  @override
  State<AdminAbstractsScreen> createState() => _AdminAbstractsScreenState();
}

class _AdminAbstractsScreenState extends State<AdminAbstractsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ConferenceProvider>().loadAllAbstracts());
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ConferenceProvider>();
    final list = prov.allAbstracts;
    final error = prov.error;

    return Scaffold(
      body: prov.loading
          ? const LoadingWidget(message: 'Loading abstracts...')
          : error != null
              ? ErrorWidget2(
                  message: error,
                  onRetry: () =>
                      context.read<ConferenceProvider>().loadAllAbstracts())
              : RefreshIndicator(
                  onRefresh: () =>
                      context.read<ConferenceProvider>().loadAllAbstracts(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: list.length,
                    itemBuilder: (_, i) =>
                        _AbstractAdminCard(abstract: list[i]),
                  ),
                ),
    );
  }
}

class _AbstractAdminCard extends StatelessWidget {
  final AbstractModel abstract;
  const _AbstractAdminCard({required this.abstract});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text(abstract.abstractId,
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13))),
            StatusBadge(status: abstract.statusLabel),
          ]),
          const SizedBox(height: 6),
          Text(abstract.paperTitle,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(abstract.subTheme,
              style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          Row(children: [
            _actionBtn(context, 'Approve', AppTheme.success, '2'),
            const SizedBox(width: 8),
            _actionBtn(context, 'Review', AppTheme.warning, '1'),
          ]),
        ]),
      ),
    );
  }

  Widget _actionBtn(
          BuildContext ctx, String label, Color color, String status) =>
      OutlinedButton(
        style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6)),
        onPressed: () => _showCommentDialog(ctx, status),
        child: Text(label, style: const TextStyle(fontSize: 13)),
      );

  Future<void> _showCommentDialog(BuildContext ctx, String status) async {
    final commentCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        title: const Text('Add Comment (optional)'),
        content: TextField(
          controller: commentCtrl,
          maxLines: 3,
          decoration:
              const InputDecoration(hintText: 'Enter review comment...'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dCtx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(dCtx, true),
              child: const Text('Confirm')),
        ],
      ),
    );

    if (confirmed == true && ctx.mounted) {
      await ctx.read<ConferenceProvider>().updateAbstractStatus(
          abstract.abstractId, status,
          comment: commentCtrl.text.trim());
      if (ctx.mounted) {
        ctx.read<ConferenceProvider>().loadAllAbstracts();
      }
    }
  }
}
