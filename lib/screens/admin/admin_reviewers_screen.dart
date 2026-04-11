import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/conference_provider.dart';
import '../../widgets/app_theme.dart';

class AdminReviewersScreen extends StatefulWidget {
  const AdminReviewersScreen({super.key});

  @override
  State<AdminReviewersScreen> createState() => _AdminReviewersScreenState();
}

class _AdminReviewersScreenState extends State<AdminReviewersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ConferenceProvider>().loadAllReviewers());
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ConferenceProvider>();
    final list = prov.allReviewers;
    final error = prov.error;

    return Scaffold(
      body: prov.loading
          ? const LoadingWidget(message: 'Loading reviewers...')
          : error != null
              ? ErrorWidget2(
                  message: error,
                  onRetry: () =>
                      context.read<ConferenceProvider>().loadAllReviewers())
              : RefreshIndicator(
                  onRefresh: () =>
                      context.read<ConferenceProvider>().loadAllReviewers(),
                  child: list.isEmpty
                      ? const Center(child: Text('No reviewers found'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: list.length,
                          itemBuilder: (_, i) =>
                              _ReviewerCard(reviewer: list[i]),
                        ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Reviewer'),
        onPressed: () => _showAddSheet(context),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _AddReviewerSheet(
        onSaved: () =>
            context.read<ConferenceProvider>().loadAllReviewers(),
      ),
    );
  }
}

// ── Reviewer Card ──────────────────────────────────────────────────────────

class _ReviewerCard extends StatelessWidget {
  final Map<String, dynamic> reviewer;
  const _ReviewerCard({required this.reviewer});

  String _val(String k) => reviewer[k]?.toString() ?? '-';

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            CircleAvatar(
              backgroundColor: AppTheme.primary.withOpacity(0.12),
              child: Text(
                (_val('name').isNotEmpty && _val('name') != '-')
                    ? _val('name')[0].toUpperCase()
                    : 'R',
                style: const TextStyle(
                    color: AppTheme.primary, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_val('name'),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppTheme.textDark)),
                    const SizedBox(height: 2),
                    Text(_val('email'),
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textGrey)),
                  ]),
            ),
            _TypeBadge(_val('review_type')),
          ]),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _ReviewerDetailSheet(reviewer: reviewer),
    );
  }
}

// ── Type badge ──────────────────────────────────────────────────────────────

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge(this.type);

  Color get _color {
    if (type.contains('Abstract')) return AppTheme.primary;
    if (type.contains('PreConference') || type.contains('Pre')) {
      return AppTheme.accent;
    }
    return AppTheme.success;
  }

  String get _short {
    if (type.contains('Abstract')) return 'Abstract';
    if (type.contains('PreConference') || type.contains('Pre')) {
      return 'Pre-Conf';
    }
    if (type.contains('Workshop')) return 'Workshop';
    return type;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(_short,
          style: TextStyle(
              fontSize: 11, color: _color, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Detail bottom sheet ────────────────────────────────────────────────────

class _ReviewerDetailSheet extends StatelessWidget {
  final Map<String, dynamic> reviewer;
  const _ReviewerDetailSheet({required this.reviewer});

  String _val(String k) => reviewer[k]?.toString().trim() ?? '-';

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      maxChildSize: 0.85,
      builder: (_, controller) => Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              const Text('Reviewer Details',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary)),
              const Spacer(),
              IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context)),
            ]),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: AppTheme.primary.withOpacity(0.12),
                    child: Text(
                      _val('name').isNotEmpty ? _val('name')[0].toUpperCase() : 'R',
                      style: const TextStyle(
                          fontSize: 26,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(child: _TypeBadge(_val('review_type'))),
                const SizedBox(height: 16),
                _InfoRow('Reviewer Code', _val('reviewer_code')),
                _InfoRow('Name', _val('name')),
                _InfoRow('Email', _val('email')),
                _InfoRow('Phone', _val('phone_number')),
                _InfoRow('Designation', _val('designation')),
                _InfoRow('Institution', _val('institution')),
                _InfoRow('Address', _val('address')),
                _InfoRow('Reviewer Type', _val('review_type')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 140,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textGrey,
                  fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontSize: 13, color: AppTheme.textDark)),
        ),
      ]),
    );
  }
}

// ── Add Reviewer bottom sheet ──────────────────────────────────────────────

class _AddReviewerSheet extends StatefulWidget {
  final VoidCallback onSaved;
  const _AddReviewerSheet({required this.onSaved});

  @override
  State<_AddReviewerSheet> createState() => _AddReviewerSheetState();
}

class _AddReviewerSheetState extends State<_AddReviewerSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _designation = TextEditingController();
  final _institution = TextEditingController();
  final _address = TextEditingController();
  String? _reviewerType;
  bool _submitting = false;

  static const _reviewerTypes = [
    'Abstract Reviewer',
    'PreConference Reviewer',
    'Workshop Reviewer',
  ];

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _designation.dispose();
    _institution.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    final ok = await context.read<ConferenceProvider>().addReviewer({
      'name': _name.text.trim(),
      'email': _email.text.trim(),
      'phone': _phone.text.trim(),
      'designation': _designation.text.trim(),
      'institution': _institution.text.trim(),
      'address': _address.text.trim(),
      'review_type': _reviewerType,
    });
    setState(() => _submitting = false);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      widget.onSaved();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reviewer added successfully')));
    } else {
      final err = context.read<ConferenceProvider>().error ?? 'Failed to add reviewer';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (_, controller) => Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                const Text('Add Reviewer',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary)),
                const Spacer(),
                if (_submitting)
                  const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                else
                  TextButton(
                      onPressed: _submit, child: const Text('Save')),
              ]),
            ),
            const Divider(height: 1),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    _field(_name, 'Name', required: true),
                    _field(_email, 'Email',
                        required: true,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => (v != null &&
                                v.contains('@'))
                            ? null
                            : 'Enter a valid email'),
                    _field(_phone, 'Phone Number',
                        keyboardType: TextInputType.phone),
                    _field(_designation, 'Designation'),
                    _field(_institution, 'Institution'),
                    _field(_address, 'Address'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _reviewerType,
                      decoration: const InputDecoration(
                        labelText: 'Reviewer Type *',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      items: _reviewerTypes
                          .map((t) =>
                              DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _reviewerType = v),
                      validator: (v) =>
                          v == null ? 'Please select a reviewer type' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white))
                          : const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    bool required = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        validator: validator ??
            (required
                ? (v) =>
                    (v == null || v.trim().isEmpty) ? '$label is required' : null
                : null),
      ),
    );
  }
}
