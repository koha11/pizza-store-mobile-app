import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pizza_store_app/controllers/controller_order_detail_manager.dart';
import 'package:pizza_store_app/controllers/controller_orders_manager.dart';
import 'package:pizza_store_app/enums/OrderStatus.dart';
import 'package:pizza_store_app/pages/order_manager/PageOrderDetailManager.dart';
import '../../helpers/other.helper.dart';

class PageOrdersList extends StatelessWidget {
  PageOrdersList({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: OrdersManagerController.get(),
      id: "orders",
      builder: (controller) {
        final selectStatus = controller.orderStatus;
        final orders = controller.orders;
        var filterOrders =
            selectStatus == null
                ? orders
                : orders
                    .where((element) => element.status == selectStatus)
                    .toList();
        filterOrders.sort(
          (a, b) => (b.orderTime ?? DateTime(0)).compareTo(
            a.orderTime ?? DateTime(0),
          ),
        );

        return Scaffold(
          backgroundColor: Colors.grey[100],
          body: RefreshIndicator(
            onRefresh: () => controller.getOrders(),
            child:
                controller.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Column(
                      children: [
                        SizedBox(height: 15),
                        CarouselSlider(
                          items:
                              controller.statuses.map((status) {
                                final isSelect =
                                    controller.orderStatus == status;
                                return OutlinedButton(
                                  onPressed: () {
                                    controller.setStatus(status);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor:
                                        isSelect ? Colors.green : Colors.white,
                                    foregroundColor:
                                        isSelect ? Colors.white : Colors.green,
                                    side: BorderSide.none,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                  child: Text(
                                    "${status == null ? "Tất cả" : status.displayText}",
                                  ),
                                );
                              }).toList(),
                          options: CarouselOptions(
                            height: 50,
                            autoPlay: false,
                            enlargeCenterPage: false,
                            padEnds: false,
                            initialPage: 0,
                            viewportFraction: 0.33,
                            enableInfiniteScroll: false,
                          ),
                        ),
                        SizedBox(height: 10),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount:
                                filterOrders.isEmpty ? 1 : filterOrders.length,

                            separatorBuilder:
                                (context, index) => SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              if (filterOrders.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 50),
                                    child: Text(
                                      "Hiện tại không có đơn nào",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              final order = filterOrders[index];
                              return GestureDetector(
                                onTap: () {
                                  Get.to(
                                    () => PageOrderDetailManager(),
                                    binding: BindingOrderDetailManager(
                                      order.orderId,
                                    ),
                                  );
                                },
                                child: Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Mã đơn hàng",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: false,
                                                maxLines: 1,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                "${order.orderId}",
                                                style: TextStyle(fontSize: 18),
                                                textAlign: TextAlign.right,
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: false,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Thời gian đặt",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            Text(
                                              order.orderTime != null
                                                  ? formatDateTime(
                                                    order.orderTime!,
                                                  )
                                                  : "Null",
                                              style: TextStyle(
                                                color: Colors.grey[800],
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Trạng thái thanh toán",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            Text(
                                              order.paymentMethod
                                                  ? 'Đã thanh toán'
                                                  : 'Chưa thanh toán',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Địa chỉ nhận hàng",
                                                style: TextStyle(fontSize: 16),
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: false,
                                                maxLines: 1,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                "${order.shippingAddress}",
                                                style: TextStyle(fontSize: 16),
                                                textAlign: TextAlign.right,
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: false,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Số lượng món",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            Text(
                                              "${order.totalAmount}",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Trạng thái",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            Text(
                                              "${order.status.displayText}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: order.status.color,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
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
