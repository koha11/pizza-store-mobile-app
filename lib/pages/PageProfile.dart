import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:pizza_store_app/helpers/supabase.helper.dart';
import 'package:pizza_store_app/pages/PageChangeEmail.dart';
import 'package:pizza_store_app/pages/PageChangeInfo.dart';
import 'package:pizza_store_app/pages/PageChangePassword.dart';
import 'package:pizza_store_app/pages/PageLogin.dart';

import '../controllers/controller_home.dart';

class PageProfile extends StatelessWidget {
  PageProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: HomePizzaStoreController.get(),
      id: "1",
      builder:
          (controller) => Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.person),
                      (getCurrentUser() == null
                          ? GestureDetector(
                            child: Text(
                              "Bạn chưa đăng nhập, click để đăng nhập",
                            ),
                            onTap: () => Get.off(PageLogin()),
                          )
                          : Text(getCurrentUser()!.id)),
                      GestureDetector(
                        child: Text("Đăng xuất"),
                        onTap: () async {
                          await controller.signOut();
                        },
                      ),
                      Text(
                        "Khánh Vinh",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        getCurrentUser()!.email ?? "",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      SizedBox(height: 50),
                      GestureDetector(
                        onTap: () => Get.to(PageChangeInfo()),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person, size: 25),
                                SizedBox(width: 15),
                                Text(
                                  "Thông tin cá nhân",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_forward_ios, size: 20),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      GestureDetector(
                        onTap: () => Get.to(PageChangeEmail()),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.email, size: 25),
                                SizedBox(width: 15),
                                Text(
                                  "Thay đổi email",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_forward_ios, size: 20),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      GestureDetector(
                        onTap: () => Get.to(PageChangePassword()),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.password, size: 25),
                                SizedBox(width: 15),
                                Text(
                                  "Thay đổi mật khẩu",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_forward_ios, size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
