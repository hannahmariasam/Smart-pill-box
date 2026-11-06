import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'auth_helpers.dart';

// ---------------- Registration ----------------
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _relation = TextEditingController();
  final _patientName = TextEditingController();
  final _patientAge = TextEditingController();
  final _patientCondition = TextEditingController();
  UserRole _role = UserRole.caregiver;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    _relation.dispose();
    _patientName.dispose();
    _patientAge.dispose();
    _patientCondition.dispose();
    super.dispose();
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;
    Session.role = _role;
    Session.name = _name.text.trim();
    Session.email = _email.text.trim();
    Session.phone = _phone.text.trim();
    Session.relation =
        _role == UserRole.family ? _relation.text.trim() : 'Caregiver';
    Session.patientName = _patientName.text.trim();
    Session.patientAge = _patientAge.text.trim();
    Session.patientCondition = _patientCondition.text.trim();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
  }

  Widget _eye() => IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: AppColors.muted,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      );

  @override
  Widget build(BuildContext context) {
    final isFamily = _role == UserRole.family;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(Icons.arrow_back,
                            size: 24, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'PILLCARE',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Create account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Set up care in a few minutes.',
                  style: TextStyle(fontSize: 14, color: AppColors.muted),
                ),
                const SizedBox(height: 22),
                const FieldLabel('Register as'),
                RoleSelector(
                    value: _role, onChanged: (r) => setState(() => _role = r)),
                const SizedBox(height: 18),
                LabeledField(
                  label: 'Full name',
                  controller: _name,
                  icon: Icons.person_outline,
                  validator: (v) => Validators.required(v, 'Name'),
                ),
                const SizedBox(height: 18),
                LabeledField(
                  label: 'Email address',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  icon: Icons.mail_outline,
                  validator: Validators.email,
                ),
                const SizedBox(height: 18),
                LabeledField(
                  label: 'Phone number',
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  icon: Icons.phone_outlined,
                  validator: Validators.phone,
                ),
                const SizedBox(height: 18),
                LabeledField(
                  label: 'Password',
                  controller: _password,
                  obscure: _obscure,
                  suffix: _eye(),
                  validator: Validators.password,
                ),
                const SizedBox(height: 18),
                LabeledField(
                  label: 'Confirm password',
                  controller: _confirm,
                  obscure: _obscure,
                  suffix: _eye(),
                  validator: (v) =>
                      v != _password.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 28),
                const SectionHeading('Patient details'),
                const SizedBox(height: 14),
                if (isFamily) ...[
                  LabeledField(
                    label: 'Relationship to patient',
                    controller: _relation,
                    icon: Icons.diversity_1_outlined,
                    validator: (v) => Validators.required(v, 'Relationship'),
                  ),
                  const SizedBox(height: 18),
                ],
                LabeledField(
                  label: 'Patient name',
                  controller: _patientName,
                  icon: Icons.elderly,
                  validator: (v) => Validators.required(v, 'Patient name'),
                ),
                const SizedBox(height: 18),
                LabeledField(
                  label: 'Patient age',
                  controller: _patientAge,
                  keyboardType: TextInputType.number,
                  icon: Icons.cake_outlined,
                  validator: (v) {
                    final age = int.tryParse(v ?? '');
                    if (age == null || age < 0 || age > 120) {
                      return 'Enter a valid age';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                LabeledField(
                  label: 'Condition / notes (optional)',
                  controller: _patientCondition,
                  icon: Icons.healing_outlined,
                ),
                const SizedBox(height: 26),
                AppButton('Create account', onPressed: _register),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? ',
                        style:
                            TextStyle(fontSize: 14, color: AppColors.muted)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
