import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pizza_store_app/controllers/controller_ShoppingCart.dart';
import 'package:pizza_store_app/controllers/controller_history_cart.dart';
import 'package:pizza_store_app/helpers/supabase.helper.dart';
import 'package:pizza_store_app/models/app_user.model.dart';
import 'package:pizza_store_app/models/user_address.model.dart';
import 'package:pizza_store_app/models/user_role.model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../dialogs/dialog.dart';
import '../helpers/supabase.helper.dart' as SupabaseHelper;

class UserController extends GetxController {
  AppUser? appUser;
  List<UserAddress>? userAddress;
  bool isLoading = false;

  static UserController get() => Get.find();

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> fetchUser() async {
    isLoading = true;
    update(["user"]);
    User? user = getCurrentUser();
    if (user != null) {
      List<AppUser> res = await AppUserSnapshot.getAppUsers(
        equalObject: {"user_id": user.id},
      );
      if (res.isNotEmpty) {
        appUser = res.first;
      }
    }
    isLoading = false;
    update(["user"]);
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    await SupabaseSnapshot.update(
      table: AppUser.tableName,
      updateObject: {"is_active": false},
      equalObject: {"user_id": appUser!.userId},
    );

    // Reset các controller
    if (Get.isRegistered<HistoryCartController>()) {
      Get.find<HistoryCartController>().reset();
    }
    if (Get.isRegistered<ShoppingCartController>()) {
      Get.find<ShoppingCartController>().reset();
    }

    appUser = null;
    update(["1"]);
  }

  Future<void> updateInfo({
    required BuildContext context,
    required TextEditingController txtUserName,
    required TextEditingController txtPhoneNumber,
  }) async {
    await AppUserSnapshot.updateInfoAppUser(
      context: context,
      txtUserName: txtUserName,
      txtPhoneNumber: txtPhoneNumber,
      userId: appUser!.userId,
    );
    await fetchUser();
  }

  Future<void> changePassword({
    required BuildContext context,
    required TextEditingController txtCurrPw,
    required TextEditingController txtNewPw,
    required TextEditingController txtConfirmNewPw,
  }) async {
    await AppUserSnapshot.updatePassword(
      context: context,
      txtCurrPw: txtCurrPw,
      txtNewPw: txtNewPw,
      txtConfirmNewPw: txtConfirmNewPw,
    );
    update(["changePassword"]);
  }

  Future<void> addNewAddress({
    required BuildContext context,
    required TextEditingController txtAddress,
    required TextEditingController txtNickName,
  }) async {
    await UserAddressSnapshot.addNewAddress(
      context: context,
      txtAddress: txtAddress,
      txtNickName: txtNickName,
      userId: appUser!.userId,
    );
    await fetchUser();
    update(["addAddress"]);
  }

  Future<void> updateAddress({
    required BuildContext context,
    required TextEditingController txtNewAddress,
    required TextEditingController txtNickName,
    required TextEditingController txtCurrAddress,
  }) async {
    await UserAddressSnapshot.updateAddress(
      context: context,
      txtNewAddress: txtNewAddress,
      txtCurrAddress: txtCurrAddress,
      txtNickName: txtNickName,
      userId: appUser!.userId,
    );
    await fetchUser();
    update(["addAddress"]);
  }

  Future<void> deleteAddress({
    required BuildContext context,
    required TextEditingController txtAddress,
  }) async {
    await UserAddressSnapshot.deleteAddress(
      context: context,
      txtAddress: txtAddress,
      userId: appUser!.userId,
    );

    await fetchUser();
    update(["editAddress"]);
  }

  // Viết phần User Admin
}

class BindingsUserController extends Bindings {
  @override
  void dependencies() {
    // Get.put<UserController>(UserController());
    Get.lazyPut(() => UserController());
  }
}
