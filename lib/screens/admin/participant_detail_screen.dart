import 'package:flutter/material.dart';
import '../../models/registration_model.dart';
import '../../widgets/app_theme.dart';

class ParticipantDetailScreen extends StatelessWidget {
  final RegistrationModel reg;
  const ParticipantDetailScreen({super.key, required this.reg});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Participant Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.accent]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white24,
                  child: Text(
                    reg.fullName.isNotEmpty ? reg.fullName[0].toUpperCase() : '?',
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text('${reg.title} ${reg.fullName}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text(reg.registrationCode,
                    style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                StatusBadge(status: reg.isActive ? 'Active' : 'Pending'),
              ]),
            ),
            const SizedBox(height: 16),

            // Details table
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _row('Registration ID', reg.registrationCode),
                    _row('Type of Delegate', reg.typeOfDelegate),
                    _row('Name', '${reg.title} ${reg.fullName}'),
                    _row('Age', reg.age),
                    _row('Gender', reg.gender),
                    _row('Designation', reg.designation),
                    _row('Name of the College', reg.institution),
                    _row('Name of the University', reg.universityName),
                    _row('Full Address', reg.fullAddress),
                    _row('City', reg.city),
                    _row('State', reg.state),
                    _row('Country', reg.country),
                    _row('Pin Code', reg.pincode),
                    _row('Email Address', reg.email),
                    _row('Mobile No', reg.phone),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                    fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
