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
    String columnName = "",
    String columnValue = "",
  }) async {
    return SupabaseSnapshot.getList(
      table: UserAddress.tableName,
      fromJson: UserAddress.fromJson,
      columnName: columnName,
      columnValue: columnValue,
    );
  }

  static Future<Map<String, UserAddress>> getMapUserAddress() {
    return SupabaseSnapshot.getMapT<String, UserAddress>(
      table: UserAddress.tableName,
      fromJson: UserAddress.fromJson,
      getId: (p0) => p0.userId,
    );
  }
}
