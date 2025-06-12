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
import 'package:pizza_store_app/widgets/LoadingDialog.dart';
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

  Future<void> updateInfo({
    required String userName,
    required String phoneNumber,
  }) async {
    await AppUserSnapshot.updateInfoAppUser(
      phoneNumber: phoneNumber,
      userName: userName,
      userId: appUser!.userId,
    );
    await fetchUser();
  }

  Future<void> changePassword({
    required String currPwd,
    required String newPwd,
    required String confirmNewPw,
  }) async {
    await AppUserSnapshot.updatePassword(
      currPwd: currPwd,
      confirmPwd: confirmNewPw,
      newPwd: newPwd,
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

  Future<void> updateAvatarUser({
    required File image,
    bool upsert = false,
  }) async {
    loadingDialog();
    await AppUserSnapshot.updateAvatar(
      image: image,
      userId: appUser!.userId,
      upsert: upsert,
    );
    Get.back();
    await fetchUser();
    update(["user"]);
  }
}

class BindingsUserController extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserController());
  }
}
