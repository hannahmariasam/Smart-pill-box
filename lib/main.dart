import 'package:flutter/material.dart';

void main() => runApp(const CareApp());

// ---------------- Routes ----------------
class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
}

// ---------------- In-memory session ----------------
enum UserRole { caregiver, family }

class Session {
  static UserRole role = UserRole.caregiver;
  static String name = 'Sarah Johnson';
  static String email = 'sarah@example.com';
  static String phone = '+1 555 123 4567';
  static String relation = 'Daughter';
  static String patientName = 'Robert Johnson';
  static String patientAge = '78';
  static String patientCondition = 'Type 2 Diabetes, Hypertension';

  static String get roleLabel =>
      role == UserRole.caregiver ? 'Caregiver' : 'Family Member';

  static void clear() {
    role = UserRole.caregiver;
  }
}

// ---------------- App ----------------
class CareApp extends StatelessWidget {
  const CareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Care App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        inputDecorationTheme:
            const InputDecorationTheme(border: OutlineInputBorder()),
      ),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.register: (_) => const RegisterPage(),
        AppRoutes.home: (_) => const MainShell(),
      },
    );
  }
}

// ---------------- Validators ----------------
class Validators {
  static String? required(String? v, [String field = 'This field']) =>
      (v == null || v.trim().isEmpty) ? '$field is required' : null;

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final ok = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(v.trim());
    return ok ? null : 'Enter a valid email';
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Minimum 6 characters';
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone is required';
    if (v.replaceAll(RegExp(r'\D'), '').length < 7) {
      return 'Enter a valid phone';
    }
    return null;
  }
}

// ---------------- Role selector ----------------
class RoleSelector extends StatelessWidget {
  final UserRole value;
  final ValueChanged<UserRole> onChanged;
  const RoleSelector({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<UserRole>(
        segments: const [
          ButtonSegment(
            value: UserRole.caregiver,
            icon: Icon(Icons.medical_services_outlined),
            label: Text('Caregiver'),
          ),
          ButtonSegment(
            value: UserRole.family,
            icon: Icon(Icons.family_restroom),
            label: Text('Family'),
          ),
        ],
        selected: {value},
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    );
  }
}

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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.favorite,
                      size: 64, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 12),
                  Text('Welcome back',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  const Text('Log in as',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  RoleSelector(
                      value: _role,
                      onChanged: (r) => setState(() => _role = r)),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        labelText: 'Email', prefixIcon: Icon(Icons.email)),
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _login,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Login'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.register),
                    child: const Text("Don't have an account? Register"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    final isFamily = _role == UserRole.family;
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Register as'),
                const SizedBox(height: 8),
                RoleSelector(
                    value: _role,
                    onChanged: (r) => setState(() => _role = r)),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                      labelText: 'Full name', prefixIcon: Icon(Icons.person)),
                  validator: (v) => Validators.required(v, 'Name'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: 'Email', prefixIcon: Icon(Icons.email)),
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                      labelText: 'Phone', prefixIcon: Icon(Icons.phone)),
                  validator: Validators.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirm,
                  obscureText: _obscure,
                  decoration: const InputDecoration(
                      labelText: 'Confirm password',
                      prefixIcon: Icon(Icons.lock_outline)),
                  validator: (v) =>
                      v != _password.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 24),
                Text('Patient details',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                if (isFamily) ...[
                  TextFormField(
                    controller: _relation,
                    decoration: const InputDecoration(
                        labelText: 'Relationship to patient',
                        prefixIcon: Icon(Icons.diversity_1)),
                    validator: (v) => Validators.required(v, 'Relationship'),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _patientName,
                  decoration: const InputDecoration(
                      labelText: 'Patient name',
                      prefixIcon: Icon(Icons.elderly)),
                  validator: (v) => Validators.required(v, 'Patient name'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _patientAge,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Patient age', prefixIcon: Icon(Icons.cake)),
                  validator: (v) {
                    final age = int.tryParse(v ?? '');
                    if (age == null || age < 0 || age > 120) {
                      return 'Enter a valid age';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _patientCondition,
                  decoration: const InputDecoration(
                      labelText: 'Condition / notes (optional)',
                      prefixIcon: Icon(Icons.healing)),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _register,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Register'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- Main shell (shared bottom navigation) ----------------
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _titles = ['Home', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[const HomePage(), const ProfilePage()];
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Hello, ${Session.name}\n(${Session.roleLabel})\n\n'
          "Other members' pages go here.",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

// ---------------- Profile ----------------
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _logout(BuildContext context) {
    Session.clear();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isFamily = Session.role == UserRole.family;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Column(
            children: [
              const CircleAvatar(
                  radius: 44, child: Icon(Icons.person, size: 44)),
              const SizedBox(height: 12),
              Text(Session.name,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Chip(label: Text(Session.roleLabel)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _section(context, isFamily ? 'Family details' : 'Caregiver details', [
          _row(Icons.email, 'Email', Session.email),
          _row(Icons.phone, 'Phone', Session.phone),
          if (isFamily)
            _row(Icons.diversity_1, 'Relationship', Session.relation),
        ]),
        const SizedBox(height: 12),
        _section(context, 'Patient details', [
          _row(Icons.elderly, 'Name', Session.patientName),
          _row(Icons.cake, 'Age', Session.patientAge),
          _row(Icons.healing, 'Condition', Session.patientCondition),
        ]),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => _logout(context),
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> rows) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            ...rows,
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value.isEmpty ? '-' : value),
    );
  }
}