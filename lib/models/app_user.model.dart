import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helpers/supabase.helper.dart';

class AppUser {
  String userId, userName, phoneNumber, roleId;
  String? avatar, email;

  static String tableName = "app_user";

  AppUser({
    required this.userId,
    required this.userName,
    required this.phoneNumber,
    required this.roleId,
    this.email,
    this.avatar,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      userId: json["user_id"],
      userName: json["user_name"],
      phoneNumber: json["phone_number"],
      roleId: json["role_id"],
      avatar: json["user_avatar"],
      email: json["user_email"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "user_name": userName,
      "phone_number": phoneNumber,
      "role_id": roleId,
      "user_avatar": avatar,
      "user_email": email,
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

  static Future<Map<String, AppUser>> getMapAppUsers() {
    return SupabaseSnapshot.getMapT<String, AppUser>(
      table: AppUser.tableName,
      fromJson: AppUser.fromJson,
      getId: (p0) => p0.userId,
    );
  }

  static Future<void> updateInfoAppUser({
    required String userName,
    required String phoneNumber,
    required String userId,
  }) async {
    final Map<String, dynamic> updates = {};
    updates['user_name'] = userName;
    updates['phone_number'] = phoneNumber;
    await supabase.from('app_user').update(updates).eq('user_id', userId);
  }
}
