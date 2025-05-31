import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

User? getCurrentUser() {
  return supabase.auth.currentUser;
}

Future<void> logout() async {
  await supabase.auth.signOut();
}

Future<void> login() async {
  await supabase.auth.signOut();
}

Future<void> register() async {
  await supabase.auth.signOut();
}

Future<AuthResponse> verify(String token, String email) async {
  return await supabase.auth.verifyOTP(
    type: OtpType.email,
    token: token,
    email: email,
  );
}

// Future<String> uploadImage({
//   required File image,
//   required String bucket,
//   required String path,
// }) async {
//   await supabase.storage
//       .from(bucket)
//       .upload(
//         path,
//         image,
//         fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
//       );
//
//   final String publicUrl = supabase.storage.from(bucket).getPublicUrl(path);
//
//   return publicUrl;
// }

Future<String> uploadImage({
  File? image,             // Cho mobile
  Uint8List? bytes,        // Cho web
  required String bucket,
  required String path,
}) async {
  final storageRef = supabase.storage.from(bucket);

  if (kIsWeb) {
    if (bytes == null) throw Exception('Dữ liệu ảnh không hợp lệ (web)');
    await storageRef.uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );
  } else {
    if (image == null) throw Exception('File ảnh không hợp lệ (mobile)');
    await storageRef.upload(
      path,
      image,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );
  }

  final String publicUrl = storageRef.getPublicUrl(path);
  return publicUrl;
}

Future<void> removeImage({required String bucket, required String path}) async {
  await supabase.storage.from(bucket).remove([path]);
}

Stream<List<T>> getDataStream<T>({
  required String table,
  required List<String> ids,
  required T Function(Map<String, dynamic> json) fromJson,
}) {
  var stream = supabase.from(table).stream(primaryKey: ids);

  return stream.map(
    (mapList) => mapList.map((mapObj) => fromJson(mapObj)).toList(),
  );
}

listenDataChange<T>(
  Map<int, T> maps, {
  required String channel,
  required String schema,
  required String table,
  required T Function(Map<String, dynamic> json) fromJson,
  required int Function(T) getId,
  Function()? updateUI,
}) async {
  supabase
      .channel(channel)
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: schema,
        table: table,
        callback: (payload) {
          switch (payload.eventType) {
            // case "INSERT" "UPDATE":
            case PostgresChangeEvent.insert:
            case PostgresChangeEvent.update:
              {
                T t = fromJson(payload.newRecord);
                maps[getId(t)] = t;
                updateUI?.call();
                break;
              }

            case PostgresChangeEvent.delete:
              {
                maps.remove(payload.oldRecord["id"]);
                updateUI?.call();
                break;
              }

            default:
              {}
          }
        },
      )
      .subscribe();
}

class SupabaseSnapshot {
  static Future<int> getLengthOfTable<T>({
    required String table,
    String selectString = "",
    Map<String, dynamic>? equalObject,
    Map<String, dynamic>? ltObject,
    Map<String, dynamic>? gtObject,
  }) async {
    var query = supabase.from(table).select(selectString);

    if (equalObject != null) {
      for (var entry in equalObject.entries) {
        query = query.eq(entry.key, entry.value);
      }
    }

    if (ltObject != null) {
      for (var entry in ltObject.entries) {
        query = query.lt(entry.key, entry.value);
      }
    }

    if (gtObject != null) {
      for (var entry in gtObject.entries) {
        query = query.gt(entry.key, entry.value);
      }
    }

    var data = await query;

    return data.length;
  }

