import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_user.dart';

class PageAddAddress extends StatelessWidget {
  PageAddAddress({super.key});
  TextEditingController txtAddress = TextEditingController();
  TextEditingController txtNickNameAddress = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: UserController.get(),
      id: "addAddress",
      builder: (controller) {
        final user = controller.appUser;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text("Địa chỉ mới"),
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
                      controller: txtAddress,
                      decoration: InputDecoration(labelText: "Địa chỉ"),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: txtNickNameAddress,
                      decoration: InputDecoration(labelText: "Nick name"),
                    ),

                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await controller.addNewAddress(
                            context: context,
                            txtAddress: txtAddress,
                            txtNickName: txtNickNameAddress,
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
                          "Hoàn thành",
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
