// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/conference_provider.dart';
// import '../../widgets/app_theme.dart';

// class AbstractSubmitScreen extends StatefulWidget {
//   const AbstractSubmitScreen({super.key});

//   @override
//   State<AbstractSubmitScreen> createState() => _AbstractSubmitScreenState();
// }

// class _AbstractSubmitScreenState extends State<AbstractSubmitScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleCtrl = TextEditingController();
//   final _keywordsCtrl = TextEditingController();
//   final _abstractCtrl = TextEditingController();

//   String _subTheme = 'Blended Learning Strategies in Dental Education';
//   String _typePresentation = 'Oral Presentations for research submission';
//   String _catPresentation = 'Systematic Review / Metanalysis';

//   // Author management
//   final List<Map<String, TextEditingController>> _authors = [];

//   @override
//   void initState() {
//     super.initState();
//     _addAuthor(); // start with one author
//   }

//   void _addAuthor() {
//     _authors.add({
//       'prefix': TextEditingController(),
//       'first_name': TextEditingController(),
//       'middle_name': TextEditingController(),
//       'last_name': TextEditingController(),
//       'email': TextEditingController(),
//       'author_type': TextEditingController(text: 'Co Author'),
//       'designation': TextEditingController(),
//       'institution': TextEditingController(),
//       'city': TextEditingController(),
//       'state': TextEditingController(),
//       'country': TextEditingController(),
//       'pincode': TextEditingController(),
//     });
//     setState(() {});
//   }

//   void _removeAuthor(int i) {
//     for (final c in _authors[i].values) c.dispose();
//     _authors.removeAt(i);
//     setState(() {});
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;

//     final auth = context.read<AuthProvider>().user;
//     final prov = context.read<ConferenceProvider>();

//     final authorsData = _authors
//         .map((a) => {
//               'prefix': a['prefix']!.text.trim(),
//               'first_name': a['first_name']!.text.trim(),
//               'middle_name': a['middle_name']!.text.trim(),
//               'last_name': a['last_name']!.text.trim(),
//               'email': a['email']!.text.trim(),
//               'author_type': a['author_type']!.text.trim(),
//               'designation': a['designation']!.text.trim(),
//               'institution': a['institution']!.text.trim(),
//               'city': a['city']!.text.trim(),
//               'state': a['state']!.text.trim(),
//               'country': a['country']!.text.trim(),
//               'pincode': a['pincode']!.text.trim(),
//             })
//         .toList();

//     final data = {
//       'register_id': auth?.userId ?? '',
//       'sub_themes': _subTheme,
//       'type_presentation': _typePresentation,
//       'cat_presentation': _catPresentation,
//       'title_paper': _titleCtrl.text.trim(),
//       'keywords': _keywordsCtrl.text.trim(),
//       'abstract_details': _abstractCtrl.text.trim(),
//       'authors': authorsData,
//     };

//     final ok = await prov.submitAbstract(data);
//     if (!mounted) return;

//     if (ok) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Thank you for your submission. We will be in touch with you soon.'),
//           backgroundColor: AppTheme.success,
//         ),
//       );
//       Navigator.pop(context, true);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(prov.error ?? 'Submission failed'),
//           backgroundColor: AppTheme.danger,
//         ),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _titleCtrl.dispose();
//     _keywordsCtrl.dispose();
//     _abstractCtrl.dispose();
//     for (final a in _authors) for (final c in a.values) c.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isLoading = context.watch<ConferenceProvider>().loading;

