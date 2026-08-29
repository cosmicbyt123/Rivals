import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Screens/auth/login_page.dart';
import 'Screens/auth/signup_page.dart';
import 'Screens/home/home_page.dart';
import 'Screens/profile_page.dart';

const String supabaseUrl = 'https://lyifcsjunlgwkarrzvra.supabase.co';
const String supabasePublishableKey = 'sb_publishable_dUMVnRG0RSSPW4ZN2NUJmQ_ENZW9DeU';

final _navigatorKey = GlobalKey<NavigatorState>();

Future<void> saveUserProfile(User user) async {
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lyifcsjunlgwkarrzvra.supabase.co',
    publishableKey: 'sb_publishable_dUMVnRG0RSSPW4ZN2NUJmQ_ENZW9DeU',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget _loginPage() {
    return LoginPage(
      onLogin: (email, password) async {
        try {
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
        } catch (e) {
          rethrow;
        }
      },
    );
  }

  @override
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
      home: _loginPage(),
      routes: {
        '/login': (_) => _loginPage(),
        '/signup': (_) => SignupPage(
              onSignUp: (email, password) async {
                final response = await Supabase.instance.client.auth.signUp(
                  email: email,
                  password: password,
                );

                if (response.user == null) {
                  throw const AuthException('Could not create the account.');
                }

                await saveUserProfile(response.user!);

                _navigatorKey.currentState?.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomePage()),
                  (route) => false,
                );
              },
            ),
        '/profile': (_) => const ProfilePage(),
      },
    );
  }
}