  static Future<List<T>> getList<T>({
    required String table,
    required T Function(Map<String, dynamic> json) fromJson,
    String selectString = "",
    Map<String, dynamic>? equalObject,
    Map<String, dynamic>? ltObject,
    Map<String, dynamic>? gtObject,
    List<Map<String, dynamic>>? orObject,
  }) async {
    List<T> ts = [];

    var query = supabase.from(table).select(selectString);

    if (equalObject != null) {
      for (var entry in equalObject.entries) {
        query = query.eq(entry.key, entry.value);
      }
    }

    if (ltObject != null) {
      for (var entry in ltObject.entries) {
        query = query.lt(entry.key, entry.value);
      }
    }

    if (gtObject != null) {
      for (var entry in gtObject.entries) {
        query = query.gt(entry.key, entry.value);
      }
    }

    if (orObject != null && orObject.isNotEmpty) {
      final orString = orObject
          .map((cond) => cond.entries
          .map((e) => '${e.key}.eq.${e.value}')
          .join(','))
          .join(',');
      query = query.or(orString);
    }

    var data = await query;

    ts = data.map(fromJson).toList();

    return ts;
  }

  static Future<T?> getById<T>({
    required String table,
    required T Function(Map<String, dynamic> json) fromJson,
    String selectString = "",
    required String idKey,
    required String idValue,
  }) async {
    var data =
        await supabase
            .from(table)
            .select(selectString)
            .eq(idKey, idValue)
            .maybeSingle();

    if (data == null) {
      return null;
    }

    return fromJson(data);
  }

  static Future<Map<T1, T2>> getMapT<T1, T2>({
    required String table,
    required T2 Function(Map<String, dynamic> json) fromJson,
    required T1 Function(T2) getId,
    String selectString = "",
    Map<String, dynamic>? equalObject,
    Map<String, dynamic>? ltObject,
    Map<String, dynamic>? gtObject,
  }) async {
    var data = await getList(
      table: table,
      fromJson: fromJson,
      selectString: selectString,
      equalObject: equalObject,
    );

    Map<T1, T2> _maps = Map.fromIterable(
      data,
      key: (t) => getId(t),
      value: (t) => t,
    );

    return _maps;
  }

  static Future<T> insert<T>({
    required String table,
    required Map<String, dynamic> insertObject,
    Map<String, dynamic>? equalObject,
    Map<String, dynamic>? ltObject,
    Map<String, dynamic>? gtObject,
  }) async {
    var data = await supabase.from(table).insert(insertObject);

    return data;
  }

  static Future<void> update<T1, T2>({
    required String table,
    required Map<String, dynamic> updateObject,
    Map<String, dynamic>? equalObject,
    Map<String, dynamic>? ltObject,
    Map<String, dynamic>? gtObject,
  }) async {
    var query = supabase.from(table).update(updateObject);

    if (equalObject != null) {
      for (var entry in equalObject.entries) {
        query = query.eq(entry.key, entry.value);
      }
    }

    await query;
  }

  static Future<void> delete<T1, T2>({
    required String table,
    Map<String, dynamic>? equalObject,
    Map<String, dynamic>? ltObject,
    Map<String, dynamic>? gtObject,
  }) async {
    var query = supabase.from(table).delete();

    if (equalObject != null) {
      for (var entry in equalObject.entries) {
        query = query.eq(entry.key, entry.value);
      }
    }

    await query;
  }

  Stream<List<T>> getDataStream<T>({
    required String table,
    required List<String> ids,
    required T Function(Map<String, dynamic> json) fromJson,
  }) {
    var stream = supabase.from(table).stream(primaryKey: ids);
    return stream.map((mapList) => mapList.map((e) => fromJson(e)).toList());
  }

  static Future<List<T>> search<T>({
    required String table,
    required String columnName,
    required String query,
    required T Function(Map<String, dynamic> json) fromJson,
    String selectString = '',
  }) async {
    try {
      final List<Map<String, dynamic>> data = await supabase
          .from(table)
          .select(selectString)
          .ilike(columnName, '%$query%');
      return data.map((e) => fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Lỗi: $e';
    }
  }
}
// dùng ktra đơn hàng đang xử lý tránh có nhiều đơn hàng xử lý cho cùng 1 khách
