import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/models/user_address.model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/supabase.helper.dart';

class AppUser {
  String userId, userName, phoneNumber, roleId;
  String? avatar, email;
  bool isActive;
  List<UserAddress>? addresses = [];

  static String tableName = "app_user";

  AppUser({
    required this.userId,
    required this.userName,
    required this.phoneNumber,
    required this.roleId,
    required this.isActive,
    this.email,
    this.avatar,
    this.addresses,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    List<dynamic> userAddressesJson = json["user_address"] ?? [];

    List<UserAddress> userAddresses =
        userAddressesJson
            .map((address) => UserAddress.fromJson(address))
            .toList();

    return AppUser(
      userId: json["user_id"],
      userName: json["user_name"],
      phoneNumber: json["phone_number"],
      roleId: json["role_id"],
      avatar: json["user_avatar"],
      email: json["user_email"],
      isActive: json["is_active"],
      addresses: userAddresses,
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
      "is_active": isActive,
    };
  }
}

class AppUserSnapshot {
  AppUser appUser;

  AppUserSnapshot(this.appUser);

  static Future<List<AppUser>> getAppUsers({
    Map<String, dynamic>? equalObject,
  }) async {
    return SupabaseSnapshot.getList(
      table: AppUser.tableName,
      fromJson: AppUser.fromJson,
      equalObject: equalObject,
      selectString: "*, user_address (*)",
    );
  }

  static Future<Map<String, AppUser>> getMapAppUsers() {
    return SupabaseSnapshot.getMapT<String, AppUser>(
      table: AppUser.tableName,
      fromJson: AppUser.fromJson,
      getId: (p0) => p0.userId,
      selectString: "*, user_address (*)",
    );
  }

  static Future<void> updateInfoAppUser({
    required BuildContext context,
    required TextEditingController txtUserName,
    required TextEditingController txtPhoneNumber,
    required String userId,
  }) async {
    final userName = txtUserName.text;
    final phoneNumber = txtPhoneNumber.text;
    ScaffoldMessenger.of(context).clearSnackBars();
    if (userName.isEmpty || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")));
      return;
    }
    final Map<String, dynamic> updates = {};
    updates['user_name'] = userName;
    updates['phone_number'] = phoneNumber;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Đang cập nhật...")));
    try {
      await SupabaseSnapshot.update(
        table: AppUser.tableName,
        updateObject: updates,
        equalObject: {'user_id': userId},
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Cập nhật thành công")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đã xảy ra lỗi không xác định")));
    }
  }

  static Future<void> updatePassword({
    required BuildContext context,
    required TextEditingController txtCurrPw,
    required TextEditingController txtNewPw,
    required TextEditingController txtConfirmNewPw,
  }) async {
    ScaffoldMessenger.of(context).clearSnackBars();
    final currPwd = txtCurrPw.text;
    final newPwd = txtNewPw.text;
    final confirmPwd = txtConfirmNewPw.text;

    if (currPwd.isEmpty || newPwd.isEmpty || confirmPwd.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")));
      return;
    }
    if (confirmPwd != newPwd) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Mật khẩu mới không khớp")));
      return;
    }
    final email = getCurrentUser()!.email;
    if (email == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Bạn chưa đăng nhập")));
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Đang xử lý...")));
    try {
      await supabase.auth.signInWithPassword(email: email, password: currPwd);

      await supabase.auth.updateUser(UserAttributes(password: newPwd));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đổi mật khẩu thành công")));
      txtCurrPw.clear();
      txtNewPw.clear();
      txtConfirmNewPw.clear();
    } on AuthApiException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Mật khẩu cũ không đúng")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đã xảy ra lỗi không xác định")));
    }
  }

  //ADMIN ----------------

  static Future<void> createUser({
    required AppUser user,
  }) async {
    await SupabaseSnapshot.insert(
      table: AppUser.tableName,
      insertObject: {
        "user_id": user.userId,
        "user_name": user.userName,
        "phone_number": user.phoneNumber,
        "role_id": user.roleId,
        "user_avatar": user.avatar,
        "user_email": user.email,
        "is_active": user.isActive,
      },
    );
  }

  static Future<void> deleteUser({
    required AppUser user,
  }) async {
    await SupabaseSnapshot.delete(
      table: AppUser.tableName,
      equalObject: {'user_id': user.userId},
    );
  }

  static Future<void> updateUser({
    required AppUser user,
  }) async {
    await SupabaseSnapshot.update(
      table: AppUser.tableName,
      updateObject: {
        "user_id": user.userId,
        "user_name": user.userName,
        "phone_number": user.phoneNumber,
        "role_id": user.roleId,
        "user_avatar": user.avatar,
        "user_email": user.email,
        "is_active": user.isActive,
      },
      equalObject: {"user_id": user.userId},
    );
  }

  static Future<List<AppUser>> searchUsers(String query) async {
    try {
      final List<AppUser> users = await SupabaseSnapshot.search<AppUser>(
        table: AppUser.tableName,
        columnName: 'user_name',
        query: query,
        fromJson: AppUser.fromJson,
        selectString: '*, role(*)',
      );
      return users;
    } catch (e) {
      throw 'Lỗi khi tìm kiếm User: $e';
    }
  }
}
