import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Default project credentials - can also be passed via --dart-define
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://lyifcsjunlgwkarrzvra.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx5aWZjc2p1bmxnd2thcnJ6dnJhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY4NzA4NjAsImV4cCI6MjEwMjQ0Njg2MH0.3a4OpPVtliE-OHtI-liC-1LWMhBvEG_J-HB0ZVpF1Fc',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummy_anon_key_for_offline_preview',
  );

  // Active default Gym ID (Iron Forge Fitness)
  static const String defaultGymId = '11111111-1111-1111-1111-111111111111';

  // Active default Member ID (Arjun Verma)
  static const String defaultMemberId = 'dddddddd-dddd-dddd-dddd-dddddddddddd';

  // Active default Owner ID (Rahul)
  static const String defaultOwnerId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
      _isInitialized = true;
      debugPrint('✅ Supabase initialized successfully.');
    } catch (e) {
      debugPrint(
        '⚠️ Supabase live connection failed, operating in safe resilient fallback mode: $e',
      );
      _isInitialized = false;
    }
  }

  static SupabaseClient get client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      // Return uninitialized instance or handle gracefully
      throw Exception('Supabase client accessed before initialization');
    }
  }
}
