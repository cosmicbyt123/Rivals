import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Screens/home/home_page.dart';
import 'Screens/profile/Profile_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabasePublishableKey = dotenv.env['SUPABASE_PUBLISHABLE_KEY'];

  if (supabaseUrl == null || supabasePublishableKey == null) {
    throw StateError('SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY are required.');
  }

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  const MyApp({super.key});

  @override // Build the main application widget with routing and theming.
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rivals',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 63, 12, 16),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
      routes: {
        
        '/home': (_) => const HomePage(),
        '/profile': (_) => const ProfilePage(),
      },
    );
  }
}
