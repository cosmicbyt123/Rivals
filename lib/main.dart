import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();

  runApp(
    const ProviderScope(
      child: RivalsApp(),
    ),
  );
}

class RivalsApp extends StatelessWidget {
  const RivalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RIVALS',
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.initial,
      routes: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
