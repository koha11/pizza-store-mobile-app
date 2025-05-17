import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:pizza_store_app/pages/PageAddAddress.dart';
import 'package:pizza_store_app/pages/PageEditAddress.dart';

import '../controllers/controller_user.dart';

class PageAddress extends StatelessWidget {
  PageAddress({super.key});
  TextEditingController txtAddress = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Địa chỉ của tôi"),
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: GetBuilder(
        init: UserController.get(),
        id: "address",
        builder: (controller) {
          final listAddress = controller.userAddress;
          if (listAddress!.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Center(child: Text("Bạn chưa có địa chỉ nào")),
                  SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => PageAddAddress());
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline, size: 25),
                          SizedBox(width: 10),
                          Text(
                            "Thêm địa chỉ",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: listAddress.length,
                    itemBuilder: (context, index) {
                      final address = listAddress[index];
                      txtAddress.text = address.address;
                      return Slidable(
                        key: ValueKey(0),
                        endActionPane: ActionPane(
                          extentRatio: 0.6,
                          motion: ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                Get.to(() => PageEditAddress(address: address));
                              },
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Sửa',
                            ),
                            SlidableAction(
                              onPressed: (context) async {
                                await controller.deleteAddress(
                                  context: context,
                                  txtAddress: txtAddress,
                                );
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Xoá',
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.location_on,
                            size: 35,
                            color: Colors.redAccent,
                          ),
                          title: Text(address.addressNickName ?? "Chưa có tên"),
                          subtitle: Text(
                            address.address,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      );
                    },
                    separatorBuilder:
                        (BuildContext context, int index) =>
                            Divider(thickness: 1.5),
                  ),
                  SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => PageAddAddress());
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline, size: 25),
                          SizedBox(width: 10),
                          Text(
                            "Thêm địa chỉ",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
