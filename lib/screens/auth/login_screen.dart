// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import '../../models/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _phone = '';
  String _preferredContact = 'Phone';
  UserRole _selectedRole = UserRole.renter;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _name,
      email: _email,
      phone: _phone,
      preferredContactMethod: _preferredContact,
      role: _selectedRole,
    );

    Navigator.of(context).pushReplacementNamed('/home', arguments: user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Care Center Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  'Sign in or continue as guest',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Required' : null,
                  onSaved: (value) => _name = value!.trim(),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Required' : null,
                  onSaved: (value) => _email = value!.trim(),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Phone'),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Required' : null,
                  onSaved: (value) => _phone = value!.trim(),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _preferredContact,
                  items: const [
                    DropdownMenuItem(value: 'Phone', child: Text('Phone')),
                    DropdownMenuItem(value: 'Email', child: Text('Email')),
                    DropdownMenuItem(value: 'WhatsApp', child: Text('WhatsApp')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Preferred Contact Method',
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _preferredContact = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Role',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<UserRole>(
                        title: const Text('Admin'),
                        value: UserRole.admin,
                        groupValue: _selectedRole,
                        onChanged: (value) =>
                            setState(() => _selectedRole = value!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<UserRole>(
                        title: const Text('Renter'),
                        value: UserRole.renter,
                        groupValue: _selectedRole,
                        onChanged: (value) =>
                            setState(() => _selectedRole = value!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<UserRole>(
                        title: const Text('Guest'),
                        value: UserRole.guest,
                        groupValue: _selectedRole,
                        onChanged: (value) =>
                            setState(() => _selectedRole = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
