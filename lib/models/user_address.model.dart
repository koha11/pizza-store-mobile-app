import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helpers/supabase.helper.dart';

class UserAddress {
  String userId, address;
  String? addressNickName;

  static String tableName = "user_address";

  UserAddress({
    required this.userId,
    required this.address,
    this.addressNickName,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      userId: json["user_id"],
      address: json["address"],
      addressNickName: json["address_nickname"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "address": address,
      "address_nickname": addressNickName,
    };
  }
}

class UserAddressSnapshot {
  UserAddress userAddress;

  UserAddressSnapshot(this.userAddress);

  static Future<List<UserAddress>> getUserAddress({
    Map<String, dynamic>? equalObject,
  }) async {
    return SupabaseSnapshot.getList(
      table: UserAddress.tableName,
      fromJson: UserAddress.fromJson,
      equalObject: equalObject,
    );
  }

  static Future<Map<String, UserAddress>> getMapUserAddress() {
    return SupabaseSnapshot.getMapT<String, UserAddress>(
      table: UserAddress.tableName,
      fromJson: UserAddress.fromJson,
      getId: (p0) => p0.userId,
    );
  }

  static Future<void> addNewAddress({
    required BuildContext context,
    required TextEditingController txtAddress,
    required TextEditingController txtNickName,
    required String userId,
  }) async {
    ScaffoldMessenger.of(context).clearSnackBars();
    final address = txtAddress.text;
    final nickName = txtNickName.text;
    if (address.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Vui lòng nhập đẩy đủ thông tin")));
      return;
    }
    try {
      final Map<String, dynamic> inserts = {};
      inserts['user_id'] = userId;
      inserts['address'] = address;
      inserts['address_nickname'] = nickName;

      await SupabaseSnapshot.insert(
        table: UserAddress.tableName,
        insertObject: inserts,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Thêm địa chỉ thành công")));
      txtAddress.clear();
      txtNickName.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${e}")));
    }
  }

  static Future<void> updateAddress({
    required BuildContext context,
    required TextEditingController txtNewAddress,
    required TextEditingController txtNickName,
    required TextEditingController txtCurrAddress,
    required String userId,
  }) async {
    final newAddress = txtNewAddress.text;
    final currAddress = txtCurrAddress.text;
    final nickName = txtNickName.text;
    ScaffoldMessenger.of(context).clearSnackBars();
    if (newAddress.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")));
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Đang cập nhật...")));
    try {
      final Map<String, dynamic> updates = {};
      updates['address'] = newAddress;
      updates['address_nickname'] = nickName;

      await SupabaseSnapshot.update(
        table: UserAddress.tableName,
        updateObject: updates,
        equalObject: {'user_id': userId, 'address': currAddress},
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Cập nhật địa chỉ thành công")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${e}")));
    }
  }

  static Future<void> deleteAddress({
    required BuildContext context,
    required TextEditingController txtAddress,
    required String userId,
  }) async {
    final address = txtAddress.text;
    ScaffoldMessenger.of(context).clearSnackBars();
    if (address.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đã xảy ra lỗi")));
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Đang cập nhật...")));
    try {
      await SupabaseSnapshot.delete(
        table: UserAddress.tableName,
        equalObject: {'user_id': userId, 'address': address},
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Xoá địa chỉ thành công")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${e}")));
    }
  }
}