//     return Scaffold(
//       appBar: AppBar(title: const Text('Submit Abstract')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _sectionTitle('Submission Details'),
//               const SizedBox(height: 12),
//               _dropdown(
//                   'Sub-Theme',
//                   _subTheme,
//                   [
//                     'Blended Learning Strategies in Dental Education',
//                     'Virtual Simulations and Hands-On Training: Bridging the Gap',
//                     'Enhancing Student Engagement in Hybrid Learning Environments',
//                     'Artificial Intelligence in dentistry',
//                     'Quality assurance in dentistry and its applications in Blended Learning',
//                     'Technology-Driven Innovations in Dental Education',
//                     'Assessment and Feedback in Hybrid Learning Models',
//                     'Faculty Development for Effective Hybrid Teaching',
//                     'Global Collaboration in Hybrid Dental Education',
//                     'Speciality Presentation',
//                   ],
//                   (v) => setState(() => _subTheme = v!)),
//               const SizedBox(height: 12),
//               _dropdown(
//                   'Type of Presentation',
//                   _typePresentation,
//                   [
//                     'Oral Presentations for research submission',
//                     'Oral Presentations for Speciality Research',
//                     'Posters',
//                     'Yenvision- Lightning talk',
//                   ],
//                   (v) => setState(() => _typePresentation = v!)),
//               const SizedBox(height: 12),
//               _dropdown(
//                   'Category of Presentation',
//                   _catPresentation,
//                   [
//                     'Systematic Review / Metanalysis',
//                     'Narrative Review',
//                     'Original Research Medical / Dental Education',
//                     'Interprofessional Research',
//                   ],
//                   (v) => setState(() => _catPresentation = v!)),
//               const SizedBox(height: 12),
//               _textField(_titleCtrl, 'Title of Paper', Icons.title,
//                   required: true),
//               const SizedBox(height: 12),
//               _textField(_keywordsCtrl, 'Keywords', Icons.label_outline,
//                   hint: 'Maximum 10 words', required: true),
//               const SizedBox(height: 12),
//               _textField(_abstractCtrl, 'Abstract Details (max 400 words)', Icons.article_outlined,
//                   hint: 'Submit Under Following Headings (Introduction, Objective(s) of the study, Methodology, Results, Conclusion)',
//                   maxLines: 6, required: true),
//               const SizedBox(height: 24),
//               _sectionTitle('Author(s) Details'),
//               const SizedBox(height: 12),
//               ...List.generate(_authors.length, (i) => _authorForm(i)),
//               TextButton.icon(
//                 onPressed: _addAuthor,
//                 icon: const Icon(Icons.add_circle_outline),
//                 label: const Text('Add Co-Author'),
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: isLoading
//                     ? const Center(
//                         child:
//                             CircularProgressIndicator(color: AppTheme.primary))
//                     : ElevatedButton(
//                         onPressed: _submit,
//                         child: const Text('Submit Abstract'),
//                       ),
//               ),
//               const SizedBox(height: 40),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _authorForm(int i) {
//     final a = _authors[i];
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(children: [
//               Text('Author ${i + 1}',
//                   style: const TextStyle(
//                       fontWeight: FontWeight.bold, color: AppTheme.primary)),
//               const Spacer(),
//               if (i > 0)
//                 IconButton(
//                   icon:
//                       const Icon(Icons.delete_outline, color: AppTheme.danger),
//                   onPressed: () => _removeAuthor(i),
//                 ),
//             ]),
//             const SizedBox(height: 12),
//             Row(children: [
//               Expanded(
//                 child: DropdownButtonFormField<String>(
//                   value: a['prefix']!.text.isEmpty ? null : a['prefix']!.text,
//                   items: const [
//                     DropdownMenuItem(value: 'Dr', child: Text('Dr')),
//                     DropdownMenuItem(value: 'Mr', child: Text('Mr')),
//                     DropdownMenuItem(value: 'Mrs', child: Text('Mrs')),
//                     DropdownMenuItem(value: 'Miss', child: Text('Miss')),
//                   ],
//                   onChanged: (v) {
//                     setState(() => a['prefix']!.text = v ?? '');
//                   },
//                   decoration: const InputDecoration(
//                     labelText: 'Prefix',
//                     isDense: true,
//                     contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                   flex: 2,
//                   child: _textFieldRaw(a['first_name']!, 'First Name')),
//             ]),
//             const SizedBox(height: 8),
//             Row(children: [
//               Expanded(child: _textFieldRaw(a['middle_name']!, 'Middle Name')),
//               const SizedBox(width: 8),
//               Expanded(child: _textFieldRaw(a['last_name']!, 'Last Name')),
//             ]),
//             const SizedBox(height: 8),
//             _textFieldRaw(a['email']!, 'Email'),
//             const SizedBox(height: 8),
//             DropdownButtonFormField<String>(
//               value: a['author_type']!.text.isEmpty ? 'Co Author' : a['author_type']!.text,
//               items: const [
//                 DropdownMenuItem(value: 'Presenting Author', child: Text('Presenting Author')),
//                 DropdownMenuItem(value: 'Co Author', child: Text('Co Author')),
//               ],
//               onChanged: (v) {
//                 setState(() => a['author_type']!.text = v ?? 'Co Author');
//               },
//               decoration: const InputDecoration(
//                 labelText: 'Author Type',
//                 isDense: true,
//                 contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//               ),
//             ),
//             const SizedBox(height: 8),
//             _textFieldRaw(a['designation']!, 'Designation'),
//             const SizedBox(height: 8),
//             _textFieldRaw(a['institution']!, 'Institution'),
//             const SizedBox(height: 8),
//             Row(children: [
//               Expanded(child: _textFieldRaw(a['city']!, 'City')),
//               const SizedBox(width: 8),
//               Expanded(child: _textFieldRaw(a['state']!, 'State')),
//             ]),
//             const SizedBox(height: 8),
//             Row(children: [
//               Expanded(child: _textFieldRaw(a['country']!, 'Country')),
//               const SizedBox(width: 8),
//               Expanded(child: _textFieldRaw(a['pincode']!, 'Pincode')),
//             ]),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _sectionTitle(String t) => Text(t,
//       style: const TextStyle(
//           fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary));

//   Widget _textField(TextEditingController ctrl, String label, IconData icon,
//           {String? hint, int maxLines = 1, bool required = false}) =>
//       TextFormField(
//         controller: ctrl,
//         maxLines: maxLines,
//         decoration: InputDecoration(
//             labelText: label,
//             hintText: hint,
//             prefixIcon: maxLines == 1 ? Icon(icon) : null,
//             alignLabelWithHint: maxLines > 1),
//         validator: required
//             ? (v) => (v == null || v.isEmpty) ? 'Required' : null
//             : null,
//       );

//   Widget _textFieldRaw(TextEditingController ctrl, String label) =>
//       TextFormField(
//         controller: ctrl,
//         decoration: InputDecoration(
//             labelText: label,
//             isDense: true,
//             contentPadding:
//                 const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
//       );

//   Widget _dropdown(String label, String value, List<String> items,
//           ValueChanged<String?> onChanged) =>
//       DropdownButtonFormField<String>(
//         value: value,
//         isExpanded: true,
//         items: items
//             .map((e) => DropdownMenuItem(
//                 value: e, child: Text(e)))
//             .toList(),
//         selectedItemBuilder: (context) => items
//             .map((e) => Text(e, overflow: TextOverflow.ellipsis))
//             .toList(),
//         onChanged: onChanged,
//         decoration: InputDecoration(labelText: label),
//       );
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/conference_provider.dart';
import '../../widgets/app_theme.dart';

class AbstractSubmitScreen extends StatefulWidget {
  const AbstractSubmitScreen({super.key});

  @override
  State<AbstractSubmitScreen> createState() => _AbstractSubmitScreenState();
}

class _AbstractSubmitScreenState extends State<AbstractSubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _keywordsCtrl = TextEditingController();
  final _abstractCtrl = TextEditingController();

  String _typePresentation = 'Oral Presentations for research submission';
  String? _subTheme;
  String? _catPresentation;

  // ── Static option lists ───────────────────────────────────────────────────

  static const List<String> _educationSubThemes = [
    'Assessment and Competency-Based Education',
    'Teaching–Learning Innovations in the Digital Era',
    'Quality Enhancement and Accreditation in Dental Education',
    'Interprofessional Education and Collaborative Practice (IPE)',
    'AI, Empathy, and Ethics in Modern Dental Practice',
    'Faculty Development and Leadership for the Future',
  ];

  static const List<String> _specialtySubThemes = [
    'Orthodontics',
    'Pedodontics',
    'Public Health Dentistry',
    'Periodontics',
    'Oral Surgery',
    'Oral Medicine and Radiology',
    'Prosthodontics',
    'Implantology',
    'Dental Materials',
    'Oral Pathology',
  ];

  static const List<String> _categoryOptions = [
    'Systematic Review / Metanalysis',
    'Narrative Review',
    'Original Research Medical / Dental Education',
    'Interprofessional Research',
  ];

  // ── Dynamic sub-theme list based on selected type ─────────────────────────

  List<String> get _subThemeOptions {
    switch (_typePresentation) {
      case 'Oral Presentations for Speciality Research':
        return _specialtySubThemes;
      case 'Posters':
        return [..._educationSubThemes, ..._specialtySubThemes];
      // 'Oral Presentations for research submission' & 'Yenvision- Lightning talk'
      default:
        return _educationSubThemes;
    }
  }

  // Author management
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
      'author_type': TextEditingController(text: 'Co Author'),
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
      'register_id': auth?.userId ?? '',
      'type_presentation': _typePresentation,
      'sub_themes': _subTheme ?? '',
      'cat_presentation': _catPresentation ?? '',
      'title_paper': _titleCtrl.text.trim(),
      'keywords': _keywordsCtrl.text.trim(),
      'abstract_details': _abstractCtrl.text.trim(),
      'authors': authorsData,
    };

    final ok = await prov.submitAbstract(data);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Thank you for your submission. We will be in touch with you soon.'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(prov.error ?? 'Submission failed'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _keywordsCtrl.dispose();
    _abstractCtrl.dispose();
    for (final a in _authors) for (final c in a.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ConferenceProvider>().loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Submit Abstract')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Submission Details'),
              const SizedBox(height: 12),

              // 1️⃣ Type of Presentation
              _dropdown(
                'Type of Presentation',
                _typePresentation,
                [
                  'Oral Presentations for research submission',
                  'Oral Presentations for Speciality Research',
                  'Posters',
                  'Yenvision- Lightning talk',
                ],
                (v) => setState(() {
                  _typePresentation = v!;
                  _subTheme = null;     // reset sub-theme on type change
                  _catPresentation = null; // reset category on type change
                }),
              ),
              const SizedBox(height: 12),

              // 2️⃣ Sub-Theme (dynamic based on type)
              _dropdownNullable(
                'Sub-Theme',
                _subTheme,
                _subThemeOptions,
                (v) => setState(() => _subTheme = v),
              ),
              const SizedBox(height: 12),

              // 3️⃣ Category of Presentation (always same 4 options)
              _dropdownNullable(
                'Category of Presentation',
                _catPresentation,
                _categoryOptions,
                (v) => setState(() => _catPresentation = v),
              ),
              const SizedBox(height: 12),

              _textField(_titleCtrl, 'Title of Paper', Icons.title,
                  required: true),
              const SizedBox(height: 12),
              _textField(_keywordsCtrl, 'Keywords', Icons.label_outline,
                  hint: 'Maximum 10 words', required: true),
              const SizedBox(height: 12),
              _textField(
                _abstractCtrl,
                'Abstract Details (max 400 words)',
                Icons.article_outlined,
                hint:
                    'Submit Under Following Headings (Introduction, Objective(s) of the study, Methodology, Results, Conclusion)',
                maxLines: 6,
                required: true,
              ),
              const SizedBox(height: 24),

              _sectionTitle('Author(s) Details'),
              const SizedBox(height: 12),
              ...List.generate(_authors.length, (i) => _authorForm(i)),
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
                        child: CircularProgressIndicator(
                            color: AppTheme.primary))
                    : ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Submit Abstract'),
                      ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _authorForm(int i) {
    final a = _authors[i];
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('Author ${i + 1}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppTheme.primary)),
              const Spacer(),
              if (i > 0)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppTheme.danger),
                  onPressed: () => _removeAuthor(i),
                ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value:
                      a['prefix']!.text.isEmpty ? null : a['prefix']!.text,
                  items: const [
                    DropdownMenuItem(value: 'Dr', child: Text('Dr')),
                    DropdownMenuItem(value: 'Mr', child: Text('Mr')),
                    DropdownMenuItem(value: 'Mrs', child: Text('Mrs')),
                    DropdownMenuItem(value: 'Miss', child: Text('Miss')),
                  ],
                  onChanged: (v) => setState(() => a['prefix']!.text = v ?? ''),
                  decoration: const InputDecoration(
                    labelText: 'Prefix',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                  flex: 2,
                  child: _textFieldRaw(a['first_name']!, 'First Name')),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _textFieldRaw(a['middle_name']!, 'Middle Name')),
              const SizedBox(width: 8),
              Expanded(child: _textFieldRaw(a['last_name']!, 'Last Name')),
            ]),
            const SizedBox(height: 8),
            _textFieldRaw(a['email']!, 'Email'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: a['author_type']!.text.isEmpty
                  ? 'Co Author'
                  : a['author_type']!.text,
              items: const [
                DropdownMenuItem(
                    value: 'Presenting Author',
                    child: Text('Presenting Author')),
                DropdownMenuItem(
                    value: 'Co Author', child: Text('Co Author')),
              ],
              onChanged: (v) =>
                  setState(() => a['author_type']!.text = v ?? 'Co Author'),
              decoration: const InputDecoration(
                labelText: 'Author Type',
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 8),
            _textFieldRaw(a['designation']!, 'Designation'),
            const SizedBox(height: 8),
            _textFieldRaw(a['institution']!, 'Institution'),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _textFieldRaw(a['city']!, 'City')),
              const SizedBox(width: 8),
              Expanded(child: _textFieldRaw(a['state']!, 'State')),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _textFieldRaw(a['country']!, 'Country')),
              const SizedBox(width: 8),
              Expanded(child: _textFieldRaw(a['pincode']!, 'Pincode')),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.primary));

  Widget _textField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    String? hint,
    int maxLines = 1,
    bool required = false,
  }) =>
      TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: maxLines == 1 ? Icon(icon) : null,
          alignLabelWithHint: maxLines > 1,
        ),
        validator: required
            ? (v) => (v == null || v.isEmpty) ? 'Required' : null
            : null,
      );

  Widget _textFieldRaw(TextEditingController ctrl, String label) =>
      TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      );

  // For non-nullable dropdowns (Type of Presentation)
  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) =>
      DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        selectedItemBuilder: (context) =>
            items.map((e) => Text(e, overflow: TextOverflow.ellipsis)).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label),
      );

  // For nullable dropdowns (Sub-Theme, Category) — resets cleanly on type change
  Widget _dropdownNullable(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) =>
      DropdownButtonFormField<String>(
        value: (value != null && items.contains(value)) ? value : null,
        isExpanded: true,
        hint: const Text('Please select'),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        selectedItemBuilder: (context) =>
            items.map((e) => Text(e, overflow: TextOverflow.ellipsis)).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label),
        validator: (v) => v == null ? 'Required' : null,
      );
}