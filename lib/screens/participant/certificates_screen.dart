import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/api_config.dart';
import '../../services/conference_service.dart';
import '../../widgets/app_theme.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, String>> _certificates = [];
  String _regCode = '';

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final service = ConferenceService();
      final data = await service.getMyCertificates();

      _regCode = data['registration_code']?.toString() ?? '';
      
      final generatedCerts = (data['generated_certificates'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [];
      
      final hasPaper = data['has_paper_presentation'] == true;
      final hasPoster = data['has_poster_presentation'] == true;
      final hasYenvision = data['has_yenvision_lightning_talk'] == true;

      _certificates = [];

      // Conference Participation - always shown
      _certificates.add({
        'title': 'Conference Participation',
        'description': 'Certificate of participation in Conference',
        'file': 'generate_conference_certificate_download.php'
      });

      // Paper Presentation - shown if user has paper abstracts
      if (hasPaper) {
        _certificates.add({
          'title': 'Paper Presentation',
          'description': 'Certificate for Paper Presentation',
          'file': 'generate_paper_presentation_certificate_download.php'
        });
      }

      // Poster Presentation - shown if user has poster abstracts
      if (hasPoster) {
        _certificates.add({
          'title': 'Poster Presentation',
          'description': 'Certificate for Poster Presentation',
          'file': 'generate_poster_presentation_certificate_download.php'
        });
      }

      // Yenvision Lightning Talk - shown if user has yenvision abstracts
      if (hasYenvision) {
        _certificates.add({
          'title': 'Yenvision Lightning Talk',
          'description': 'Certificate for Yenvision Lightning Talk Presentation',
          'file': 'generate_yenvision_lightning_talk_certificate_download.php'
        });
      }

      // Generated certificates - only shown if they exist
      final generatedCertMap = {
        'preconference_item_analysis': {
          'title': 'Pre-Conference Participation',
          'description': 'Certificate of participation in Pre-Conference Item Analysis',
          'file': 'generate_certificate_download.php'
        },
        'mindful_map': {
          'title': 'Pre-Conference Workshop',
          'description': 'Certificate of participation in Pre-Conference Workshop Mindful Map',
          'file': 'generate_mindfulmap_certificate_download.php'
        },
        'sage': {
          'title': 'Pre-Conference Participation SAGE',
          'description': 'Certificate of participation in Pre-Conference SAGE',
          'file': 'generate_sage_certificate_download.php'
        },
        'itlm': {
          'title': 'Pre-Conference Participation ITLM',
          'description': 'Certificate of participation in Pre-Conference Interactive Teaching Learning Methods',
          'file': 'generate_itlm_certificate_download.php'
        },
        'workshop_bridging': {
          'title': 'Workshop Course',
          'description': 'Certificate of participation in Workshop Course Bridging Mind Building Care',
          'file': 'generate_workshop_bridging_certificate_download.php'
        },
        'workshop_proms_prems': {
          'title': 'Workshop PROMs PREMs',
          'description': 'Workshop Certificate: PROMs, PREMs, and Dentistry Experiences',
          'file': 'generate_workshop_proms_prems_certificate_download.php'
        },
        'workshop_microteaching': {
          'title': 'Microteaching Workshop',
          'description': 'Workshop Certificate: Microteaching',
          'file': 'generate_workshop_microteaching_certificate_download.php'
        },
        'first_place_paper': {
          'title': '1st Place Paper Award',
          'description': 'Award Certificate: 1st Place Paper',
          'file': 'generate_first_place_paper_certificate_download.php'
        },
        'second_place_paper': {
          'title': '2nd Place Paper Award',
          'description': 'Award Certificate: 2nd Place Paper',
          'file': 'generate_second_place_paper_certificate_download.php'
        },
        'first_place_poster': {
          'title': '1st Place Poster Award',
          'description': 'Award Certificate: 1st Place Poster',
          'file': 'generate_first_place_poster_certificate_download.php'
        },
        'second_place_poster': {
          'title': '2nd Place Poster Award',
          'description': 'Award Certificate: 2nd Place Poster',
          'file': 'generate_second_place_poster_certificate_download.php'
        },
        'first_place_yenvision': {
          'title': '1st Place YenVision Award',
          'description': 'Award Certificate: 1st Place YenVision',
          'file': 'generate_first_place_yenvision_certificate_download.php'
        },
        'second_place_yenvision': {
          'title': '2nd Place YenVision Award',
          'description': 'Award Certificate: 2nd Place YenVision',
          'file': 'generate_second_place_yenvision_certificate_download.php'
        },
      };

      for (var certType in generatedCerts) {
        if (generatedCertMap.containsKey(certType)) {
          final cert = generatedCertMap[certType]!;
          _certificates.add({
            'title': cert['title']!,
            'description': cert['description']!,
            'file': cert['file']!
          });
        }
      }

    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const LoadingWidget(message: 'Loading certificates...');
    }

    if (_error != null) {
      return ErrorWidget2(
        message: _error!,
        onRetry: _loadCertificates,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCertificates,
      child: _certificates.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 120),
                Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.card_membership_outlined,
                      size: 64, color: AppTheme.textGrey),
                  SizedBox(height: 12),
                  Text('No certificates available yet',
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 16)),
                ])),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _certificates.length,
              itemBuilder: (_, i) {
                final cert = _certificates[i];
                return _CertCard(
                  cert: cert,
                  regCode: _regCode,
                );
              },
            ),
    );
  }
}

class _CertCard extends StatelessWidget {
  final Map<String, String> cert;
  final String regCode;
  const _CertCard({required this.cert, required this.regCode});

  @override
  Widget build(BuildContext context) {
    final isAward = cert['title']!.contains('Place');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isAward ? Icons.emoji_events_outlined : Icons.workspace_premium_outlined,
            color: AppTheme.success,
            size: 28,
          ),
        ),
        title: Text(cert['title']!,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(cert['description']!,
            style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.download, color: AppTheme.primary),
          tooltip: 'Download',
          onPressed: () => _downloadCertificate(context, cert['file']!),
        ),
      ),
    );
  }

  Future<void> _downloadCertificate(BuildContext context, String fileName) async {
    try {
      // Build URL to the PHP certificate generator
      final url = '${ApiConfig.baseUrl}/$fileName?id=$regCode';

      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: ${e.toString()}'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }
}
