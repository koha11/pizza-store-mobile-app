import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseHelper {
  static final supabase = Supabase.instance.client;

  Future<String> uploadImage({
    required File image,
    required String bucket,
    required String path,
  }) async {
    await supabase.storage
        .from(bucket)
        .upload(
      path,
      image,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );

    final String publicUrl = supabase.storage.from(bucket).getPublicUrl(path);

    return publicUrl;
  }

  Future<void> removeImage({required String bucket, required String path}) async {
    await supabase.storage.from(bucket).remove([path]);
  }
}

class SupabaseSnapshot {
  static Future<Map<K, V>> getMapT<K, V>({
    required String table,
    required V Function(Map<String, dynamic>) fromJson,
    required K Function(V) getId,
    String selectString = "*",
  }) async {
    final res = await SupabaseHelper.supabase.from(table).select(selectString);
    if (res == null) {
      return {};
    }
    final map = <K, V>{};
    for (final row in res) {
      final item = fromJson(row);
      map[getId(item)] = item;
    }
    return map;
  }
}