import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/conference_provider.dart';
import '../../widgets/app_theme.dart';

enum SubmissionType { preconference, workshop }

class SubmissionFormScreen extends StatefulWidget {
  final SubmissionType type;
  const SubmissionFormScreen({super.key, required this.type});

  @override
  State<SubmissionFormScreen> createState() => _SubmissionFormScreenState();
}

class _SubmissionFormScreenState extends State<SubmissionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _keyCtrl = TextEditingController();
  final _abstractCtrl = TextEditingController();
  
  // Pre-conference specific fields
  final _backgroundCtrl = TextEditingController();
  final _rationaleCtrl = TextEditingController();
  final _objectiveCtrl = TextEditingController();
  final _outcomeCtrl = TextEditingController();
  final _structureCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _participantCtrl = TextEditingController();
  final _participantDescCtrl = TextEditingController();
  final _maxParticipantsCtrl = TextEditingController();
  final _workshopOverviewCtrl = TextEditingController();

  String _subTheme = 'Assessment in Competency Based Dental Education';
  String _type = 'Oral';
  String _category = 'Original Research';

  final List<Map<String, TextEditingController>> _authors = [];

  @override
  void initState() {
    super.initState();
    _addAuthor();
  }

  void _addAuthor() {
    _authors.add({
      'prefix': TextEditingController(),
      'first_name': TextEditingController(),
      'middle_name': TextEditingController(),
      'last_name': TextEditingController(),
      'email': TextEditingController(),
      'author_type': TextEditingController(text: 'Author'),
      'designation': TextEditingController(),
      'institution': TextEditingController(),
      'city': TextEditingController(),
      'state': TextEditingController(),
      'country': TextEditingController(),
      'pincode': TextEditingController(),
    });
    setState(() {});
  }

  void _removeAuthor(int i) {
    for (final c in _authors[i].values) c.dispose();
    _authors.removeAt(i);
    setState(() {});
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>().user;
    final prov = context.read<ConferenceProvider>();

    final authorsData = _authors
        .map((a) => {
              'prefix': a['prefix']!.text.trim(),
              'first_name': a['first_name']!.text.trim(),
              'middle_name': a['middle_name']!.text.trim(),
              'last_name': a['last_name']!.text.trim(),
              'email': a['email']!.text.trim(),
              'author_type': a['author_type']!.text.trim(),
              'designation': a['designation']!.text.trim(),
              'institution': a['institution']!.text.trim(),
              'city': a['city']!.text.trim(),
              'state': a['state']!.text.trim(),
              'country': a['country']!.text.trim(),
              'pincode': a['pincode']!.text.trim(),
            })
        .toList();

    final data = {
      'participant_id': auth?.userId ?? '',
      'subthemes': _subTheme,
      'paper_title': _titleCtrl.text.trim(),
      'keyword': _keyCtrl.text.trim(),
      'paper_abstract': _abstractCtrl.text.trim(),
      'type_of_presentation': _type,
      'category_presentation': _category,
      'authors': authorsData,
      // Add workshop/pre-conference specific fields
      'abstract_background': _backgroundCtrl.text.trim(),
      'abstract_rationale': _rationaleCtrl.text.trim(),
      'abstract_objective': _objectiveCtrl.text.trim(),
      'abstract_outcome': _outcomeCtrl.text.trim(),
      'abstract_structure': _structureCtrl.text.trim(),
      'abstract_description': _descriptionCtrl.text.trim(),
      'participant': _participantCtrl.text.trim(),
      'participant_description': _participantDescCtrl.text.trim(),
      'max_participants': _maxParticipantsCtrl.text.trim(),
      'workshop_overview': _workshopOverviewCtrl.text.trim(),
    };

    bool ok;
    if (widget.type == SubmissionType.preconference) {
      ok = await prov.submitPreConference(data);
    } else {
      ok = await prov.submitWorkshop(data);
    }

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Thank you for your submission. We will be in touch with you soon.'),
            backgroundColor: AppTheme.success),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(prov.error ?? 'Submission failed'),
            backgroundColor: AppTheme.danger),
      );
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _keyCtrl.dispose();
    _abstractCtrl.dispose();
    _backgroundCtrl.dispose();
    _rationaleCtrl.dispose();
    _objectiveCtrl.dispose();
    _outcomeCtrl.dispose();
    _structureCtrl.dispose();
    _descriptionCtrl.dispose();
    _participantCtrl.dispose();
    _participantDescCtrl.dispose();
    _maxParticipantsCtrl.dispose();
    _workshopOverviewCtrl.dispose();
    for (final a in _authors) for (final c in a.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == SubmissionType.preconference
        ? 'Pre-Conference Submission'
        : 'Workshop Submission';

    final isLoading = context.watch<ConferenceProvider>().loading;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dropdown(
                  'Sub-Theme',
                  _subTheme,
                  [
                    'Assessment in Competency Based Dental Education',
                    'Teaching & Learning in Competency Based Dental Education',
                    'Interprofessional Education in Dental Education',
                    'Translational Research in Competency Based Dental Education',
                    'Incorporation of Competency Based Dental Education in Primary Health Care',
                  ],
                  (v) => setState(() => _subTheme = v!)),
              const SizedBox(height: 12),
              _tf(_titleCtrl, 'Title of Paper', required: true),
              const SizedBox(height: 12),
              _tf(_keyCtrl, 'Keywords (max 10)', required: true),
              const SizedBox(height: 12),
              _tf(_abstractCtrl, 'Abstract', maxLines: 5, required: true),
              const SizedBox(height: 12),
              _dropdown(
                  'Type of Presentation',
                  _type,
                  ['Oral', 'Poster', 'Interactive'],
                  (v) => setState(() => _type = v!)),
              const SizedBox(height: 24),
              
              // Pre-conference and Workshop specific fields
              const Divider(thickness: 2),
              const SizedBox(height: 16),
              const Text('Abstract Submission Required Details',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary)),
              const SizedBox(height: 16),
              _tf(_backgroundCtrl, 'Background', maxLines: 5, required: true),
              const SizedBox(height: 12),
              _tf(_rationaleCtrl, 
                  widget.type == SubmissionType.preconference 
                      ? 'Rationale for the pre-conference workshop'
                      : 'Rationale for the workshop',
                  maxLines: 5, required: true),
              const SizedBox(height: 12),
              _tf(_objectiveCtrl, 'Learning objectives',
                  maxLines: 5, required: true),
              const SizedBox(height: 12),
              _tf(_outcomeCtrl, 'Intended outcomes',
                  maxLines: 5, required: true),
              const SizedBox(height: 12),
              _tf(_structureCtrl, 'Structure of workshop',
                  maxLines: 5, required: true),
              const SizedBox(height: 12),
              _tf(_descriptionCtrl,
                  'A description of the interaction anticipated during the session and a session itinerary with specifics and the approximate amount of time given for each activity (Activity 1/2/3)',
                  maxLines: 5, required: true),
              const SizedBox(height: 12),
              _tf(_participantCtrl, 'Who should participate?',
                  maxLines: 5, required: true),
              const SizedBox(height: 12),
              _tf(_participantDescCtrl,
                  'A description of the participants\' pearls of wisdom/take home messages, knowledge, or material they will acquire',
                  maxLines: 5, required: true),
              const SizedBox(height: 12),
              _tf(_maxParticipantsCtrl, 'Ideal maximum number of participants',
                  maxLines: 3, required: true),
              const SizedBox(height: 12),
              _tf(_workshopOverviewCtrl,
                  'Marketing workshop description: Give an overview of the workshop that will encourage and attract participants to sign up for the workshop (150 words maximum)',
                  maxLines: 5, required: true),
              const SizedBox(height: 24),
              
              const Text('Author(s)',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary)),
              const SizedBox(height: 8),
              ...List.generate(_authors.length, _authorCard),
              TextButton.icon(
                onPressed: _addAuthor,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Add Co-Author'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: AppTheme.primary))
                    : ElevatedButton(
                        onPressed: _submit, child: const Text('Submit')),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _authorCard(int i) {
    final a = _authors[i];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('Author ${i + 1}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppTheme.primary)),
            const Spacer(),
            if (i > 0)
              IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                      color: AppTheme.danger),
                  onPressed: () => _removeAuthor(i)),
          ]),
          Row(children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: a['prefix']!.text.isEmpty ? null : a['prefix']!.text,
                items: const [
                  DropdownMenuItem(value: 'Dr', child: Text('Dr')),
                  DropdownMenuItem(value: 'Mr', child: Text('Mr')),
                  DropdownMenuItem(value: 'Mrs', child: Text('Mrs')),
                  DropdownMenuItem(value: 'Miss', child: Text('Miss')),
                ],
                onChanged: (v) {
                  setState(() => a['prefix']!.text = v ?? '');
                },
                decoration: const InputDecoration(
                  labelText: 'Prefix',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(flex: 2, child: _tfRaw(a['first_name']!, 'First Name')),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _tfRaw(a['middle_name']!, 'Middle')),
            const SizedBox(width: 8),
            Expanded(child: _tfRaw(a['last_name']!, 'Last Name')),
          ]),
          const SizedBox(height: 8),
          _tfRaw(a['email']!, 'Email'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: a['author_type']!.text.isEmpty ? 'Author' : a['author_type']!.text,
            items: const [
              DropdownMenuItem(value: 'Presenting Author', child: Text('Presenting Author')),
              DropdownMenuItem(value: 'Co Author', child: Text('Co Author')),
              DropdownMenuItem(value: 'Author', child: Text('Author')),
            ],
            onChanged: (v) {
              setState(() => a['author_type']!.text = v ?? 'Author');
            },
            decoration: const InputDecoration(
              labelText: 'Author Type',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
          ),
          const SizedBox(height: 8),
          _tfRaw(a['designation']!, 'Designation'),
          const SizedBox(height: 8),
          _tfRaw(a['institution']!, 'Institution'),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _tfRaw(a['city']!, 'City')),
            const SizedBox(width: 8),
            Expanded(child: _tfRaw(a['state']!, 'State')),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _tfRaw(a['country']!, 'Country')),
            const SizedBox(width: 8),
            Expanded(child: _tfRaw(a['pincode']!, 'Pincode')),
          ]),
        ]),
      ),
    );
  }

  Widget _tf(TextEditingController c, String label,
          {int maxLines = 1, bool required = false}) =>
      TextFormField(
        controller: c,
        maxLines: maxLines,
        decoration:
            InputDecoration(labelText: label, alignLabelWithHint: maxLines > 1),
        validator:
            required ? (v) => v?.isEmpty == true ? 'Required' : null : null,
      );

  Widget _tfRaw(TextEditingController c, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: TextFormField(
          controller: c,
          decoration: InputDecoration(
              labelText: label,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
        ),
      );

  Widget _dropdown(String label, String val, List<String> items,
          ValueChanged<String?> fn) =>
      DropdownButtonFormField<String>(
        value: val,
        isExpanded: true,
        items: items
            .map((e) => DropdownMenuItem(
                value: e, child: Text(e)))
            .toList(),
        selectedItemBuilder: (context) => items
            .map((e) => Text(e, overflow: TextOverflow.ellipsis))
            .toList(),
        onChanged: fn,
        decoration: InputDecoration(labelText: label),
      );
}
