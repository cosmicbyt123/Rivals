import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Screens/auth/login_page.dart';
import 'Screens/auth/signup_page.dart';
import 'Screens/home/home_page.dart';
import 'Screens/profile_page.dart';

const String supabaseUrl = 'https://lyifcsjunlgwkarrzvra.supabase.co';    
const String supabasePublishableKey = 'sb_publishable_dUMVnRG0RSSPW4ZN2NUJmQ_ENZW9DeU';

final _navigatorKey = GlobalKey<NavigatorState>();    

Future<void> saveUserProfile(User user) async {     //
  final email = user.email ?? '';
  final fullName = email.contains('@') ? email.split('@').first : 'User';

  await Supabase.instance.client.from('profiles').upsert(
    {
      'id': user.id,
      'email': email,
      'full_name': fullName,
    },
    onConflict: 'id',
  );
}

Future<void> main() async {     // Ensure that Flutter bindings are initialized before using Supabase
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lyifcsjunlgwkarrzvra.supabase.co',
    publishableKey: 'sb_publishable_dUMVnRG0RSSPW4ZN2NUJmQ_ENZW9DeU',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {     // This widget is the root of your application.
  const MyApp({super.key});

  Future<void> _handleLogin(String email, String password) async {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Invalid credentials. Please try again.');
    }

    _navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  Future<void> _handleSignUp(String email, String password) async {
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw const AuthException('Could not create the account.');
    }

    await saveUserProfile(response.user!);

    if (Supabase.instance.client.auth.currentSession != null) {
      await Supabase.instance.client.auth.signOut();
    }

    _navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => _loginPage()),
      (route) => false,
    );
  }

  Widget _loginPage() {
    return LoginPage(onLogin: _handleLogin);
  }

  @override     // Build the main application widget with routing and theming.
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      title: 'Rivals',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 63, 12, 16),
          brightness: Brightness.dark,
        ),
      ),
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final hasSession = Supabase.instance.client.auth.currentSession != null;

          if (hasSession) {
            return const HomePage();
          }

          return _loginPage();
        },
      ),
      routes: {
        '/login': (_) => _loginPage(),
        '/signup': (_) => SignupPage(onSignUp: _handleSignUp),
        '/profile': (_) => const ProfilePage(),
      },
    );
  }
}