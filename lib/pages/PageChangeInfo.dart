import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_home.dart';
import 'package:pizza_store_app/controllers/controller_user.dart';
import 'package:pizza_store_app/helpers/supabase.helper.dart';
import 'package:pizza_store_app/models/app_user.model.dart';
import 'package:pizza_store_app/pages/PagePendingOrder.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PageChangeInfo extends StatelessWidget {
  PageChangeInfo({super.key});
  TextEditingController txtName = TextEditingController();
  TextEditingController txtPhoneNumber = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Sửa hồ sơ"),
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: GetBuilder(
        init: UserController.get(),
        id: "changeInfo",
        builder: (controller) {
          final user = controller.appUser;
          if (user == null) {
            return Text("Null");
          }
          txtName.text = user.userName;
          txtPhoneNumber.text = user.phoneNumber;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: txtName,
                      decoration: InputDecoration(labelText: "Họ tên"),
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      controller: txtPhoneNumber,
                      decoration: InputDecoration(labelText: "Số điện thoại"),
                    ),
                    SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await controller.updateInfo(
                            context: context,
                            txtUserName: txtName,
                            txtPhoneNumber: txtPhoneNumber,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: Text(
                          "Lưu",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (context) => PagePendingOrder(),
                              )
                            );
                          },
                          child: Text ("Giao hàng")
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
