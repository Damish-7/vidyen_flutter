import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/conference_provider.dart';
import '../../models/registration_model.dart';
import '../../services/conference_service.dart';
import '../../widgets/app_theme.dart';
import 'participant_detail_screen.dart';

class ParticipantsScreen extends StatefulWidget {
  const ParticipantsScreen({super.key});

  @override
  State<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends State<ParticipantsScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ConferenceProvider>().loadAllRegistrations());
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ConferenceProvider>();
    final all = prov.allRegistrations;
    final error = prov.error;

    final filtered = _search.isEmpty
        ? all
        : all
            .where((r) =>
                r.fullName.toLowerCase().contains(_search.toLowerCase()) ||
                r.registrationCode
                    .toLowerCase()
                    .contains(_search.toLowerCase()) ||
                r.email.toLowerCase().contains(_search.toLowerCase()))
            .toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: const InputDecoration(
                hintText: 'Search participants...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
            ),
          ),
          if (prov.loading)
            const Expanded(
                child: LoadingWidget(message: 'Loading participants...'))
          else if (error != null)
            Expanded(
                child: ErrorWidget2(
                    message: error,
                    onRetry: () => context
                        .read<ConferenceProvider>()
                        .loadAllRegistrations()))
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    context.read<ConferenceProvider>().loadAllRegistrations(),
                child: ListView.builder(
                  key: const PageStorageKey('participants_list'),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _RegCard(
                    key: ValueKey(filtered[i].registrationCode),
                    reg: filtered[i],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RegCard extends StatefulWidget {
  final RegistrationModel reg;
  const _RegCard({super.key, required this.reg});

  @override
  State<_RegCard> createState() => _RegCardState();
}

class _RegCardState extends State<_RegCard> {
  bool _isActivating = false;
  bool _isActivated = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.reg.isActive || _isActivated;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ParticipantDetailScreen(reg: widget.reg),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Expanded(
                child: Text(widget.reg.fullName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              StatusBadge(status: isActive ? 'Active' : 'Pending'),
            ],
          ),
          const SizedBox(height: 6),
          Text(widget.reg.registrationCode,
              style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
          const SizedBox(height: 4),
          Text('${widget.reg.typeOfDelegate} · ${widget.reg.institution}',
              style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text(widget.reg.email,
              style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
          if (!isActive) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: _isActivating
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(color: AppTheme.success),
                      ),
                    )
                  : OutlinedButton.icon(
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Activate'),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.success,
                          side: const BorderSide(color: AppTheme.success)),
                      onPressed: () async {
                        print('Activate button clicked for: ${widget.reg.registrationCode}');
                        setState(() => _isActivating = true);
                        
                        try {
                          // Call service directly to avoid provider's loading state
                          // which causes ListView to rebuild and scroll
                          final service = ConferenceService();
                          final res = await service.activateParticipant(widget.reg.registrationCode);
                          final success = res['status'] == true;
                          
                          print('Activation success: $success');
                          
                          if (mounted) {
                            setState(() {
                              _isActivating = false;
                              if (success) {
                                _isActivated = true;
                              }
                            });
                            
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Participant activated successfully'),
                                  backgroundColor: AppTheme.success,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              // Reload in background without showing loading state
                              context.read<ConferenceProvider>().loadAllRegistrations();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(res['message'] ?? 'Activation failed'),
                                  backgroundColor: AppTheme.danger,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          print('Activation error: $e');
                          if (mounted) {
                            setState(() => _isActivating = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
                                backgroundColor: AppTheme.danger,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        }
                      },
                    ),
            ),
          ],
          ],
        ),
      ),
      ),
    );
  }
}
