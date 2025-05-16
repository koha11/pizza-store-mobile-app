import 'package:pizza_store_app/helpers/supabase.helper.dart';
import '../../helpers/supabase.helper.dart' as SupabaseHelper;

class UserAdmin {
  String userId, userName, phoneNumber, roleId;

  static String tableName = "app_user";

  UserAdmin({
    required this.userId,
    required this.userName,
    required this.phoneNumber,
    required this.roleId,
  });

  factory UserAdmin.fromJson(Map<String, dynamic> json) {
    return UserAdmin(
      userId: json["user_id"],
      userName: json["user_name"],
      phoneNumber: json["phone_number"],
      roleId: json["role_id"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "user_name": userName,
      "phone_number": phoneNumber,
      "role_id": roleId,
    };
  }
}



class UserAdminSnapshot {
  UserAdmin item;

  UserAdminSnapshot(this.item);

  static Future<List<UserAdmin>> getUserAdminWithPagination({int startIndex = 0, int limit = 5, String? searchQuery}) async {
    final res = await SupabaseHelper.supabase
        .from(UserAdmin.tableName)
        .select('*, role(role_id)')
        .range(startIndex, startIndex + limit - 1);

    if (res == null) {
      return [];
    }
    return (res as List).map((json) => UserAdmin.fromJson(json)).toList();
  }

  static Future<Map<String, UserAdmin>> getMapUserAdmin() {
    return SupabaseSnapshot.getMapT<String, UserAdmin>(
      table: UserAdmin.tableName,
      fromJson: UserAdmin.fromJson,
      getId: (p0) => p0.userId,
      selectString:
      "*, role(role_id)",
    );
  }

  static Future<int> getTotalUserAdmin({String? searchQuery}) async {
    final res = await SupabaseHelper.supabase
        .from(UserAdmin.tableName)
        .select('user_id'); // Chỉ lấy ID
    if (res == null) {
      return 0;
    }
    return (res as List).length;
  }

  static Future<void> update(UserAdmin newUser) async {
    final supabase = SupabaseHelper.supabase;
    await supabase
        .from(UserAdmin.tableName)
        .update(newUser.toJson())
        .eq("user_id", newUser.userId);
  }

  static Future<dynamic> insert(UserAdmin newUser) async {
    final supabase = SupabaseHelper.supabase;
    final data = await supabase
        .from(UserAdmin.tableName)
        .insert(newUser.toJson())
        .select(); // Lấy dữ liệu vừa insert nếu cần
    return data;
  }

  static Future<void> delete(String userId) async {
    final supabase = SupabaseHelper.supabase;
    await supabase.from(UserAdmin.tableName).delete().eq("user_id", userId);
  }
}