import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:pizza_store_app/helpers/supabase.helper.dart';
import 'package:pizza_store_app/pages/PageLogin.dart';

import '../controllers/controller_home.dart';

class PageProfile extends StatelessWidget {
  PageProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            Icon(Icons.person),
            (getCurrentUser() == null
                ? GestureDetector(
                  child: Text("Bạn chưa đăng nhập, click để đăng nhập"),
                  onTap: () => Get.off(PageLogin()),
                )
                : Text(getCurrentUser()!.id)),
            GestureDetector(
              child: Text("Đăng xuất"),
              onTap: () async {
                await HomePizzaStoreController.get().signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
