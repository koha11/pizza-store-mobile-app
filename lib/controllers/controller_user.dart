import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/helpers/supabase.helper.dart';
import 'package:pizza_store_app/models/app_user.model.dart';
import 'package:pizza_store_app/models/user_address.model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserController extends GetxController {
  AppUser? appUser;
  List<UserAddress>? userAddress;
  bool isLoading = false;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchUser();
  }

  static UserController get() => Get.find();
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
        await fetchAddress();
      }
    }
    isLoading = false;
    update(["user"]);
  }

  Future<void> fetchAddress() async {
    if (appUser != null) {
      userAddress = await UserAddressSnapshot.getUserAddress(
        equalObject: {"user_id": appUser!.userId},
      );

      update(["address"]);
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
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
    update(["changeInfo"]);
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
    await fetchAddress();
    update(["addAddress"]);
    update(["address"]);
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
    await fetchAddress();
    update(["addAddress"]);
    update(["address"]);
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
    await fetchAddress();
    update(["addAddress"]);
    update(["address"]);
  }
}

class BindingsUserController extends Bindings {
  @override
  void dependencies() {
    Get.put<UserController>(UserController());
  }
}