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
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text("Địa chỉ mới"),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                            nickName: txtNickNameAddress.text,
                            address: txtAddress.text,
                          );
                          txtNickNameAddress.clear();
                          txtAddress.clear();
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
                          "Thêm mới",
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
