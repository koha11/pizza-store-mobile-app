import 'package:get/get.dart';
import 'package:pizza_store_app/models/order_items.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsController extends GetxController {
  final supabase = Supabase.instance.client;
  var orderDetails = <OrderDetailWithInfo>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  final String orderId;
  var orderStatus = ''.obs; // Thêm biến để lưu trạng thái đơn hàng

  OrderDetailsController(this.orderId);

  @override
  void onInit() {
    super.onInit();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    try {
      isLoading(true);
      errorMessage('');
      // Lấy thông tin chi tiết đơn hàng và trạng thái đơn hàng
      final response = await supabase
          .from('order_detail')
          .select('''
          amount,
          actual_price,
          items:item_id (item_name, price),
          customer_order:order_id (
            status,
            shipping_fee,
            shipping_address,
            app_user:customer_id (user_name, phone_number)
          )
        ''')
          .eq('order_id', orderId);
      if (response.isEmpty) {
        throw Exception('Không tìm thấy đơn hàng');
      }

      final List<OrderDetailWithInfo> details = [];
      for (final item in response) {
        final orderData = item['customer_order'] as Map<String, dynamic>? ?? {};
        final userData = orderData['app_user'] as Map<String, dynamic>? ?? {};
        final itemData = item['items'] as Map<String, dynamic>? ?? {};

        details.add(OrderDetailWithInfo(
          customerName: userData['user_name']?.toString() ?? 'Không có tên',
          phoneNumber: userData['phone_number']?.toString() ?? 'Không có số điện thoại',
          itemName: itemData['item_name']?.toString() ?? 'Không có tên sản phẩm',
          amount: (item['amount'] as num?)?.toInt() ?? 0,
          unitPrice: (item['actual_price'] as num?)?.toInt() ?? 0,
          subTotal: ((item['amount'] as num?)?.toInt() ?? 0) *
              ((item['actual_price'] as num?)?.toInt() ?? 0),
          shippingFee: (orderData['shipping_fee'] as num?)?.toInt() ?? 0,
          deliveryAddress: orderData['shipping_address']?.toString() ??
              'Không có địa chỉ',
        ));
        orderStatus.value =
            orderData['status']?.toString() ?? ''; // Lưu trạng thái đơn hàng
      }

      orderDetails.assignAll(details);
    } catch (e) {
      errorMessage('Lỗi khi tải dữ liệu: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  int get totalPrice {
    return orderDetails.fold(0, (sum, item) => sum + item.subTotal);
  }

  int get grandTotal =>
      totalPrice + (orderDetails.isNotEmpty ? orderDetails.first.shippingFee : 0);

  //Chuyển status pending sang shipping
  Future<void> confirmOrder() async {
    if (orderStatus.value != 'pending') {
      Get.snackbar('Lỗi', 'Chỉ có thể xác nhận đơn hàng đang chờ xử lý.');
      return;
    }
    try {
      await supabase
          .from('customer_order')
          .update({'status': 'shipping'})
          .eq('order_id', orderId);
      Get.snackbar('Thành công', 'Đơn hàng đã được xác nhận.');
      await _loadOrderDetails(); // Tải lại dữ liệu để cập nhật trạng thái mới
    } catch (e) {
      Get.snackbar('Lỗi', 'Lỗi khi xác nhận đơn hàng: ${e.toString()}');
    }
  }

  //Chuyển status shipping sang finished
  Future<void> markOrderAsFinished() async {
    if (orderStatus.value !=
        'shipping') { // Kiểm tra trạng thái đơn hàng trước khi cập nhật
      Get.snackbar('Lỗi', 'Chỉ có thể hoàn tất đơn hàng đang giao.');
      return; // Dừng nếu không ở trạng thái "shipping"
    }
    try {
      await supabase
          .from('customer_order')
          .update({'status': 'finished'}) // Cập nhật trạng thái thành 'finished'
          .eq('order_id', orderId);
      Get.snackbar('Thành công', 'Đơn hàng đã được hoàn tất.');
      await _loadOrderDetails();
    } catch (e) {
      Get.snackbar('Lỗi', 'Lỗi khi hoàn tất đơn hàng: ${e.toString()}');
    }
  }

  Future<bool> openPhoneDial(String phoneNumber) async {
    bool check = await canLaunchUrl((Uri.parse('tel:$phoneNumber')));
    if (check == false) return false;
    else
      return launch('sms:$phoneNumber');
  }
}
