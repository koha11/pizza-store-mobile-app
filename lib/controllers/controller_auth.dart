import 'package:get/get.dart';
import 'package:pizza_store_app/layouts/MainLayout.dart';
import 'package:pizza_store_app/widgets/LoadingDialog.dart';
import 'package:pizza_store_app/widgets/ShowSnackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/other.helper.dart';
import '../helpers/supabase.helper.dart';
import '../models/app_user.model.dart';
import '../pages/auth/PageVertifyEmail.dart';
import 'controller_ShoppingCart.dart';
import 'controller_history_cart.dart';
import 'controller_home.dart';
import 'controller_user.dart';

class AuthController {
  static Future<void> login({
    required String email,
    required String pwd,
  }) async {
    final supabase = Supabase.instance.client;
    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: pwd,
      );

      final User user = res.user!;
      final userController = UserController.get();

      await userController.fetchUser();
      final myUser = userController.appUser;

      await AppUserSnapshot.updateUserByObject(
        updateObject: {"is_active": true},
        equalObject: {"user_id": user.id},
      );

      Get.offAll(
        checkRole(myUser!.roleId),
        binding: getRoleControllerBindings(myUser.roleId),
      );
    } on AuthException catch (e) {
      if (e.message == "Email not confirmed") {
        await supabase.auth.signInWithOtp(email: email);
        Get.back();
        Get.to(() => PageVerifyEmail(email: email));
      }

      if (e.message == "Invalid login credentials") {
        Get.back();
        showSnackBar(desc: "Sai Email hoặc mật khẩu", success: false);
      }
    }
  }

  static Future<void> register({
    required String email,
    required String pwd,
    required String name,
    required String phone,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final AuthResponse res = await supabase.auth.signUp(
        email: email,
        password: pwd,
      );

      final User? user = res.user;

      if (user != null) {
        await supabase.from('app_user').insert({
          'user_id': user.id,
          'user_name': name,
          'phone_number': phone,
          'user_email': user.email,
          'role_id': "CUSTOMER",
        });

        Get.to(PageVerifyEmail(email: user.email!));
      }
    } catch (e) {
      rethrow;
    }
  }

  static void verifyOtp({
    required String otpCode,
    required String email,
  }) async {
    final supabase = Supabase.instance.client;

    if (otpCode.length == 6) {
      loadingDialog();

      AuthResponse res = await supabase.auth.verifyOTP(
        type: OtpType.email,
        token: otpCode,
        email: email,
      );

      if (res.user != null) {
        await UserController.get().fetchUser();
        Get.offAll(MainLayout(), binding: getRoleControllerBindings(""));
      }
    }
  }

  static Future<void> signOut() async {
    final userController = UserController.get();
    final supabase = Supabase.instance.client;

    await supabase.auth.signOut();
    await SupabaseSnapshot.update(
      table: AppUser.tableName,
      updateObject: {"is_active": false},
      equalObject: {"user_id": userController.appUser!.userId},
    );

    // Reset các controller
    if (Get.isRegistered<HistoryCartController>()) {
      Get.find<HistoryCartController>().reset();
    }
    if (Get.isRegistered<ShoppingCartController>()) {
      Get.find<ShoppingCartController>().reset();
    }

    userController.appUser = null;

    HomePizzaStoreController.get().refreshHome();
  }
}
