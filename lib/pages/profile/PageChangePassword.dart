import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_user.dart';
import 'package:pizza_store_app/helpers/supabase.helper.dart';
import 'package:pizza_store_app/pages/auth/PageLogin.dart';

class PageChangePassword extends StatelessWidget {
  PageChangePassword({super.key});
  TextEditingController txtCurrPw = TextEditingController();
  TextEditingController txtNewPw = TextEditingController();
  TextEditingController txtConfirmNewPw = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: UserController.get(),
      id: "changePassword",
      builder: (controller) {
        final user = controller.appUser;
        if (user == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Text(
                      "Bạn chưa đăng nhập, click để đăng nhập ${getCurrentUser()!.id}",
                    ),
                    onTap: () => Get.off(PageLogin()),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text("Thay mật khẩu"),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: txtCurrPw,
                      decoration: InputDecoration(
                        labelText: "Mật khẩu hiện tại",
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: txtNewPw,
                      decoration: InputDecoration(labelText: "Mật khẩu mới"),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: txtConfirmNewPw,
                      decoration: InputDecoration(
                        labelText: "Xác nhận mật khẩu mới",
                      ),
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await controller.changePassword(
                            newPwd: txtNewPw.text,
                            confirmNewPw: txtConfirmNewPw.text,
                            currPwd: txtCurrPw.text,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.lightGreen,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: Text(
                          "Tiếp theo",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
