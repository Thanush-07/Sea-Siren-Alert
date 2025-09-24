import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});
  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final villageController = TextEditingController();
  final regNoController = TextEditingController();

  // Accepts both hyphen (-) and en-dash (–) as separators
  // Pattern: IND–TN–<2 digits>–<2 uppercase letters>–<3 to 5 digits>
  final RegExp regNoPattern = RegExp(
    r'^IND(?:-|–)TN(?:-|–)(\d{2})(?:-|–)([A-Z]{2})(?:-|–)(\d{3,5})$',
    caseSensitive: true,
  );

  String normalizeRegNo(String input) {
    // Uppercase, trim, collapse spaces, normalize separators to en-dash visually (optional)
    final s = input.toUpperCase().trim().replaceAll(RegExp(r'\s+'), '');
    return s;
  }

  Future<void> _register() async {
    final box = Hive.box('fisherman_box');
    final user = {
      'name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'village': villageController.text.trim(),
      'boatRegNo': normalizeRegNo(regNoController.text),
    };
    await box.put('user', user);
    await box.put('isLoggedIn', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('பதிவு (Registration)')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // App logo and name at top
              Image.asset('assets/images/app_logo.png', width: 120, height: 120),
              const SizedBox(height: 8),
              const Text('Sea Siren Alert', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'பெயர் (Name)'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'பெயரை உள்ளிடவும்' : null,
                    ),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'தொலைபேசி (Phone)'),
                      keyboardType: TextInputType.phone,
                      validator: (v) => (v == null || v.trim().length < 8) ? 'சரியான எண்ணை உள்ளிடவும்' : null,
                    ),
                    TextFormField(
                      controller: villageController,
                      decoration: const InputDecoration(labelText: 'கிராமம் (Village)'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'கிராமத்தை உள்ளிடவும்' : null,
                    ),
                    TextFormField(
                      controller: regNoController,
                      decoration: const InputDecoration(
                        labelText: 'அதிகாரப்பூர்வ படகு பதிவு எண் (Official Boat Registration No.)',
                        hintText: 'IND–TN–05–MF–1234',
                      ),
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) {
                        final value = normalizeRegNo(v ?? '');
                        if (value.isEmpty) return 'பதிவு எண்ணை உள்ளிடவும்';
                        if (!regNoPattern.hasMatch(value)) {
                          return 'வடிவம்: IND–TN–NN–TT–NNN (எ.கா. IND–TN–05–MF–1234)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) _register();
                      },
                      child: const Text('பதிவு செய் (Register)'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                      child: const Text('ஏற்கனவே பதிவு? உள்நுழை (Login)'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
