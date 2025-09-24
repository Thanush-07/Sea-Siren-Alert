import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _village;
  late final TextEditingController _boatRegNo;
  late final TextEditingController _sosPhone;

  bool _argsApplied = false; // ensure we only read args once

  @override
  void initState() {
    super.initState();
    // Create controllers with empty text; do NOT read ModalRoute here
    _name = TextEditingController();
    _phone = TextEditingController();
    _village = TextEditingController();
    _boatRegNo = TextEditingController();
    _sosPhone = TextEditingController();

    // Optionally preload from Hive if desired (not required)
    final box = Hive.box('fisherman_box');
    final u = (box.get('user') as Map?) ?? {};
    _name.text = (u['name'] ?? '').toString();
    _phone.text = (u['phone'] ?? '').toString();
    _village.text = (u['village'] ?? '').toString();
    _boatRegNo.text = (u['boatRegNo'] ?? '').toString();
    _sosPhone.text = (u['sosPhone'] ?? '').toString();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safe place to use ModalRoute.of(context)
    if (_argsApplied) return;
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null) {
      _name.text = (args['name'] ?? _name.text).toString();
      _phone.text = (args['phone'] ?? _phone.text).toString();
      _village.text = (args['village'] ?? _village.text).toString();
      _boatRegNo.text = (args['boatRegNo'] ?? _boatRegNo.text).toString();
      _sosPhone.text = (args['sosPhone'] ?? _sosPhone.text).toString();
    }
    _argsApplied = true;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _village.dispose();
    _boatRegNo.dispose();
    _sosPhone.dispose();
    super.dispose();
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'தேவை' : null;

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'தொலைபேசி எண்ணை உள்ளிடவும்';
    final s = v.trim();
    final re = RegExp(r'^(?:\+91[\s-]?)?[6-9]\d{9}$');
    if (!re.hasMatch(s)) return 'சரியான தொலைபேசி எண்ணை உள்ளிடவும்';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final box = Hive.box('fisherman_box');
    final user = {
      'name': _name.text.trim(),
      'phone': _phone.text.trim(),
      'village': _village.text.trim(),
      'boatRegNo': _boatRegNo.text.trim(),
      'sosPhone': _sosPhone.text.trim(),
    };
    await box.put('user', user);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('சுயவிவரம் திருத்தம்')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'பெயர்', border: OutlineInputBorder()),
              validator: _req,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              decoration: const InputDecoration(labelText: 'தொலைபேசி (10 இலக்கம்)', border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
              validator: _validatePhone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _village,
              decoration: const InputDecoration(labelText: 'கிராமம் / துறைமுகம்', border: OutlineInputBorder()),
              validator: _req,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _boatRegNo,
              decoration: const InputDecoration(labelText: 'படகு பதிவு எண்', border: OutlineInputBorder()),
              validator: _req,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _sosPhone,
              decoration: const InputDecoration(labelText: 'SOS எண் (ஒரு எண்)', border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
              validator: _validatePhone,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('சேமிக்கவும்'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
