import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/conference_provider.dart';
import '../../models/submission_models.dart';
import '../../widgets/app_theme.dart';
import 'submission_form_screen.dart';
import 'preconference_detail_screen.dart';

class PreConferenceListScreen extends StatefulWidget {
  const PreConferenceListScreen({super.key});

  @override
  State<PreConferenceListScreen> createState() =>
      _PreConferenceListScreenState();
}

class _PreConferenceListScreenState extends State<PreConferenceListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ConferenceProvider>().loadMyPreConf());
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ConferenceProvider>();
    final loading = prov.loading;
    final error = prov.error;
    final list = prov.preconference;

    return Scaffold(
      body: loading
          ? const LoadingWidget(message: 'Loading...')
          : error != null
              ? ErrorWidget2(
                  message: error,
                  onRetry: () =>
                      context.read<ConferenceProvider>().loadMyPreConf())
              : list.isEmpty
                  ? const Center(
                      child: Text('No pre-conference submissions yet',
                          style: TextStyle(color: AppTheme.textGrey)))
                  : RefreshIndicator(
                      onRefresh: () =>
                          context.read<ConferenceProvider>().loadMyPreConf(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: list.length,
                        itemBuilder: (ctx, i) => _SubmissionCard(item: list[i]),
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final done = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
                builder: (_) => const SubmissionFormScreen(
                    type: SubmissionType.preconference)),
          );
          if (done == true && mounted) {
            context.read<ConferenceProvider>().loadMyPreConf();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Submit'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  final PreConferenceModel item;
  const _SubmissionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PreConferenceDetailScreen(
                preconferenceId: item.preconferenceId,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.preconferenceId,
                    style:
                        const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                StatusBadge(status: item.statusLabel),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.paperTitle,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(item.subthemes,
                style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ]),
        ),
      ),
    );
  }
}
