import 'package:flutter/material.dart';

import 'pages/auth_helpers.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/main_shell.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const PillCareApp());
}

class PillCareApp extends StatelessWidget {
  const PillCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PillCare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.register: (_) => const RegisterPage(),
        AppRoutes.home: (_) => const MainShell(),
      },
    );
  }
}
