import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pizza_store_app/controllers/controller_order_detail_manager.dart';
import 'package:pizza_store_app/models/app_user.model.dart';
import 'package:pizza_store_app/pages/order_manager/PageShippersList.dart';

import '../../helpers/other.helper.dart';

class PageOrderDetailManager extends StatelessWidget {
  const PageOrderDetailManager({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderDetailManagerController>(
      builder: (controller) {
        final order = controller.orderDetail;

        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: const Text("Chi tiết đơn hàng"),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body:
              controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : order == null
                  ? const Center(child: Text("Không tìm thấy đơn hàng"))
                  : SingleChildScrollView(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
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
                                  "Thông tin đơn hàng",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Mã đơn hàng",
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      order.orderId,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Thời gian đặt",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    Text(
                                      formatDateTime(order.orderTime),
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Thời gian xác nhận",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    Text(
                                      formatDateTime(order.acceptTime),
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Phương thức thanh toán",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    Text(
                                      "${order.paymentMethod ? "Ngân hàng" : "Thanh toán khi nhận hàng"}",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Trạng thái đơn hàng",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    Text(
                                      order.status.displayText,
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                                if (order.note != null)
                                  Column(
                                    children: [
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Icon(Icons.notes, color: Colors.red),
                                          SizedBox(width: 10),
                                          Text("Ghi chú: ${order.note!}"),
                                        ],
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.local_shipping_outlined),
                                    SizedBox(width: 10),
                                    if (order.shipper != null &&
                                        order.manager != null)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Wrap(
                                            spacing: 10,
                                            runSpacing: 4,
                                            children: [
                                              Text(
                                                order.shipper!.userName,
                                                style: TextStyle(fontSize: 17),
                                              ),
                                              Text(
                                                "(+84) ${order.shipper!.phoneNumber}",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            order.shipper!.email ?? "",
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (order.manager == null &&
                                        order.shipper == null)
                                      GestureDetector(
                                        onTap: () async {
                                          AppUser selectedShipper =
                                              await Get.to(
                                                () => PageListShipper(),
                                              );
                                          if (selectedShipper != null) {
                                            await controller
                                                .assignShipperToOrder(
                                                  shipperId:
                                                      selectedShipper.userId,
                                                );
                                          }
                                        },
                                        child: Text(
                                          "Chọn nhân viên giao hàng",
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Divider(),
                                SizedBox(height: 10),
                                Text(
                                  "Thông tin khách hàng",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.location_on_outlined),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Wrap(
                                            spacing: 10,
                                            runSpacing: 4,
                                            children: [
                                              Text(
                                                order.customer!.userName,
                                                style: TextStyle(fontSize: 18),
                                              ),
                                              Text(
                                                "(+84) ${order.customer!.phoneNumber}",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            "${order.customer!.email}",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            "${order.shippingAddress}",
                                            style: TextStyle(
                                              fontSize: 17,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

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
                                  "Các món đặt",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Column(
                                  children:
                                      order.orderDetails!.map((e) {
                                        return Column(
                                          children: [
                                            SizedBox(height: 15),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    child: Container(
                                                      height: 85,
                                                      child: Image.network(
                                                        e.item.itemImage ??
                                                            "https://via.placeholder.com/80",
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                SizedBox(width: 5),
                                                Expanded(
                                                  flex: 2,
                                                  child: Container(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          e.item.itemName ??
                                                              "Tên món",
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                          ),
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                        Text(
                                                          "Loại: ${e.item.category.categoryName}",
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                        Row(
                                                          children:
                                                              e.variantMaps.entries.map((
                                                                e,
                                                              ) {
                                                                return Row(
                                                                  children: [
                                                                    Column(
                                                                      children:
                                                                          e.value.map((
                                                                            a,
                                                                          ) {
                                                                            return Text(
                                                                              a.variantName,
                                                                            );
                                                                          }).toList(),
                                                                    ),
                                                                  ],
                                                                );
                                                              }).toList(),
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  "Số lượng:",
                                                                  style:
                                                                      TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                      ),
                                                                ),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Text(
                                                                  "${e.amount}",
                                                                  style:
                                                                      TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: 25,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Text(
                                                                  "${formatMoney(money: e.actualPrice)}",
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Tổng tiền hàng",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      formatMoney(money: order.total ?? 0),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Phí vận chuyển",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      formatMoney(
                                        money: order.shippingFee ?? 0,
                                      ),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Thành tiền",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    Text(
                                      formatMoney(
                                        money:
                                            order.total! + order.shippingFee!,
                                      ),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
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
    );
  }
}
