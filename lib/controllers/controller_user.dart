import 'package:get/get.dart';
import 'package:pizza_store_app/helpers/supabase.helper.dart';
import 'package:pizza_store_app/models/app_user.model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserController extends GetxController {
  AppUser? appUser;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchUser();
  }

  static UserController get() => Get.find();
  Future<void> fetchUser() async {
    User? user = getCurrentUser();
    if (user != null) {
      List<AppUser> res = await AppUserSnapshot.getAppUsers(
        columnName: "user_id",
        columnValue: user.id,
      );
      if (res.isNotEmpty) {
        appUser = res.first;
        update(["user"]);
      }
    }
  }

  Future<void> signOut() async {
    final supabase = Supabase.instance.client;
    await supabase.auth.signOut();
    appUser = null;
    update(["1"]);
  }
}

class BindingUserController extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    Get.lazyPut<UserController>(() => UserController());
  }
}
