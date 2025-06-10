import 'package:get/get.dart';
import 'package:pizza_store_app/models/Item.model.dart';
import 'package:pizza_store_app/models/app_user.model.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';
import 'package:pizza_store_app/models/order_detail.model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helpers/supabase.helper.dart';

class OrderDetailsController extends GetxController {
  final String orderId;
  OrderDetailsController({required this.orderId});

  AppUser? customer;
  List<OrderDetail> orderDetail = [];
  CustomerOrder? customerOrder;
  List<Item> items = [];

  bool isLoadingOrderDetail = false;
  bool isLoadingUser = false;
  bool isLoadingCustomerOrder = false;

  RxString orderStatus = 'pending'.obs;

  static OrderDetailsController get() => Get.find();

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  Future<void> _initData() async {
    Future.wait([fetchCustomer(), getCustomerOrder(), getOrderDetail()]);
  }

  Future<void> getOrderDetail() async {
    isLoadingOrderDetail = true;
    update();
    orderDetail = await OrderDetailSnapshot.getOrderDetails();
    isLoadingOrderDetail = false;
    update();
  }

  Future<void> getCustomerOrder() async {
    isLoadingCustomerOrder = true;
    update();
    customerOrder = await CustomerOrderSnapshot.getOrderDetail(
      orderId: orderId,
    );
    isLoadingCustomerOrder = false;
    update();
  }

  Future<void> fetchCustomer() async {
    isLoadingUser = true;
    update();
    if (customerOrder == null) {
      await getCustomerOrder();
    }

    if (customerOrder != null) {
      final users = await AppUserSnapshot.getAppUsers(
        equalObject: {"user_id": customerOrder!.customerId},
      );
      if (users.isNotEmpty) {
        customer = users.first;
      }
    }
    isLoadingUser = false;
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
    if (orderStatus.value != 'pending') {
      Get.snackbar('Lỗi', 'Chỉ có thể xác nhận đơn hàng đang chờ xử lý');
      return;
    }

    try {
      isLoadingCustomerOrder = true;
      update();

      await supabase
          .from('customer_order')
          .update({'status': 'shipping'})
          .eq('order_id', orderId);

      orderStatus.value = 'shipping';
      Get.snackbar('Thành công', 'Đã xác nhận đơn hàng');
      await getCustomerOrder(); // Refresh data
    } catch (e) {
      Get.snackbar('Lỗi', 'Xác nhận đơn hàng thất bại: ${e.toString()}');
    } finally {
      isLoadingCustomerOrder = false;
      update();
    }
  }

  Future<void> markOrderAsFinished() async {
    if (orderStatus.value != 'shipping') {
      Get.snackbar('Lỗi', 'Chỉ có thể hoàn tất đơn hàng đang giao');
      return;
    }

    try {
      isLoadingCustomerOrder = true;
      update();

      await supabase
          .from('customer_order')
          .update({'status': 'finished'})
          .eq('order_id', orderId); // snapshot dau cha

      orderStatus.value = 'finished';
      Get.snackbar('Thành công', 'Đã hoàn tất đơn hàng');
      await getCustomerOrder(); // Refresh data
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
    Get.lazyPut<OrderDetailsController>(
      () => OrderDetailsController(orderId: orderId),
    );
  }
}

// import 'package:get/get.dart';
// import 'package:pizza_store_app/models/order_items.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class OrderDetailsController extends GetxController {
//   final supabase = Supabase.instance.client;
//   var orderDetails = <OrderDetailWithInfo>[].obs;
//   var isLoading = true.obs;
//   var errorMessage = ''.obs;
//   final String orderId;
//   var orderStatus = ''.obs;
//
//   OrderDetailsController(this.orderId);
//
//   @override
//   void onInit() {
//     super.onInit();
//     _loadOrderDetails();
//   }
//
//   Future<void> _loadOrderDetails() async {
//     try {
//       isLoading(true);
//       errorMessage('');
//       final response = await supabase
//           .from('order_detail')
//           .select('''
//           amount,
//           actual_price,
//           items:item_id (item_name, price),
//           customer_order:order_id (
//             status,
//             shipping_fee,
//             shipping_address,
//             app_user:customer_id (user_name, phone_number)
//           )
//         ''')
//           .eq('order_id', orderId);
//       if (response.isEmpty) {
//         throw Exception('Không tìm thấy đơn hàng');
//       }
//
//       final List<OrderDetailWithInfo> details = [];
//       for (final item in response) {
//         final orderData = item['customer_order'] as Map<String, dynamic>? ?? {};
//         final userData = orderData['app_user'] as Map<String, dynamic>? ?? {};
//         final itemData = item['items'] as Map<String, dynamic>? ?? {};
//
//         details.add(OrderDetailWithInfo(
//           customerName: userData['user_name']?.toString() ?? 'Không có tên',
//           phoneNumber: userData['phone_number']?.toString() ?? 'Không có số điện thoại',
//           itemName: itemData['item_name']?.toString() ?? 'Không có tên sản phẩm',
//           amount: (item['amount'] as num?)?.toInt() ?? 0,
//           unitPrice: (item['actual_price'] as num?)?.toInt() ?? 0,
//           subTotal: ((item['amount'] as num?)?.toInt() ?? 0) *
//               ((item['actual_price'] as num?)?.toInt() ?? 0),
//           shippingFee: (orderData['shipping_fee'] as num?)?.toInt() ?? 0,
//           deliveryAddress: orderData['shipping_address']?.toString() ??
//               'Không có địa chỉ',
//         ));
//         orderStatus.value =
//             orderData['status']?.toString() ?? '';
//       }
//
//       orderDetails.assignAll(details);
//     } catch (e) {
//       errorMessage('Lỗi khi tải dữ liệu: ${e.toString()}');
//     } finally {
//       isLoading(false);
//     }
//   }
//
//   int get totalPrice {
//     return orderDetails.fold(0, (sum, item) => sum + item.subTotal);
//   }
//
//   int get grandTotal =>
//       totalPrice + (orderDetails.isNotEmpty ? orderDetails.first.shippingFee : 0);
//
//   Future<void> confirmOrder() async {
//     if (orderStatus.value != 'pending') {
//       Get.snackbar('Lỗi', 'Chỉ có thể xác nhận đơn hàng đang chờ xử lý.');
//       return;
//     }
//     try {
//       await supabase
//           .from('customer_order')
//           .update({'status': 'shipping'})
//           .eq('order_id', orderId);
//       Get.snackbar('Thành công', 'Đơn hàng đã được xác nhận.');
//       await _loadOrderDetails();
//     } catch (e) {
//       Get.snackbar('Lỗi', 'Lỗi khi xác nhận đơn hàng: ${e.toString()}');
//     }
//   }
//
//   Future<void> markOrderAsFinished() async {
//     if (orderStatus.value !=
//         'shipping') {
//       Get.snackbar('Lỗi', 'Chỉ có thể hoàn tất đơn hàng đang giao.');
//       return;
//     }
//     try {
//       await supabase
//           .from('customer_order')
//           .update({'status': 'finished'})
//           .eq('order_id', orderId);
//       Get.snackbar('Thành công', 'Đơn hàng đã được hoàn tất.');
//       await _loadOrderDetails();
//     } catch (e) {
//       Get.snackbar('Lỗi', 'Lỗi khi hoàn tất đơn hàng: ${e.toString()}');
//     }
//   }
//
//   Future<bool> openPhoneDial(String phoneNumber) async {
//     bool check = await canLaunchUrl((Uri.parse('tel:$phoneNumber')));
//     if (check == false) return false;
//     else
//       return launch('sms:$phoneNumber');
//   }
// }
