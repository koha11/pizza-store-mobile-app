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
        columnName: "user_id",
        columnValue: user.id,
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
        columnName: "user_id",
        columnValue: appUser!.userId,
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
    final userName = txtUserName.text;
    final phoneNumber = txtPhoneNumber.text;
    ScaffoldMessenger.of(context).clearSnackBars();
    if (userName.isEmpty || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Đang cập nhật...")));
    try {
      await AppUserSnapshot.updateInfoAppUser(
        userName: userName,
        phoneNumber: phoneNumber,
        userId: appUser!.userId,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Cập nhật thành công")));
      await fetchUser();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đã xảy ra lỗi không xác định")));
    }
    update(["changeInfo"]);
  }

  Future<void> changePassword({
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
      ).showSnackBar(SnackBar(content: Text("Không tìm thấy tài khoản")));
      return;
    }
    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: currPwd,
      );

      await supabase.auth.updateUser(UserAttributes(password: newPwd));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đổi mật khẩu thành công")));
      txtCurrPw.clear();
      txtNewPw.clear();
      txtConfirmNewPw.clear();
      update(["changePassword"]);
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

  Future<void> addNewAddress({
    required BuildContext context,
    required TextEditingController txtAddress,
    required TextEditingController txtNickName,
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
      final Map<String, dynamic> updates = {};
      updates['user_id'] = appUser!.userId;
      updates['address'] = address;
      updates['address_nickname'] = nickName;

      await supabase.from("user_address").insert(updates);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Thêm địa chỉ thành công")));
      txtAddress.clear();
      txtNickName.clear();
      await fetchAddress();
      update(["addAddress"]);
      update(["address"]);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${e}")));
    }
  }
}

class BindingsUserController extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserController>(() => UserController());
  }
}
