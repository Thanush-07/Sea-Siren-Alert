import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../utils/constants.dart';

class RegistrationPage extends StatefulWidget {
  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final villageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('பதிவு')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'பெயர்'),
                validator: (value) =>
                    value!.isEmpty ? 'பெயரை உள்ளிடவும்' : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'தொலைபேசி எண்'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? 'தொலைபேசி எண்ணை உள்ளிடவும்' : null,
              ),
              TextFormField(
                controller: villageController,
                decoration: const InputDecoration(labelText: 'கிராமம்'),
                validator: (value) =>
                    value!.isEmpty ? 'கிராமத்தை உள்ளிடவும்' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final box = Hive.box(kHiveBox);
                    await box.put('user', {
                      'name': nameController.text,
                      'phone': phoneController.text,
                      'village': villageController.text,
                    });
                    Get.offNamed('/home');
                  }
                },
                child: const Text('பதிவு செய்'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
