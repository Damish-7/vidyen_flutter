import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/conference_provider.dart';
import '../../widgets/app_theme.dart';

class AdminMessagesScreen extends StatefulWidget {
  const AdminMessagesScreen({super.key});

  @override
  State<AdminMessagesScreen> createState() => _AdminMessagesScreenState();
}

class _AdminMessagesScreenState extends State<AdminMessagesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ConferenceProvider>().loadMessages());
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ConferenceProvider>();
    final msgs = prov.messages;
    final error = prov.error;

    return Scaffold(
      body: prov.loading
          ? const LoadingWidget(message: 'Loading messages...')
          : error != null
              ? ErrorWidget2(
                  message: error,
                  onRetry: () =>
                      context.read<ConferenceProvider>().loadMessages())
              : msgs.isEmpty
                  ? const Center(
                      child: Text('No messages yet',
                          style: TextStyle(color: AppTheme.textGrey)))
                  : RefreshIndicator(
                      onRefresh: () =>
                          context.read<ConferenceProvider>().loadMessages(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: msgs.length,
                        itemBuilder: (_, i) => _MessageCard(msg: msgs[i]),
                      ),
                    ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final Map<String, dynamic> msg;
  const _MessageCard({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.person_outline, color: AppTheme.primary, size: 18),
            const SizedBox(width: 6),
            Text(msg['name']?.toString() ?? '-',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            Text(msg['created_on']?.toString() ?? '',
                style: const TextStyle(color: AppTheme.textGrey, fontSize: 11)),
          ]),
          const SizedBox(height: 4),
          Text(msg['email']?.toString() ?? '',
              style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
          const Divider(height: 16),
          Text(msg['message']?.toString() ?? '',
              style: const TextStyle(fontSize: 14, height: 1.5)),
        ]),
      ),
    );
  }
}
