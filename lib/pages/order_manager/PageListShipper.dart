import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_order_detail_manager.dart';

class PageListShipper extends StatelessWidget {
  const PageListShipper({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderDetailManagerController>(
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
                                          return Slidable(
                                            key: ValueKey(e.userId),
                                            endActionPane: ActionPane(
                                              extentRatio: 0.3,
                                              motion: ScrollMotion(),
                                              children: [
                                                SlidableAction(
                                                  onPressed: (context) {
                                                    Get.back(result: e);
                                                  },
                                                  backgroundColor: Colors.blue,
                                                  foregroundColor: Colors.white,
                                                  icon: Icons.edit,
                                                  label: 'Chọn',
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              children: [
                                                SizedBox(height: 20),
                                                GestureDetector(
                                                  onTap: () {
                                                    Get.back(result: e);
                                                  },
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      e.avatar != null
                                                          ? Container(
                                                            width: 90,
                                                            height: 90,
                                                            color: Colors.white,
                                                            child:
                                                                Image.network(
                                                                  e.avatar!,
                                                                ),
                                                          )
                                                          : Container(
                                                            width: 90,
                                                            height: 90,
                                                            color: Colors.white,
                                                            child: Image.network(
                                                              "https://media.istockphoto.com/id/1147544807/vector/thumbnail-image-vector-graphic.jpg?s=612x612&w=0&k=20&c=rnCKVbdxqkjlcs3xH87-9gocETqpspHFXu5dIGB4wuM=",
                                                            ),
                                                          ),

                                                      SizedBox(width: 10),

                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  "Mã nhân viên:",
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    e.userId,
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          17,
                                                                    ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),

                                                            SizedBox(height: 4),

                                                            Text(
                                                              e.userName,
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),

                                                            SizedBox(height: 4),

                                                            Text(
                                                              "(+84) ${e.phoneNumber}",
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                color:
                                                                    Colors
                                                                        .grey[600],
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),

                                                            SizedBox(height: 4),

                                                            Text(
                                                              e.email ?? "",
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color:
                                                                    Colors
                                                                        .blueAccent,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
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
