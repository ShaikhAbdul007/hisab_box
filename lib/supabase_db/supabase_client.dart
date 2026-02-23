import 'package:http/http.dart' as http; // Alias use karein
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static late final SupabaseClient client;

  static Future<void> init() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      // 🔥 Yahan Timeout add kar diya hai
      httpClient: CustomHttpClient(),
      realtimeClientOptions: const RealtimeClientOptions(eventsPerSecond: 10),
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );

    client = Supabase.instance.client;
  }

  static GoTrueClient get auth => client.auth;

  static SupabaseQueryBuilder from(String table) {
    return client.from(table);
  }

  static SupabaseStorageClient get storage => client.storage;
}

// 🚀 Naya Class jo connection errors ko sambhalega
class CustomHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // Har request ko 20 seconds ka max time diya hai
    // Taaki 'Connection closed' wali error na aaye
    return _inner
        .send(request)
        .timeout(
          const Duration(seconds: 20),
          onTimeout:
              () =>
                  throw http.ClientException("Connection Timeout! Try again."),
        );
  }
}
