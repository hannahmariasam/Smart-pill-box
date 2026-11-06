import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'auth_helpers.dart';

// ---------------- Login ----------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  UserRole _role = UserRole.caregiver;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    Session.role = _role;
    Session.email = _email.text.trim();
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'PILLCARE',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'A little support for every daily dose.',
                  style: TextStyle(fontSize: 14, color: AppColors.muted),
                ),
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.medication_outlined,
                        size: 34, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Care, on schedule.',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sign in to manage medicines and stay connected to your loved one.',
                  style: TextStyle(
                      fontSize: 15, height: 1.4, color: AppColors.muted),
                ),
                const SizedBox(height: 24),
                const FieldLabel('Log in as'),
                RoleSelector(
                    value: _role, onChanged: (r) => setState(() => _role = r)),
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
                  label: 'Password',
                  controller: _password,
                  obscure: _obscure,
                  validator: Validators.password,
                  suffix: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: AppColors.muted,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                const SizedBox(height: 24),
                AppButton('Log in',
                    icon: Icons.arrow_forward, onPressed: _login),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('New to PillCare? ',
                        style:
                            TextStyle(fontSize: 14, color: AppColors.muted)),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.register),
                      child: const Text(
                        'Create an account',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const NoticeBox(
                  tone: Tone.info,
                  icon: Icons.info_outline,
                  white: true,
                  title: 'Your care stays private',
                  message:
                      'Only you and your invited caregivers can see your medication information.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
