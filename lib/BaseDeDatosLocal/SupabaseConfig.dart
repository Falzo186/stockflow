import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://heyrfywlbdtdncyillbt.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhleXJmeXdsYmR0ZG5jeWlsbG0iLCJyb2xlIjoiYW5vbiIsImlhdCI6MTc2MDc1NjYwMywiZXhwIjoyMDc2MzMyNjAzfQ.kQ7WuDY63Eea0aZUODSPDtSTcZr69ALbvinjsZXZVx8';

  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
