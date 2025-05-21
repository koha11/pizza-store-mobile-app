import 'package:get/get.dart';
import 'package:pizza_store_app/helpers/supabase.helper.dart';
import 'package:pizza_store_app/models/customer_order.model.dart';
import 'package:pizza_store_app/models/order_detail.model.dart';

class ShoppingCartPending extends GetxController{
  List<CustomerOrder> pendingOrders = [];

  Future<void> fetchPendingOrders(String userId) async {
    // Lấy danh sách đơn hàng có status = 'pending'
    final data = await supabase
      .from('customer_order')
      .select()
      .eq('customer_id', userId)
      .eq('status', 'pending');
    pendingOrders = data.map((e) => CustomerOrder.fromJson(e)).toList();
    update();
  }

  Future<List<OrderDetail>> fetchOrderDetails(String orderId) async {
    final map = await CustomerOrderSnapshot.getCartItems(orderId);
    return map.values.toList();
  }
}
class BindingShoppingCartPending extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<ShoppingCartPending>(() => ShoppingCartPending());
  }
}