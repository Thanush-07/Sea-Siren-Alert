import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user_model.dart';
import 'home_screen.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _phone = '';
  String _language = 'Tamil';  // Default for Tamil people

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('பதிவு / Registration')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'பெயர் / Name'),
                onChanged: (val) => _name = val,
                validator: (val) => val!.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'தொலைபேசி / Phone Number'),
                keyboardType: TextInputType.phone,
                onChanged: (val) => _phone = val,
                validator: (val) => val!.length < 10 ? 'Enter valid phone' : null,
              ),
              DropdownButtonFormField<String>(
                value: _language,
                items: ['Tamil', 'English'].map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
                onChanged: (val) => setState(() => _language = val!),
                decoration: InputDecoration(labelText: 'எச்சரிக்கை மொழி / Language for Alerts'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    var user = UserModel(name: _name, phone: _phone, language: _language);
                    Hive.box('userBox').put('user', user);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
                  }
                },
                child: Text('பதிவு செய்யவும் / Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}