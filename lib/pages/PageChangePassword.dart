import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PageChangePassword extends StatelessWidget {
  PageChangePassword({super.key});
  TextEditingController txtCurrPw = TextEditingController();
  TextEditingController txtNewPw = TextEditingController();
  TextEditingController txtConfirmNewPw = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Thay mật khẩu"),
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              children: [
                TextFormField(
                  controller: txtCurrPw,
                  decoration: InputDecoration(labelText: "Mật khẩu hiện tại"),
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
  }
}
