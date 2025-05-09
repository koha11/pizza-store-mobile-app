import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_home.dart';
import 'package:pizza_store_app/helpers/supabase.helper.dart';
import 'package:pizza_store_app/models/app_user.model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PageChangeInfo extends StatelessWidget {
  PageChangeInfo({super.key});
  TextEditingController txtName = TextEditingController();
  TextEditingController txtPhoneNumber = TextEditingController();

  @override
  Widget build(BuildContext context) {
    User? user = getCurrentUser();
    AppUser fakeUser = AppUser(
      userId: "0312kn",
      userName: "Khánh Vinh",
      phoneNumber: "0899348258",
      roleId: "123",
    );
    if (user == null) {
      return Scaffold(body: Center(child: Text("Chưa đăng nhập")));
    }

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
      body: FutureBuilder<AppUser?>(
        future: AppUserSnapshot.getUserById(user!.id),
        builder: (context, snapshot) {
          // if (snapshot.connectionState != ConnectionState.done) {
          //   return Center(child: CircularProgressIndicator());
          // }
          // if (snapshot.hasError) {
          //   return Center(child: Text("Error: ${snapshot.error}"));
          // }
          // if (!snapshot.hasData || snapshot.data == null) {
          //   return Center(child: Text("Không tìm thấy người dùng"));
          // }
          AppUser? user = snapshot.data;
          txtName.text = fakeUser.userName;
          txtPhoneNumber.text = fakeUser.phoneNumber;
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
                        onPressed: () {},
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
