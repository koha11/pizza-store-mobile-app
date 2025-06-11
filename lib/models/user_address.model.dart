import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/widgets/ShowSnackbar.dart';

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
    required String address,
    required String nickName,
    required String userId,
  }) async {
    if (address.isEmpty) {
      showSnackBar(desc: "Địa chỉ không được trống", success: false);
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
      showSnackBar(desc: "Thêm thành công", success: true);
    } catch (e) {
      showSnackBar(desc: e.toString(), success: false);
    }
  }

  static Future<void> updateAddress({
    required String newAddress,
    required String currAddress,
    required String nickName,
    required String userId,
  }) async {
    if (newAddress.isEmpty) {
      showSnackBar(desc: "Địa chỉ không được trống", success: false);
      return;
    }

    try {
      final Map<String, dynamic> updates = {};
      updates['address'] = newAddress;
      updates['address_nickname'] = nickName;

      await SupabaseSnapshot.update(
        table: UserAddress.tableName,
        updateObject: updates,
        equalObject: {'user_id': userId, 'address': currAddress},
      );
      showSnackBar(desc: "Cập nhật thành công", success: true);
    } catch (e) {
      showSnackBar(desc: e.toString(), success: false);
    }
  }

  static Future<void> deleteAddress({
    required String address,
    required String userId,
  }) async {
    if (address.isEmpty) {
      showSnackBar(desc: "Địa chỉ trống", success: false);
      return;
    }

    try {
      await SupabaseSnapshot.delete(
        table: UserAddress.tableName,
        equalObject: {'user_id': userId, 'address': address},
      );
      showSnackBar(desc: "Xoá thành công", success: true);
    } catch (e) {
      showSnackBar(desc: e.toString(), success: false);
    }
  }
}
