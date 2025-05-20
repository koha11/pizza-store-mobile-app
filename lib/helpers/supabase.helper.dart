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
  static Future<int> getLengthOfTable<T>({
    required String table,
    String selectString = "",
    Map<String, dynamic>? equalObject,
  }) async {
    var query = supabase.from(table).select(selectString);

    if (equalObject != null) {
      for (var entry in equalObject.entries) {
        query = query.eq(entry.key, entry.value);
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
  }) async {
    List<T> ts = [];

    var query = supabase.from(table).select(selectString);

    if (equalObject != null) {
      for (var entry in equalObject.entries) {
        query = query.eq(entry.key, entry.value);
      }
    }

    var data = await query;

    ts = data.map(fromJson).toList();

    return ts;
  }

  static Future<Map<T1, T2>> getMapT<T1, T2>({
    required String table,
    required T2 Function(Map<String, dynamic> json) fromJson,
    required T1 Function(T2) getId,
    String selectString = "",
    Map<String, dynamic>? equalObject,
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
  }) async {
    var data = await supabase.from(table).insert(insertObject);

    return data;
  }

  static Future<void> update<T1, T2>({
    required String table,
    required Map<String, dynamic> updateObject,
    Map<String, dynamic>? equalObject,
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
}

// dùng ktra đơn hàng đang xử lý tránh có nhiều đơn hàng xử lý cho cùng 1 khách
class SupabaseHelper {
  static Future<String?> getPendingOrderId(String customerId) async {
    final response =
        await supabase
            .from('customer_order')
            .select('order_id')
            .eq('customer_id', customerId)
            .eq('status', 'pending')
            .maybeSingle();

    return response?['order_id'] as String?;
  }

  // tính tiền
  static Future<void> updateOrderTotal(String orderId, int total) async {
    await supabase
        .from('customer_order')
        .update({'total_amount': total})
        .eq('order_id', orderId);
  }

  // Phương thức cập nhật số lượng sản phẩm trong giỏ hàng
  static Future<void> updateCartItemAmount(
    String orderId,
    String itemId,
    int newAmount,
  ) async {
    try {
      await supabase
          .from('order_detail')
          .update({'amount': newAmount})
          .eq('order_id', orderId)
          .eq('item_id', itemId);
    } catch (e) {
      print('Lỗi cập nhật số lượng trong database: $e');
      rethrow;
    }
  }

  // Phương thức xóa sản phẩm khỏi giỏ hàng
  static Future<void> removeCartItem(String orderId, String itemId) async {
    try {
      await supabase
          .from('order_detail')
          .delete()
          .eq('order_id', orderId)
          .eq('item_id', itemId);
    } catch (e) {
      print('Lỗi xóa sản phẩm khỏi giỏ hàng: $e');
      rethrow;
    }
  }

  //
  // // Phương thức xóa nhiều sản phẩm khỏi giỏ hàng
  // static Future<void> removeCartItems(String orderId, List<String> itemIds) async {
  //   try {
  //     await supabase
  //         .from('order_detail')
  //         .delete()
  //         .eq('order_id', orderId)
  //         .in_('item_id', itemIds);
  //   } catch (e) {
  //     print('Lỗi xóa nhiều sản phẩm khỏi giỏ hàng: $e');
  //     rethrow;
  //   }
  // }
  //
  // // Phương thức cập nhật tổng tiền đơn hàng
  // static Future<void> updateOrderTotal(String orderId) async {
  //   try {
  //     final response = await supabase
  //         .from('order_detail')
  //         .select('amount, actual_price')
  //         .eq('order_id', orderId);
  //
  //     int total = 0;
  //     for (var item in response) {
  //       total += item['amount'] * item['actual_price'];
  //     }
  //
  //     await supabase
  //         .from('customer_order')
  //         .update({'total': total})
  //         .eq('order_id', orderId);
  //   } catch (e) {
  //     print('Lỗi cập nhật tổng tiền đơn hàng: $e');
  //     rethrow;
  //   }
  // }
}
