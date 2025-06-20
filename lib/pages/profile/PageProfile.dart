import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pizza_store_app/admin/PageAdmin.dart';
import 'package:pizza_store_app/controllers/controller_auth.dart';
import 'package:pizza_store_app/controllers/controller_dashboard_manager.dart';
import 'package:pizza_store_app/controllers/controller_orders_manager.dart';
import 'package:pizza_store_app/controllers/controller_user.dart';
import 'package:pizza_store_app/helpers/other.helper.dart';
import 'package:pizza_store_app/helpers/supabase.helper.dart';
import 'package:pizza_store_app/layouts/MainLayout.dart';
import 'package:pizza_store_app/pages/dashboard/PageDashboard.dart';
import 'package:pizza_store_app/pages/home/PageHome.dart';
import 'package:pizza_store_app/pages/profile/PageAddress.dart';
import 'package:pizza_store_app/pages/profile/PageChangeInfo.dart';
import 'package:pizza_store_app/pages/profile/PageChangePassword.dart';
import 'package:pizza_store_app/pages/auth/PageLogin.dart';
import 'package:pizza_store_app/pages/order_manager/PageOrderDetailManager.dart';
import 'package:pizza_store_app/pages/order_manager/PageOrdersList.dart';
import 'package:pizza_store_app/widgets/LoadingDialog.dart';

class PageProfile extends StatelessWidget {
  PageProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: UserController.get(),
      id: "user",
      builder: (controller) {
        final user = controller.appUser;
        if (controller.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        if (user == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Text("Bạn chưa đăng nhập, click để đăng nhập "),
                    onTap: () => Get.off(PageLogin()),
                  ),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(
                                  user.avatar != null && user.avatar!.isNotEmpty
                                      ? user.avatar!
                                      : "https://images.unsplash.com/photo-1633332755192-727a05c4013d?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8dXNlcnxlbnwwfHwwfHx8MA%3D%3D",
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () async {
                                final pickedImage = await ImagePicker()
                                    .pickImage(source: ImageSource.gallery);
                                if (pickedImage != null) {
                                  File file = File(pickedImage.path);
                                  await controller.updateAvatarUser(
                                    image: file,
                                  );
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 15),
                    Text(
                      "${user.userName}",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      getCurrentUser()?.email ?? "",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    SizedBox(height: 50),
                    GestureDetector(
                      onTap: () => Get.to(() => PageChangeInfo()),
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
                      onTap: () => Get.to(() => PageChangePassword()),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.password, size: 25),
                              SizedBox(width: 15),
                              Text(
                                "Mật khẩu",
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
                      onTap: () => Get.to(PageAddress()),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 25),
                              SizedBox(width: 15),
                              Text(
                                "Địa chỉ",
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

                    SizedBox(height: 50),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          loadingDialog();
                          await AuthController.signOut();
                          Get.offAll(
                            () => checkRole(""),
                            binding: getRoleControllerBindings(""),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                            side: BorderSide(color: Colors.grey, width: 1.5),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout_outlined, size: 20),
                            SizedBox(width: 10),
                            Text(
                              "Đăng xuất",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
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
