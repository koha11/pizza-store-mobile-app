import 'dart:io';

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
  final supabase = Supabase.instance.client;

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
  static Future<List<T>> getList<T>({
    required String table,
    required T Function(Map<String, dynamic> json) fromJson,
    String selectString = "",
    String columnName = "",
    String columnValue = "",
  }) async {
    List<T> ts = [];

    PostgrestList data;

    if (columnName == "") {
      data = await supabase.from(table).select(selectString);
    } else {
      data = await supabase
          .from(table)
          .select(selectString)
          .eq(columnName, columnValue);
    }

    ts = data.map(fromJson).toList();

    return ts;
  }

  static Future<Map<T1, T2>> getMapT<T1, T2>({
    required String table,
    required T2 Function(Map<String, dynamic> json) fromJson,
    required T1 Function(T2) getId,
    String selectString = "",
    String columnName = "",
    String columnValue = "",
  }) async {
    var data = await getList(
      table: table,
      fromJson: fromJson,
      selectString: selectString,
      columnName: columnName,
      columnValue: columnValue,
    );

    Map<T1, T2> _maps = Map.fromIterable(
      data,
      key: (t) => getId(t),
      value: (t) => t,
    );

    return _maps;
  }
}