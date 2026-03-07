import 'dart:io';

import 'package:inventory/supabase_db/supabase_client.dart';

class StorageService {
  StorageService._();

  static const String _profileBucket = 'profile-images';

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
    final storagePath =
        '$userId/profile_${DateTime.now().millisecondsSinceEpoch}.$extension';

    await SupabaseConfig.storage.from(_profileBucket).upload(storagePath, file);
    return SupabaseConfig.storage.from(_profileBucket).getPublicUrl(storagePath);
  }
}
