import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/conference_provider.dart';
import '../../models/abstract_model.dart';
import '../../widgets/app_theme.dart';
import 'abstract_submit_screen.dart';
import 'abstract_detail_screen.dart';

class AbstractListScreen extends StatefulWidget {
  const AbstractListScreen({super.key});

  @override
  State<AbstractListScreen> createState() => _AbstractListScreenState();
}

class _AbstractListScreenState extends State<AbstractListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ConferenceProvider>().loadMyAbstracts());
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ConferenceProvider>();
    final loading = prov.loading;
    final error = prov.error;
    final list = prov.abstracts;

    return Scaffold(
      body: loading
          ? const LoadingWidget(message: 'Loading abstracts...')
          : error != null
              ? ErrorWidget2(
                  message: error,
                  onRetry: () =>
                      context.read<ConferenceProvider>().loadMyAbstracts())
              : list.isEmpty
                  ? const Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.article_outlined,
                            size: 64, color: AppTheme.textGrey),
                        SizedBox(height: 12),
                        Text('No abstracts submitted yet',
                            style: TextStyle(
                                color: AppTheme.textGrey, fontSize: 16)),
                      ]),
                    )
                  : RefreshIndicator(
                      onRefresh: () =>
                          context.read<ConferenceProvider>().loadMyAbstracts(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: list.length,
                        itemBuilder: (ctx, i) =>
                            _AbstractCard(abstract: list[i]),
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final done = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AbstractSubmitScreen()),
          );
          if (done == true && mounted) {
            context.read<ConferenceProvider>().loadMyAbstracts();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Submit Abstract'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _AbstractCard extends StatelessWidget {
  final AbstractModel abstract;
  const _AbstractCard({required this.abstract});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.article_outlined, color: AppTheme.primary),
        ),
        title: Text(
          abstract.paperTitle,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(abstract.abstractId,
                style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
            const SizedBox(height: 4),
            StatusBadge(status: abstract.statusLabel),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  AbstractDetailScreen(abstractId: abstract.abstractId)),
        ),
      ),
    );
  }
}
