import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pizza_store_app/controllers/controller_ShoppingCart.dart';
import 'package:pizza_store_app/controllers/controller_history_cart.dart';
import 'package:pizza_store_app/controllers/controller_home.dart';
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

  @override
  void onReady() async {
    // TODO: implement onReady
    super.onReady();
    await fetchUser();
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

    HomePizzaStoreController.get().refreshHome();
    update();
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
    required String address,
    required String nickName,
  }) async {
    await UserAddressSnapshot.addNewAddress(
      nickName: nickName,
      address: address,
      userId: appUser!.userId,
    );
    await fetchUser();
    update(["addAddress"]);
  }

  Future<void> updateAddress({
    required String newAddress,
    required String nickName,
    required String currAddress,
  }) async {
    await UserAddressSnapshot.updateAddress(
      currAddress: currAddress,
      newAddress: newAddress,
      nickName: nickName,
      userId: appUser!.userId,
    );
    await fetchUser();
    update(["addAddress"]);
  }

  Future<void> deleteAddress({required String address}) async {
    await UserAddressSnapshot.deleteAddress(
      address: address,
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
