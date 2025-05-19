import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pizza_store_app/controllers/controller_orders_manager.dart';
import 'package:pizza_store_app/enums/OrderStatus.dart';

class PageOrdersList extends StatelessWidget {
  PageOrdersList({super.key});

  final currencyFormat = NumberFormat.currency(locale: "vi_VN", symbol: "₫");
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      id: "orders",
      init: OrdersManagerController.get(),
      builder: (controller) {
        final selectStatus = OrderStatus.fromDisplayTextToName(
          controller.orderStatus,
        );
        final orders = controller.orders;
        print(selectStatus);
        final filterOrders =
            selectStatus == null
                ? orders
                : orders
                    .where((element) => element.status == selectStatus)
                    .toList();
        print("${filterOrders.length}");
        filterOrders.forEach(
          (element) => print("${element.status} - ${element.orderId}"),
        );
        if (controller.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text("Danh sách đơn hàng"),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          body:
              filterOrders.isEmpty
                  ? Center(child: Text("Chưa có đơn hàng nào"))
                  : Column(
                    children: [
                      SizedBox(height: 20),
                      CarouselSlider(
                        items:
                            controller.statuses.map((status) {
                              final isSelect = controller.orderStatus == status;
                              return OutlinedButton(
                                onPressed: () {
                                  controller.setStatus(status);
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor:
                                      isSelect ? Colors.orange : Colors.white,
                                  foregroundColor:
                                      isSelect ? Colors.white : Colors.orange,
                                  side: BorderSide(
                                    color: Colors.orange,
                                    width: 1.5,
                                  ),
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
                                child: Text(status),
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
                      SizedBox(height: 20),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: filterOrders.length,
                          separatorBuilder:
                              (context, index) => SizedBox(height: 15),
                          itemBuilder: (context, index) {
                            final order = filterOrders[index];
                            return Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Mã đơn: ${order.orderId}',
                                          style: TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          order.orderTime != null
                                              ? dateFormat.format(
                                                order.orderTime!,
                                              )
                                              : "Null",
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.payment,
                                          color: Colors.blueAccent,
                                        ),
                                        SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            order.paymentMethod
                                                ? 'Đã thanh toán'
                                                : 'Chưa thanh toán',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          color: Colors.redAccent,
                                        ),
                                        SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            order.shippingAddress ??
                                                'Không có địa chỉ',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.fastfood,
                                          color: Colors.green,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          "Số lượng: ${order.total}",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          "Trạng thái: ${OrderStatus.fromString(order.status).displayText}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                (OrderStatus.fromString(
                                                  order.status,
                                                ).color),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
        );
      },
    );
  }
}
