import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Screens/auth/login_page.dart';
import 'Screens/auth/signup_page.dart';
import 'Screens/home/home_page.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lyifcsjunlgwkarrzvra.supabase.co',
    publishableKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx5aWZjc2p1bmxnd2thcnJ6dnJhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY4NzA4NjAsImV4cCI6MjEwMjQ0Njg2MH0.3a4OpPVtliE-OHtI-liC-1LWMhBvEG_J-HB0ZVpF1Fc',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: LoginPage(
        onLogin: (email, password) async {
          await Supabase.instance.client.auth.signInWithPassword(
            email: email,
            password: password,
          );

          _navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(
              builder: (_) => const HomePage(),
            ),
          );
        },
      ),
      routes: {
        '/signup': (_) => SignupPage(
          onSignUp: (email, password) async {
            final response = await Supabase.instance.client.auth.signUp(
              email: email,
              password: password,
            );

            if (response.user == null) {
              throw const AuthException('Could not create the account.');
            }

            if (response.session != null) {
              _navigatorKey.currentState?.pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const HomePage(),
                ),
              );
            }
          },
        ),
      },
    );
  }
}
