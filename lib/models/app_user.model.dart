import 'package:get/get.dart';

import '../helpers/supabase.helper.dart';

class AppUser {
  String userId, userName, phoneNumber, roleId;

  static String tableName = "app_user";

  AppUser({
    required this.userId,
    required this.userName,
    required this.phoneNumber,
    required this.roleId,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
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

class AppUserSnapshot {
  AppUser appUser;

  AppUserSnapshot(this.appUser);

  static Future<List<AppUser>> getAppUsers({
    String columnName = "",
    String columnValue = "",
  }) async {
    return SupabaseSnapshot.getList(
      table: AppUser.tableName,
      fromJson: AppUser.fromJson,
      columnName: columnName,
      columnValue: columnValue,
    );
  }

  static Future<AppUser?> getUserById(String userId) async {
    List<AppUser> users = await AppUserSnapshot.getAppUsers();
    print("User total: ${users.length}");
    users.forEach((element) => print(element));
    print(users.firstWhereOrNull((user) => user.userId == userId));
    return users.firstWhereOrNull((user) => user.userId == userId);
  }

  static Future<Map<String, AppUser>> getMapAppUsers() {
    return SupabaseSnapshot.getMapT<String, AppUser>(
      table: AppUser.tableName,
      fromJson: AppUser.fromJson,
      getId: (p0) => p0.userId,
    );
  }
}
