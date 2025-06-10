import 'package:flutter/material.dart';
import 'package:pizza_store_app/admin/PageAdmin.dart';
import 'package:pizza_store_app/controllers/controller_home.dart';
import 'package:pizza_store_app/controllers/controller_user.dart';
import 'package:pizza_store_app/helpers/supabase.helper.dart';
import 'package:pizza_store_app/layouts/ManagerLayout.dart';
import 'package:pizza_store_app/models/app_user.model.dart';
import 'package:pizza_store_app/pages/auth/PageRegister.dart';
import 'package:pizza_store_app/pages/auth/PageVertifyEmail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

import '../../layouts/MainLayout.dart';
import '../PagePendingOrder.dart';

class PageLogin extends StatelessWidget {
  PageLogin({super.key});

  final _formKey = GlobalKey<FormState>();
  final emailTxt = TextEditingController();
  final pwdTxt = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Đăng nhập vào",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 36,
                color: Colors.black,
              ),
            ),
            Text(
              "tài khoản của bạn.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 36,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Hãy đăng nhập vô tài khoản của bạn",
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: emailTxt,
                    decoration: InputDecoration(labelText: "Địa chỉ Email"),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: pwdTxt,
                    decoration: InputDecoration(labelText: "Mật khẩu"),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        child: Text(
                          "Quên mật khẩu?",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.inversePrimary,
                    ),
                    onPressed: () async {
                      final supabase = Supabase.instance.client;
                      try {
                        final AuthResponse res = await supabase.auth
                            .signInWithPassword(
                              email: emailTxt.text,
                              password: pwdTxt.text,
                            );

                        final User user = res.user!;
                        final userController = UserController.get();

                        await userController.fetchUser();
                        final myUser = userController.appUser;
                        HomePizzaStoreController.get().setCurrUser(user);

                        await AppUserSnapshot.updateUserByObject(
                          updateObject: {"is_active": true},
                          equalObject: {"user_id": user.id},
                        );

                        checkRole(myUser!.roleId);
                      } on AuthException catch (e) {
                        if (e.message == "Email not confirmed") {
                          final supabase = Supabase.instance.client;
                          await supabase.auth.signInWithOtp(
                            email: emailTxt.text,
                          );

                          Get.to(PageVerifyEmail(email: emailTxt.text));
                        }
                      }
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Đăng nhập",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Bạn không có tài khoản? "),
                      GestureDetector(
                        child: Text(
                          "Hãy đăng ký",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        onTap: () => Get.off(PageRegister()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void checkRole(String role) {
  switch (role) {
    case "ADMIN":
      Get.off(PageAdmin());
      break;
    case "MANAGER":
      Get.off(ManagerLayout());
      break;
    case "SHIPPER":
      Get.off(PagePendingOrder());
      break;
    default:
      Get.off(MainLayout(), binding: BindingsHomePizzaStore());
  }
}
