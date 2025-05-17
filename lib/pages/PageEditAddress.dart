import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_user.dart';
import 'package:pizza_store_app/models/user_address.model.dart';

class PageEditAddress extends StatelessWidget {
  PageEditAddress({super.key, required this.address});
  TextEditingController txtNewAddress = TextEditingController();
  TextEditingController txtNickNameAddress = TextEditingController();
  TextEditingController txtCurrAddress = TextEditingController();
  UserAddress address;
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: UserController.get(),
      id: "editAddress",
      builder: (controller) {
        txtNewAddress.text = address.address;
        txtCurrAddress.text = address.address;
        txtNickNameAddress.text = address.addressNickName ?? "";
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text("Sửa địa chỉ"),
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
                      controller: txtNewAddress,
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
                          await controller.updateAddress(
                            context: context,
                            txtCurrAddress: txtCurrAddress,
                            txtNewAddress: txtNewAddress,
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
                          "Cập nhật",
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
