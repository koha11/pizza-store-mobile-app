import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_shipper.dart';

class PageListShipper extends StatelessWidget {
  const PageListShipper({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShipperController>(
      init: ShipperController.get(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: Text("Danh sách nhân viên giao hàng"),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body:
              controller.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Thông tin nhân viên giao hàng",
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Column(
                                    children:
                                        controller.shipperList.map((e) {
                                          return Column(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Get.back(result: e);
                                                },
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      child: Image.network(
                                                        e.avatar ?? "",
                                                      ),
                                                      color: Colors.white,
                                                      height: 90,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              "Mã nhân viên",
                                                              style: TextStyle(
                                                                fontSize: 17,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              e.userId,
                                                              style: TextStyle(
                                                                fontSize: 17,
                                                              ),
                                                            ),
                                                          ],
                                                        ),

                                                        Column(
                                                          children: [
                                                            Text(
                                                              e.userName,
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              "(+84) ${e.phoneNumber}",
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                color:
                                                                    Colors
                                                                        .grey[600],
                                                              ),
                                                            ),
                                                          ],
                                                        ),

                                                        Row(
                                                          children: [
                                                            Text(
                                                              e.email ?? "",
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
        );
      },
    );
  }
}