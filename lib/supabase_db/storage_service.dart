import 'dart:io';
import 'package:inventory/helper/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:inventory/supabase_db/supabase_client.dart';

class StorageService {
  StorageService._();

  static const String _profileBucket = 'profile_image';

  static bool isNetworkImage(String? value) {
    if (value == null) return false;
    return value.startsWith('http://') || value.startsWith('https://');
  }

  static String _fileExtension(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == path.length - 1) return 'jpg';
    return path.substring(dotIndex + 1).toLowerCase();
  }

  static Future<String> uploadProfileImage({
    required File file,
    required String userId,
  }) async {
    final extension = _fileExtension(file.path);

    // 1. Path banaya (User ID ke folder mein avatar.jpg)
    final storagePath = '$userId/avatar.$extension';

    // 2. Photo Upload ki (upsert: true matlab purani replace ho jayegi)
    await SupabaseConfig.storage
        .from(_profileBucket)
        .upload(
          storagePath,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    // 3. ✨ YE RAHI WO LINE: Public URL lo (Ab token ki zaroorat nahi)
    final String publicUrl = SupabaseConfig.storage
        .from(_profileBucket)
        .getPublicUrl(storagePath);

    // 4. Cache-buster add kiya taaki turant update dikhe
    final finalUrl = "$publicUrl?v=${DateTime.now().millisecondsSinceEpoch}";

    AppLogger.info("Generated Public URL: $finalUrl");
    return finalUrl;
  }
}
