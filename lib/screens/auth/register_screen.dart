import 'package:flutter/material.dart';
// import 'package:provider/provider.dart'; // unused
import '../../providers/conference_provider.dart';
import '../../services/conference_service.dart';
import '../../widgets/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Controllers
  final _fullNameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _designationCtrl = TextEditingController();
  final _institutionCtrl = TextEditingController();
  final _departmentCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  String _title = 'Dr.';
  String _gender = 'Male';
  String _delegateType = 'Faculty';
  bool _ifdhe = false;
  bool _abstractSub = false;
  bool _preconf = false;
  bool _workshop = false;

  @override
  void dispose() {
    for (final c in [
      _fullNameCtrl,
      _ageCtrl,
      _designationCtrl,
      _institutionCtrl,
      _departmentCtrl,
      _addressCtrl,
      _cityCtrl,
      _stateCtrl,
      _countryCtrl,
      _pincodeCtrl,
      _phoneCtrl,
      _emailCtrl,
    ]) c.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'title': _title,
      'full_name': _fullNameCtrl.text.trim(),
      'age': _ageCtrl.text.trim(),
      'gender': _gender,
      'type_of_delegate': _delegateType,
      'designation': _designationCtrl.text.trim(),
      'institution': _institutionCtrl.text.trim(),
      'department': _departmentCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'state': _stateCtrl.text.trim(),
      'country': _countryCtrl.text.trim(),
      'pincode': _pincodeCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'ifdhe_member': _ifdhe ? '1' : '0',
      'abstract_submission': _abstractSub ? '1' : '0',
      'preconference': _preconf ? '1' : '0',
      'workshop': _workshop ? '1' : '0',
      'accompanied_by': '',
      'membership_id': '',
      'dietary_requirement': '',
      'special_assistance': '',
    };

    final service = ConferenceService();
    final res = await service.register(data);

    if (!mounted) return;

    if (res['status'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Thank you for registering with us. You will receive an email with further details including payment link. Kindly make the payment in order to complete your registration.'),
          backgroundColor: AppTheme.success,
          duration: Duration(seconds: 6),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Registration failed'),
          backgroundColor: AppTheme.danger,
        ),
      );
      print(res['message'] ?? 'Registration failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conference Registration')),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep++);
            } else {
              _submit();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0)
              setState(() => _currentStep--);
            else
              Navigator.pop(context);
          },
          steps: [
            _buildPersonalStep(),
            _buildContactStep(),
            _buildPreferencesStep(),
          ],
        ),
      ),
    );
  }

  Step _buildPersonalStep() => Step(
        title: const Text('Personal Info'),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        content: Column(children: [
          _dropdownField(
              'Name Prefix',
              _title,
              ['Dr.', 'Prof.', 'Mr.', 'Mrs.', 'Miss.'],
              (v) => setState(() => _title = v!)),
          const SizedBox(height: 12),
          _textField(_fullNameCtrl, 'Full Name', Icons.person_outline),
          const SizedBox(height: 12),
          _textField(_ageCtrl, 'Age', Icons.cake_outlined,
              keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          _dropdownField('Gender', _gender, ['Male', 'Female', 'Other'],
              (v) => setState(() => _gender = v!)),
          const SizedBox(height: 12),
          _dropdownField(
              'Type of Delegate',
              _delegateType,
              [
                'Faculty',
                'Post-Graduate',
                'Under-Graduate',
                'Industry Professional',
                'Other'
              ],
              (v) => setState(() => _delegateType = v!)),
          const SizedBox(height: 12),
          _textField(_designationCtrl, 'Designation', Icons.work_outline),
          const SizedBox(height: 12),
          _textField(_institutionCtrl, 'Institution', Icons.school_outlined),
          const SizedBox(height: 12),
          _textField(_departmentCtrl, 'Department', Icons.category_outlined),
        ]),
      );

  Step _buildContactStep() => Step(
        title: const Text('Contact Details'),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        content: Column(children: [
          _textField(_addressCtrl, 'Address', Icons.home_outlined, maxLines: 2),
          const SizedBox(height: 12),
          _textField(_cityCtrl, 'City', Icons.location_city_outlined),
          const SizedBox(height: 12),
          _textField(_stateCtrl, 'State', Icons.map_outlined),
          const SizedBox(height: 12),
          _textField(_countryCtrl, 'Country', Icons.flag_outlined),
          const SizedBox(height: 12),
          _textField(_pincodeCtrl, 'Pincode', Icons.pin_outlined,
              keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          _textField(_phoneCtrl, 'Phone', Icons.phone_outlined,
              keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          _textField(_emailCtrl, 'Email', Icons.email_outlined,
              keyboardType: TextInputType.emailAddress),
        ]),
      );

  Step _buildPreferencesStep() => Step(
        title: const Text('Preferences'),
        isActive: _currentStep >= 2,
        content:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Interested in:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          CheckboxListTile(
            title: const Text('Abstract Submission'),
            value: _abstractSub,
            onChanged: (v) => setState(() => _abstractSub = v!),
          ),
          CheckboxListTile(
            title: const Text('Pre-Conference Workshop'),
            value: _preconf,
            onChanged: (v) => setState(() => _preconf = v!),
          ),
          CheckboxListTile(
            title: const Text('Workshop'),
            value: _workshop,
            onChanged: (v) => setState(() => _workshop = v!),
          ),
          CheckboxListTile(
            title: const Text('IFDHE Member'),
            value: _ifdhe,
            onChanged: (v) => setState(() => _ifdhe = v!),
          ),
        ]),
      );

  Widget _textField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    bool obscureText = false,
    int maxLines = 1,
  }) =>
      TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
      );

  Widget _dropdownField(
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
        selectedItemBuilder: (context) => items
            .map((e) => Text(e, overflow: TextOverflow.ellipsis))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label),
      );
}

// Extension to access private service for submit from screen
extension _ConferenceProviderX on ConferenceProvider {
  // ignore: unused_element
  get _service => (this as dynamic)._service;
}
