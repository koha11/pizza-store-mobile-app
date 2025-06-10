import 'package:get/get.dart';
import 'package:pizza_store_app/enums/OrderStatus.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helpers/supabase.helper.dart';
import 'controller_pending_order_shipper.dart';

class OrderDetailsShipperController extends GetxController {
  final String orderId;

  OrderDetailsShipperController({required this.orderId});

  CustomerOrder? customerOrder;

  bool isLoadingCustomerOrder = true;

  static OrderDetailsShipperController get() => Get.find();

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  Future<void> _initData() async {
    await getCustomerOrder();
  }

  Future<void> getCustomerOrder() async {
    customerOrder = await CustomerOrderSnapshot.getOrderById(orderId);
    isLoadingCustomerOrder = false;
    update();
  }

  // Tính tổng tạm tính
  int get subTotal {
    if (customerOrder == null || customerOrder!.orderDetails == null) {
      return 0;
    }
    return customerOrder!.orderDetails!
        .map((e) => e.amount * e.item.price)
        .fold(0, (a, b) => a + b);
  }

  // Tính tổng cộng
  int get grandTotal {
    if (customerOrder == null) return subTotal;
    return subTotal + (customerOrder?.shippingFee ?? 0);
  }

  Future<bool> openPhoneDial(String phoneNumber) async {
    bool check = await canLaunchUrl((Uri.parse('tel:$phoneNumber')));
    if (check == false) return false;
    return launch('sms:$phoneNumber');
  }

  Future<void> confirmOrder() async {
    if (customerOrder?.status != OrderStatus.confirmed) {
      Get.snackbar('Lỗi', 'Chỉ có thể xác nhận đơn hàng đang chờ xử lý');
      return;
    }

    try {
      await SupabaseSnapshot.update<String, CustomerOrder>(
        table: CustomerOrder.tableName,
        updateObject: {
          "status": OrderStatus.shipping.name,
          "delivery_time": DateTime.now().toIso8601String(),
        },
        equalObject: {'order_id': orderId},
      );
      Get.snackbar('Thành công', 'Đã xác nhận đơn hàng');
      await getCustomerOrder();
      await OrderListShipperController.get().listenToGetPendingOrders();
    } catch (e) {
      Get.snackbar('Lỗi', 'Xác nhận đơn hàng thất bại: ${e.toString()}');
    } finally {
      isLoadingCustomerOrder = false;
      update();
    }
  }

  Future<void> markOrderAsFinished() async {
    if (customerOrder?.status != OrderStatus.shipping) {
      Get.snackbar('Lỗi', 'Chỉ có thể hoàn tất đơn hàng đang giao');
      return;
    }

    try {
      await SupabaseSnapshot.update<String, CustomerOrder>(
        table: CustomerOrder.tableName,
        updateObject: {
          "status": OrderStatus.finished.name,
          "delivery_time": DateTime.now().toIso8601String(),
        },
        equalObject: {'order_id': orderId},
      );

      Get.snackbar('Thành công', 'Đã hoàn tất đơn hàng');
      await getCustomerOrder();
      await OrderListShipperController.get().listenToGetPendingOrders();
      await OrderListShipperController.get().listenToGetHistoryOrders();
    } catch (e) {
      Get.snackbar('Lỗi', 'Hoàn tất đơn hàng thất bại: ${e.toString()}');
    } finally {
      isLoadingCustomerOrder = false;
      update();
    }
  }
}

// Binding cho OrderListController
class BindingOrderDetails extends Bindings {
  final String orderId;

  BindingOrderDetails(this.orderId);

  @override
  void dependencies() {
    Get.lazyPut<OrderDetailsShipperController>(
      () => OrderDetailsShipperController(orderId: orderId),
    );
  }
}
