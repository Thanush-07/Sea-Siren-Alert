import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final regNoController = TextEditingController();

  final RegExp regNoPattern = RegExp(
    r'^IND(?:-|–)TN(?:-|–)(\d{2})(?:-|–)([A-Z]{2})(?:-|–)(\d{3,5})$',
    caseSensitive: true,
  );

  String normalizeRegNo(String s) =>
      s.toUpperCase().trim().replaceAll(RegExp(r'\s+'), '');

  Future<void> _login() async {
    final box = Hive.box('fisherman_box');
    final user = box.get('user') as Map?;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('பதிவு இல்லை (No registration found)')),
      );
      return;
    }
    final saved = (user['boatRegNo'] ?? '').toString();
    final entered = normalizeRegNo(regNoController.text);

    if (entered == saved) {
      await box.put('isLoggedIn', true);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (r) => false);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('தவறான பதிவு எண் (Invalid registration number)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('உள்நுழை (Login)')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      // Big centered logo
                      Center(
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          width: 180,   // make it big
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Center(
                        child: Text('Sea Siren Alert', style: TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(height: 24),

                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: regNoController,
                              decoration: const InputDecoration(
                                labelText: 'அதிகாரப்பூர்வ படகு பதிவு எண்',
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
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) _login();
                                },
                                child: const Text('உள்நுழை (Login)'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pushReplacementNamed('/register'),
                              child: const Text('புதிய பயனர்? பதிவு செய் (Register)'),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(), // pushes content up if there is extra space
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
