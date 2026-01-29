import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  SupabaseConfig._(); // private constructor

  static late final SupabaseClient client;

  /// Call this ONCE in main()
  static Future<void> init() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce, // secure by default
      ),
    );

    client = Supabase.instance.client;
  }

  // ---------- SHORTCUTS (Universal use) ----------

  static GoTrueClient get auth => client.auth;

  static SupabaseQueryBuilder from(String table) {
    return client.from(table);
  }

  static SupabaseStorageClient get storage => client.storage;
}
