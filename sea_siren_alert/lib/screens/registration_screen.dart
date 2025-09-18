import 'package:flutter/material.dart';
import 'package:sea_siren_alert/models/user_model.dart';
import 'package:sea_siren_alert/screens/home_screen.dart';
import 'package:sea_siren_alert/services/storage_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _phone = '';
  String _language = 'ta';  // Default Tamil

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registration')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (val) => _name = val,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                onChanged: (val) => _phone = val,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                value: _language,
                items: const [
                  DropdownMenuItem(value: 'ta', child: Text('Tamil')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                ],
                onChanged: (val) => setState(() => _language = val!),
                decoration: const InputDecoration(labelText: 'Language for Alerts'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final user = UserModel(name: _name, phone: _phone, language: _language);
                    StorageService.saveUser(user);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                  }
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}