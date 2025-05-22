import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/helpers/supabase.helper.dart';
import 'package:pizza_store_app/models/app_user.model.dart';

class PageChangeEmail extends StatelessWidget {
  PageChangeEmail({super.key});
  TextEditingController txtEmail = TextEditingController();

  @override
  Widget build(BuildContext context) {
    txtEmail.text = getCurrentUser()?.email ?? "";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Thay đổi email"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                  controller: txtEmail,
                  decoration: InputDecoration(labelText: "Địa chỉ email"),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
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
  }
}
