// lib/screens/auth/signup_screen.dart
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  String _fullName = '';
  String _nationalId = '';
  String _phone = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _preferredContact = 'Phone';
  bool _isSubmitting = false;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_password != _confirmPassword) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final auth = AuthService();

      // No one can sign up as admin; all registered users are renters.
      final user = auth.registerRenter(
        fullName: _fullName,
        nationalId: _nationalId,
        phone: _phone,
        email: _email,
        password: _password,
        preferredContactMethod: _preferredContact,
      );

      // Go directly to home as the new renter.
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home', arguments: user);
    } on StateError catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Sign up as renter',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                  onSaved: (value) => _fullName = value!.trim(),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'National ID (9 digits)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    final v = value.trim();
                    if (v.length != 9 || int.tryParse(v) == null) {
                      return 'Must be exactly 9 digits';
                    }
                    return null;
                  },
                  onSaved: (value) => _nationalId = value!.trim(),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Phone number (8 digits)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    final v = value.trim();
                    if (v.length != 8 || int.tryParse(v) == null) {
                      return 'Must be exactly 8 digits';
                    }
                    return null;
                  },
                  onSaved: (value) => _phone = value!.trim(),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    if (!value.contains('@')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                  onSaved: (value) => _email = value!.trim(),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (value.length < 6) {
                      return 'At least 6 characters';
                    }
                    return null;
                  },
                  onSaved: (value) => _password = value!,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Confirm password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                  onSaved: (value) => _confirmPassword = value!,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _preferredContact,
                  items: const [
                    DropdownMenuItem(value: 'Phone', child: Text('Phone')),
                    DropdownMenuItem(value: 'Email', child: Text('Email')),
                    DropdownMenuItem(value: 'WhatsApp', child: Text('WhatsApp')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Preferred contact method',
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _preferredContact = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: Text(_isSubmitting ? 'Creating account...' : 'Sign up'),
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
